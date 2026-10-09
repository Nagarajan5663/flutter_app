const express = require('express');
const db = require('../config/db');

const {
  getNextTransactionNumber,
} = require('../utils/transaction_number');

const router = express.Router();

// ============================================================
// HELPERS
// ============================================================

function toNumber(
  value,
  fallback = 0
) {
  const number = Number(value);

  return Number.isFinite(number)
    ? number
    : fallback;
}

function normalizeDate(value) {
  if (value == null) {
    return null;
  }

  const text =
    value
      .toString()
      .trim();

  if (text === '') {
    return null;
  }

  return text.length >= 10
    ? text.substring(0, 10)
    : text;
}

function mapBillItem(row) {
  return {
    id:
      row.id
        ?.toString() ??
      null,

    billId:
      row.bill_id
        ?.toString() ??
      '',

    sourceType:
      row.source_type ??
      '',

    itemId:
      row.item_id == null
        ? null
        : row.item_id
            .toString(),

    partId:
      row.part_id == null
        ? null
        : row.part_id
            .toString(),

    itemName:
      row.item_name ??
      '',

    description:
      row.description ??
      '',

    qty:
      toNumber(
        row.qty
      ),

    rate:
      toNumber(
        row.rate
      ),

    amount:
      toNumber(
        row.amount
      ),
  };
}

function mapBill(
  row,
  items = []
) {
  return {
    id:
      row.id
        ?.toString() ??
      null,

    billNumber:
      row.bill_number ??
      '',

    vendorInvoiceNumber:
      row.vendor_invoice_number ??
      '',

    invoiceAttachmentPath:
      row.invoice_attachment_path ??
      null,

    vendorId:
      row.vendor_id
        ?.toString() ??
      '',

    vendorName:
      row.vendor_name ??
      '',

    purchaseOrderId:
      row.purchase_order_id ==
      null
        ? null
        : row.purchase_order_id
            .toString(),

    purchaseOrderNumber:
      row.purchase_order_number ??
      null,

    billDate:
      row.bill_date ??
      '',

    dueDate:
      row.due_date ??
      null,

    items,

    taxAmount:
      toNumber(
        row.tax_amount
      ),

    amountPaid:
      toNumber(
        row.amount_paid
      ),

    isVoided:
      row.is_voided === true ||
      row.is_voided === 1 ||
      row.is_voided === '1',

    subTotal:
      toNumber(
        row.sub_total
      ),

    total:
      toNumber(
        row.total
      ),

    createdAt:
      row.created_at ??
      null,

    updatedAt:
      row.updated_at ??
      null,
  };
}

// ============================================================
// RESOLVE ITEM / PART FROM EXISTING CATALOG
// ============================================================

async function resolveCatalogProduct(
  connection,
  itemName,
  rate
) {
  const name =
    itemName
      ?.toString()
      .trim() ??
    '';

  if (!name) {
    const error =
      new Error(
        'Item name is required'
      );

    error.statusCode =
      400;

    throw error;
  }

  const [itemRows] =
    await connection.query(
      `
      SELECT
        id,
        name,
        purchase_price,
        description

      FROM items

      WHERE name = ?
      `,
      [
        name,
      ]
    );

  const [partRows] =
    await connection.query(
      `
      SELECT
        id,
        name,
        purchase_price,
        description

      FROM parts

      WHERE name = ?
      `,
      [
        name,
      ]
    );

  const candidates = [];

  for (
    const row
    of itemRows
  ) {
    candidates.push({
      sourceType:
        'Item',

      itemId:
        Number(
          row.id
        ),

      partId:
        null,

      name:
        row.name,

      purchasePrice:
        toNumber(
          row.purchase_price
        ),

      description:
        row.description ??
        '',
    });
  }

  for (
    const row
    of partRows
  ) {
    candidates.push({
      sourceType:
        'Part',

      itemId:
        null,

      partId:
        Number(
          row.id
        ),

      name:
        row.name,

      purchasePrice:
        toNumber(
          row.purchase_price
        ),

      description:
        row.description ??
        '',
    });
  }

  if (
    candidates.length === 0
  ) {
    const error =
      new Error(
        `Selected item "${name}" was not found in Items or Parts`
      );

    error.statusCode =
      404;

    throw error;
  }

  if (
    candidates.length === 1
  ) {
    return candidates[0];
  }

  const matchingRate =
    candidates.filter(
      (candidate) =>
        Math.abs(
          candidate.purchasePrice -
            rate
        ) < 0.005
    );

  if (
    matchingRate.length === 1
  ) {
    return matchingRate[0];
  }

  const error =
    new Error(
      `More than one Item/Part uses the name "${name}".`
    );

  error.statusCode =
    400;

  throw error;
}

// ============================================================
// NEXT BILL NUMBER
//
// GET /api/bills/next-number
//
// module = Bill
// Prefix and starting number are fully dynamic.
// ============================================================

router.get(
  '/next-number',
  async (req, res) => {
    try {
      const result =
        await getNextTransactionNumber({
          module:
            'Bill',

          table:
            'bills',

          numberColumn:
            'bill_number',

          padding:
            4,
        });

      return res
        .status(200)
        .json({
          success: true,

          data: {
            billNumber:
              result.transactionNumber,

            prefix:
              result.prefix,

            startingNumber:
              result.startingNumber,

            nextNumber:
              result.nextNumber,
          },
        });
    } catch (error) {
      console.error(
        'Get next bill number error:',
        error
      );

      return res
        .status(
          error.statusCode ??
            500
        )
        .json({
          success: false,

          message:
            error.message ||
            'Failed to generate bill number',
        });
    }
  }
);

// ============================================================
// GET ALL BILLS
//
// GET /api/bills
// ============================================================

router.get(
  '/',
  async (req, res) => {
    try {
      const {
        vendor,
        vendorName,
        vendor_id,

        dateFrom,
        dateTo,

        date_from,
        date_to,
        status_filter,
      } = req.query;

      const finalVendor =
        (
          vendor ??
          vendorName ??
          ''
        )
          .toString()
          .trim();

      const finalDateFrom =
        normalizeDate(
          dateFrom ??
          date_from
        );

      const finalDateTo =
        normalizeDate(
          dateTo ??
          date_to
        );

      let sql = `
        SELECT
          id,

          bill_number,

          vendor_invoice_number,
          invoice_attachment_path,

          vendor_id,
          vendor_name,

          purchase_order_id,
          purchase_order_number,

          DATE_FORMAT(
            bill_date,
            '%Y-%m-%d'
          ) AS bill_date,

          CASE
            WHEN due_date
              IS NULL
              THEN NULL

            ELSE DATE_FORMAT(
              due_date,
              '%Y-%m-%d'
            )
          END AS due_date,

          sub_total,
          tax_amount,
          total,
          amount_paid,

          EXISTS (
            SELECT 1
            FROM bill_voids
            WHERE bill_voids.bill_id = CAST(bills.id AS CHAR)
          ) AS is_voided,

          created_at,
          updated_at

        FROM bills

        WHERE 1 = 1
      `;

      const values = [];

      const finalStatus =
        (status_filter ?? '')
          .toString()
          .trim();

      if (finalStatus === 'Void') {
        sql += `
          AND EXISTS (
            SELECT 1
            FROM bill_voids
            WHERE bill_voids.bill_id = CAST(bills.id AS CHAR)
          )
        `;
      } else if (['Unpaid', 'Partially Paid', 'Paid'].includes(finalStatus)) {
        sql += `
          AND NOT EXISTS (
            SELECT 1
            FROM bill_voids
            WHERE bill_voids.bill_id = CAST(bills.id AS CHAR)
          )
        `;
        if (finalStatus === 'Unpaid') {
          sql += ' AND amount_paid <= 0';
        } else if (finalStatus === 'Partially Paid') {
          sql += ' AND amount_paid > 0 AND amount_paid < total';
        } else {
          sql += ' AND amount_paid >= total';
        }
      }

      if (
        finalVendor !== ''
      ) {
        sql += `
          AND vendor_name
            LIKE ?
        `;

        values.push(
          `%${finalVendor}%`
        );
      }

      if (
        vendor_id
      ) {
        sql += `
          AND vendor_id = ?
        `;

        values.push(
          vendor_id
        );
      }

      if (
        finalDateFrom
      ) {
        sql += `
          AND bill_date >= ?
        `;

        values.push(
          finalDateFrom
        );
      }

      if (
        finalDateTo
      ) {
        sql += `
          AND bill_date <= ?
        `;

        values.push(
          finalDateTo
        );
      }

      sql += `
        ORDER BY id DESC
      `;

      const [billRows] =
        await db.query(
          sql,
          values
        );

      if (
        billRows.length === 0
      ) {
        return res
          .status(200)
          .json({
            success: true,

            data: [],
          });
      }

      const ids =
        billRows.map(
          (row) =>
            Number(
              row.id
            )
        );

      const placeholders =
        ids
          .map(() => '?')
          .join(',');

      const [itemRows] =
        await db.query(
          `
          SELECT
            id,
            bill_id,

            source_type,

            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM bill_items

          WHERE bill_id
            IN (${placeholders})

          ORDER BY
            bill_id ASC,
            id ASC
          `,
          ids
        );

      const groupedItems =
        {};

      for (
        const row
        of itemRows
      ) {
        const billId =
          Number(
            row.bill_id
          );

        if (
          !groupedItems[
            billId
          ]
        ) {
          groupedItems[
            billId
          ] = [];
        }

        groupedItems[
          billId
        ].push(
          mapBillItem(
            row
          )
        );
      }

      const data =
        billRows.map(
          (row) => {
            const id =
              Number(
                row.id
              );

            return mapBill(
              row,

              groupedItems[
                id
              ] ?? []
            );
          }
        );

      return res
        .status(200)
        .json({
          success: true,

          data,
        });
    } catch (error) {
      console.error(
        'Get bills error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to fetch bills',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// GET PAYMENTS MADE
//
// GET /api/bills/payments-made
// ============================================================

router.get(
  '/payments-made',
  async (req, res) => {
    try {
      const conditions = [];
      const values = [];
      const vendor = req.query.vendor?.toString().trim() ?? '';
      const billNumber = req.query.billNumber?.toString().trim() ?? '';
      const dateFrom = normalizeDate(req.query.dateFrom);
      const dateTo = normalizeDate(req.query.dateTo);

      if (vendor) {
        conditions.push('b.vendor_name LIKE ?');
        values.push(`%${vendor}%`);
      }
      if (billNumber) {
        conditions.push('b.bill_number LIKE ?');
        values.push(`%${billNumber}%`);
      }
      if (dateFrom) {
        conditions.push('p.payment_date >= ?');
        values.push(dateFrom);
      }
      if (dateTo) {
        conditions.push('p.payment_date <= ?');
        values.push(dateTo);
      }

      const where = conditions.length
        ? `WHERE ${conditions.join(' AND ')}`
        : '';
      const [rows] = await db.query(
        `
        SELECT
          p.id,
          p.bill_id,
          DATE_FORMAT(p.payment_date, '%Y-%m-%d') AS payment_date,
          p.amount,
          p.payment_mode,
          p.reference_number,
          p.paid_by,
          p.notes,
          b.bill_number,
          b.vendor_name,
          b.vendor_invoice_number,
          v.email AS vendor_email,
          v.phone AS vendor_phone
        FROM bill_payments p
        INNER JOIN bills b ON b.id = p.bill_id
        LEFT JOIN vendors v ON v.id = b.vendor_id
        ${where}
        ORDER BY p.payment_date DESC, p.id DESC
        `,
        values
      );

      return res.status(200).json({
        success: true,
        data: rows.map((row) => ({
          id: row.id.toString(),
          paymentNumber: `PAY-${row.id}`,
          billId: row.bill_id.toString(),
          billNumber: row.bill_number ?? '',
          vendorName: row.vendor_name ?? '',
          vendorInvoiceNumber: row.vendor_invoice_number ?? '',
          date: row.payment_date,
          amount: toNumber(row.amount),
          mode: row.payment_mode ?? '',
          reference: row.reference_number ?? '',
          paidBy: row.paid_by ?? '',
          notes: row.notes ?? '',
          vendorEmail: row.vendor_email ?? '',
          vendorPhone: row.vendor_phone ?? '',
        })),
      });
    } catch (error) {
      console.error('Get payments made error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to fetch payments made',
        error: error.message,
      });
    }
  }
);

router.put(
  '/payments-made/:paymentId',
  async (req, res) => {
    let connection;
    let transactionStarted = false;
    try {
      const { paymentId } = req.params;
      const payment = Number(toNumber(req.body.amount).toFixed(2));
      const paymentDate = normalizeDate(req.body.date);
      const paymentMode = req.body.mode?.toString().trim() ?? '';
      const reference = req.body.reference?.toString().trim() ?? '';
      const paidBy = req.body.paidBy?.toString().trim() ?? '';
      const notes = req.body.notes?.toString().trim() ?? '';
      const parsedDate = paymentDate
        ? new Date(`${paymentDate}T00:00:00.000Z`)
        : null;

      if (
        payment <= 0 ||
        !parsedDate ||
        Number.isNaN(parsedDate.getTime()) ||
        parsedDate.toISOString().substring(0, 10) !== paymentDate ||
        !paymentMode ||
        paymentMode.length > 60 ||
        reference.length > 255 ||
        paidBy.length > 255 ||
        notes.length > 2000
      ) {
        return res.status(400).json({
          success: false,
          message: 'Payment details are invalid',
        });
      }

      connection = await db.getConnection();
      await connection.beginTransaction();
      transactionStarted = true;

      const [rows] = await connection.query(
        `
        SELECT
          p.id,
          p.bill_id,
          p.amount,
          b.total,
          b.amount_paid,
          EXISTS (
            SELECT 1
            FROM bill_voids
            WHERE bill_voids.bill_id = CAST(b.id AS CHAR)
          ) AS is_voided
        FROM bill_payments p
        INNER JOIN bills b ON b.id = p.bill_id
        WHERE p.id = ?
        LIMIT 1
        FOR UPDATE
        `,
        [paymentId]
      );
      if (rows.length === 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(404).json({
          success: false,
          message: 'Payment not found',
        });
      }
      const row = rows[0];
      if (
        row.is_voided === true ||
        row.is_voided === 1 ||
        row.is_voided === '1'
      ) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(409).json({
          success: false,
          message: 'Payments for voided bills cannot be edited',
        });
      }
      const adjustedPaid = Number(
        (
          toNumber(row.amount_paid) -
          toNumber(row.amount) +
          payment
        ).toFixed(2)
      );
      if (adjustedPaid > toNumber(row.total) || adjustedPaid < 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(400).json({
          success: false,
          message: 'Payment would exceed the bill total',
        });
      }

      await connection.query(
        `
        UPDATE bill_payments
        SET
          amount = ?,
          payment_date = ?,
          payment_mode = ?,
          reference_number = ?,
          paid_by = ?,
          notes = ?
        WHERE id = ?
        `,
        [
          payment,
          paymentDate,
          paymentMode,
          reference || null,
          paidBy || null,
          notes || null,
          paymentId,
        ]
      );
      await connection.query(
        'UPDATE bills SET amount_paid = ? WHERE id = ?',
        [adjustedPaid, row.bill_id]
      );
      await connection.commit();
      transactionStarted = false;
      return res.status(200).json({
        success: true,
        message: 'Payment updated successfully',
      });
    } catch (error) {
      if (connection && transactionStarted) await connection.rollback();
      console.error('Update payment made error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to update payment',
        error: error.message,
      });
    } finally {
      if (connection) connection.release();
    }
  }
);

router.delete(
  '/payments-made/:paymentId',
  async (req, res) => {
    let connection;
    let transactionStarted = false;
    try {
      const { paymentId } = req.params;
      connection = await db.getConnection();
      await connection.beginTransaction();
      transactionStarted = true;
      const [rows] = await connection.query(
        `
        SELECT p.id, p.bill_id, p.amount, b.amount_paid,
          EXISTS (
            SELECT 1
            FROM bill_voids
            WHERE bill_voids.bill_id = CAST(b.id AS CHAR)
          ) AS is_voided
        FROM bill_payments p
        INNER JOIN bills b ON b.id = p.bill_id
        WHERE p.id = ?
        LIMIT 1
        FOR UPDATE
        `,
        [paymentId]
      );
      if (rows.length === 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(404).json({
          success: false,
          message: 'Payment not found',
        });
      }

      const row = rows[0];
      await connection.query('DELETE FROM bill_payments WHERE id = ?', [
        paymentId,
      ]);
      if (
        row.is_voided !== true &&
        row.is_voided !== 1 &&
        row.is_voided !== '1'
      ) {
        const adjustedPaid = Math.max(
          0,
          Number((toNumber(row.amount_paid) - toNumber(row.amount)).toFixed(2))
        );
        await connection.query(
          'UPDATE bills SET amount_paid = ? WHERE id = ?',
          [adjustedPaid, row.bill_id]
        );
      }
      await connection.commit();
      transactionStarted = false;
      return res.status(200).json({
        success: true,
        message: 'Payment deleted successfully',
      });
    } catch (error) {
      if (connection && transactionStarted) await connection.rollback();
      console.error('Delete payment made error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to delete payment',
        error: error.message,
      });
    } finally {
      if (connection) connection.release();
    }
  }
);

// ============================================================
// GET SINGLE BILL
//
// GET /api/bills/:id
// ============================================================

router.get(
  '/:id',
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      const [billRows] =
        await db.query(
          `
          SELECT
            id,

            bill_number,

            vendor_invoice_number,
            invoice_attachment_path,

            vendor_id,
            vendor_name,

            purchase_order_id,
            purchase_order_number,

            DATE_FORMAT(
              bill_date,
              '%Y-%m-%d'
            ) AS bill_date,

            CASE
              WHEN due_date
                IS NULL
                THEN NULL

              ELSE DATE_FORMAT(
                due_date,
                '%Y-%m-%d'
              )
            END AS due_date,

            sub_total,
            tax_amount,
            total,
            amount_paid,

            EXISTS (
              SELECT 1
              FROM bill_voids
              WHERE bill_voids.bill_id = CAST(bills.id AS CHAR)
            ) AS is_voided,

            created_at,
            updated_at

          FROM bills

          WHERE id = ?

          LIMIT 1
          `,
          [
            id,
          ]
        );

      if (
        billRows.length === 0
      ) {
        return res
          .status(404)
          .json({
            success: false,

            message:
              'Bill not found',
          });
      }

      const [itemRows] =
        await db.query(
          `
          SELECT
            id,
            bill_id,

            source_type,

            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM bill_items

          WHERE bill_id = ?

          ORDER BY id ASC
          `,
          [
            id,
          ]
        );

      return res
        .status(200)
        .json({
          success: true,

          data:
            mapBill(
              billRows[0],

              itemRows.map(
                mapBillItem
              )
            ),
        });
    } catch (error) {
      console.error(
        'Get bill error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to fetch bill',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// CREATE BILL
//
// POST /api/bills
// ============================================================

router.post(
  '/',
  async (req, res) => {
    let connection;

    try {
      const {
        billNumber,

        vendorInvoiceNumber,

        invoiceAttachmentPath,

        vendorId,

        purchaseOrderId,
        purchaseOrderNumber,

        billDate,
        dueDate,

        items,

        taxAmount,

        amountPaid,
      } = req.body;

      // --------------------------------------------------------
      // VALIDATION
      // --------------------------------------------------------

      if (
        !billNumber ||
        billNumber
          .toString()
          .trim() === ''
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Bill number is required',
          });
      }

      const parsedVendorId =
        Number(
          vendorId
        );

      if (
        !Number.isInteger(
          parsedVendorId
        ) ||
        parsedVendorId <= 0
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Please select a valid vendor',
          });
      }

      const finalBillDate =
        normalizeDate(
          billDate
        );

      if (
        !finalBillDate
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Bill date is required',
          });
      }

      if (
        !Array.isArray(
          items
        ) ||
        items.length === 0
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'At least one item is required',
          });
      }

      connection =
        await db.getConnection();

      await connection
        .beginTransaction();

      // --------------------------------------------------------
      // VENDOR
      // --------------------------------------------------------

      const [vendorRows] =
        await connection.query(
          `
          SELECT
            id,
            display_name

          FROM vendors

          WHERE id = ?

          LIMIT 1
          `,
          [
            parsedVendorId,
          ]
        );

      if (
        vendorRows.length === 0
      ) {
        await connection
          .rollback();

        return res
          .status(404)
          .json({
            success: false,

            message:
              'Selected vendor not found',
          });
      }

      const vendor =
        vendorRows[0];

      // --------------------------------------------------------
      // OPTIONAL PURCHASE ORDER
      // --------------------------------------------------------

      let finalPurchaseOrderId =
        null;

      let finalPurchaseOrderNumber =
        purchaseOrderNumber &&
        purchaseOrderNumber
          .toString()
          .trim() !== ''
          ? purchaseOrderNumber
              .toString()
              .trim()
          : null;

      if (
        (purchaseOrderId != null &&
          Number(purchaseOrderId) > 0) ||
        finalPurchaseOrderNumber != null
      ) {
        let poRows = [];
        const parsedPoId = Number(purchaseOrderId);

        if (Number.isInteger(parsedPoId) && parsedPoId > 0) {
          [poRows] = await connection.query(
            `
            SELECT
              id,
              po_number

            FROM purchase_orders

            WHERE id = ?
              AND vendor_id = ?

            LIMIT 1
            `,
            [
              parsedPoId,
              parsedVendorId,
            ]
          );
        }

        if (
          poRows.length === 0 &&
          finalPurchaseOrderNumber != null
        ) {
          [poRows] = await connection.query(
            `
            SELECT
              id,
              po_number

            FROM purchase_orders

            WHERE po_number = ?
              AND vendor_id = ?

            LIMIT 1
            `,
            [
              finalPurchaseOrderNumber,
              parsedVendorId,
            ]
          );
        }

        if (
          poRows.length === 0
        ) {
          await connection
            .rollback();

          return res
            .status(404)
            .json({
              success: false,

              message:
                'Selected purchase order not found',
            });
        }

        finalPurchaseOrderId =
          Number(poRows[0].id);

        finalPurchaseOrderNumber =
          poRows[0]
            .po_number;
      }

      // --------------------------------------------------------
      // ITEMS
      // --------------------------------------------------------

      const preparedItems =
        [];

      let calculatedSubTotal =
        0;

      for (
        const line
        of items
      ) {
        const itemName =
          line.itemName
            ?.toString()
            .trim() ??
          '';

        if (
          itemName === ''
        ) {
          await connection
            .rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                'Every bill row must have an item',
            });
        }

        const qty =
          toNumber(
            line.qty
          );

        const rate =
          toNumber(
            line.rate
          );

        if (
          qty <= 0
        ) {
          await connection
            .rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                `Quantity for "${itemName}" must be greater than zero`,
            });
        }

        if (
          rate < 0
        ) {
          await connection
            .rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                `Rate for "${itemName}" cannot be negative`,
            });
        }

        const product =
          await resolveCatalogProduct(
            connection,

            itemName,

            rate
          );

        const amount =
          Number(
            (
              qty * rate
            ).toFixed(2)
          );

        calculatedSubTotal +=
          amount;

        preparedItems.push({
          sourceType:
            product.sourceType,

          itemId:
            product.itemId,

          partId:
            product.partId,

          itemName:
            product.name,

          description:
            line.description
              ?.toString()
              .trim() ||
            product.description ||
            '',

          qty,

          rate,

          amount,
        });
      }

      calculatedSubTotal =
        Number(
          calculatedSubTotal
            .toFixed(2)
        );

      const finalTaxAmount =
        Math.max(
          0,

          toNumber(
            taxAmount
          )
        );

      const calculatedTotal =
        Number(
          (
            calculatedSubTotal +
            finalTaxAmount
          ).toFixed(2)
        );

      const finalAmountPaid =
        Math.max(
          0,

          toNumber(
            amountPaid
          )
        );

      // --------------------------------------------------------
      // INSERT BILL
      // --------------------------------------------------------

      const [billResult] =
        await connection.query(
          `
          INSERT INTO bills (
            bill_number,

            vendor_invoice_number,
            invoice_attachment_path,

            vendor_id,
            vendor_name,

            purchase_order_id,
            purchase_order_number,

            bill_date,
            due_date,

            sub_total,
            tax_amount,
            total,

            amount_paid
          )
          VALUES (
            ?, ?, ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?, ?
          )
          `,
          [
            billNumber
              .toString()
              .trim(),

            vendorInvoiceNumber &&
            vendorInvoiceNumber
              .toString()
              .trim() !== ''
              ? vendorInvoiceNumber
                  .toString()
                  .trim()
              : null,

            invoiceAttachmentPath &&
            invoiceAttachmentPath
              .toString()
              .trim() !== ''
              ? invoiceAttachmentPath
                  .toString()
                  .trim()
              : null,

            parsedVendorId,

            vendor.display_name,

            finalPurchaseOrderId,

            finalPurchaseOrderNumber,

            finalBillDate,

            normalizeDate(
              dueDate
            ),

            calculatedSubTotal,

            finalTaxAmount,

            calculatedTotal,

            finalAmountPaid,
          ]
        );

      const billId =
        billResult.insertId;

      // --------------------------------------------------------
      // INSERT BILL ITEMS
      // --------------------------------------------------------

      for (
        const line
        of preparedItems
      ) {
        await connection.query(
          `
          INSERT INTO bill_items (
            bill_id,

            source_type,

            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount
          )
          VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?
          )
          `,
          [
            billId,

            line.sourceType,

            line.itemId,

            line.partId,

            line.itemName,

            line.description ||
            null,

            line.qty,

            line.rate,

            line.amount,
          ]
        );
      }

      await connection
        .commit();

      // --------------------------------------------------------
      // RETURN CREATED BILL
      // --------------------------------------------------------

      const [savedRows] =
        await db.query(
          `
          SELECT
            id,

            bill_number,

            vendor_invoice_number,
            invoice_attachment_path,

            vendor_id,
            vendor_name,

            purchase_order_id,
            purchase_order_number,

            DATE_FORMAT(
              bill_date,
              '%Y-%m-%d'
            ) AS bill_date,

            CASE
              WHEN due_date
                IS NULL
                THEN NULL

              ELSE DATE_FORMAT(
                due_date,
                '%Y-%m-%d'
              )
            END AS due_date,

            sub_total,
            tax_amount,
            total,
            amount_paid,

            0 AS is_voided,

            created_at,
            updated_at

          FROM bills

          WHERE id = ?

          LIMIT 1
          `,
          [
            billId,
          ]
        );

      const [savedItems] =
        await db.query(
          `
          SELECT
            id,
            bill_id,

            source_type,

            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM bill_items

          WHERE bill_id = ?

          ORDER BY id ASC
          `,
          [
            billId,
          ]
        );

      return res
        .status(201)
        .json({
          success: true,

          message:
            'Bill created successfully',

          data:
            mapBill(
              savedRows[0],

              savedItems.map(
                mapBillItem
              )
            ),
        });
    } catch (error) {
      if (connection) {
        try {
          await connection
            .rollback();
        } catch (_) {}
      }

      console.error(
        'Create bill error:',
        error
      );

      if (
        error.code ===
        'ER_DUP_ENTRY'
      ) {
        return res
          .status(409)
          .json({
            success: false,

            message:
              'Bill number already exists',
          });
      }

      if (
        error.statusCode
      ) {
        return res
          .status(
            error.statusCode
          )
          .json({
            success: false,

            message:
              error.message,
          });
      }

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to create bill',

          error:
            error.message,
        });
    } finally {
      if (connection) {
        connection.release();
      }
    }
  }
);

// ============================================================
// UPDATE BILL
//
// PUT /api/bills/:id
// ============================================================

router.put(
  '/:id',
  async (req, res) => {
    let connection;
    let transactionStarted = false;

    try {
      const { id } = req.params;
      const {
        vendorInvoiceNumber,
        invoiceAttachmentPath,
        vendorId,
        billDate,
        dueDate,
        items,
        taxAmount,
      } = req.body;
      const parsedVendorId = Number(vendorId);
      const finalBillDate = normalizeDate(billDate);

      if (!Number.isInteger(parsedVendorId) || parsedVendorId <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Please select a valid vendor',
        });
      }
      if (!finalBillDate) {
        return res.status(400).json({
          success: false,
          message: 'Bill date is required',
        });
      }
      if (!Array.isArray(items) || items.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'At least one item is required',
        });
      }

      connection = await db.getConnection();
      await connection.beginTransaction();
      transactionStarted = true;

      const [existingRows] = await connection.query(
        `
        SELECT
          id,
          vendor_id,
          purchase_order_id,
          purchase_order_number,
          amount_paid,
          total,
          EXISTS (
            SELECT 1
            FROM bill_voids
            WHERE bill_voids.bill_id = CAST(bills.id AS CHAR)
          ) AS is_voided
        FROM bills
        WHERE id = ?
        LIMIT 1
        FOR UPDATE
        `,
        [id]
      );

      if (existingRows.length === 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(404).json({
          success: false,
          message: 'Bill not found',
        });
      }
      const existing = existingRows[0];
      if (
        existing.is_voided === true ||
        existing.is_voided === 1 ||
        existing.is_voided === '1'
      ) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(409).json({
          success: false,
          message: 'Voided bills cannot be edited',
        });
      }

      const [vendorRows] = await connection.query(
        `
        SELECT id, display_name
        FROM vendors
        WHERE id = ?
        LIMIT 1
        `,
        [parsedVendorId]
      );
      if (vendorRows.length === 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(404).json({
          success: false,
          message: 'Selected vendor not found',
        });
      }

      const preparedItems = [];
      let calculatedSubTotal = 0;
      for (const line of items) {
        const itemName = line.itemName?.toString().trim() ?? '';
        if (!itemName) {
          await connection.rollback();
          transactionStarted = false;
          return res.status(400).json({
            success: false,
            message: 'Every bill row must have an item',
          });
        }

        const qty = toNumber(line.qty);
        const rate = toNumber(line.rate);
        if (qty <= 0 || rate < 0) {
          await connection.rollback();
          transactionStarted = false;
          return res.status(400).json({
            success: false,
            message: `Invalid quantity or rate for "${itemName}"`,
          });
        }

        const product = await resolveCatalogProduct(
          connection,
          itemName,
          rate
        );
        const amount = Number((qty * rate).toFixed(2));
        calculatedSubTotal += amount;
        preparedItems.push({
          sourceType: product.sourceType,
          itemId: product.itemId,
          partId: product.partId,
          itemName: product.name,
          description:
            line.description?.toString().trim() ||
            product.description ||
            '',
          qty,
          rate,
          amount,
        });
      }

      calculatedSubTotal = Number(calculatedSubTotal.toFixed(2));
      const finalTaxAmount = toNumber(taxAmount);
      if (finalTaxAmount < 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(400).json({
          success: false,
          message: 'Tax cannot be negative',
        });
      }
      const calculatedTotal = Number(
        (calculatedSubTotal + finalTaxAmount).toFixed(2)
      );
      if (calculatedTotal < toNumber(existing.amount_paid)) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(400).json({
          success: false,
          message: 'Bill total cannot be less than the amount already paid',
        });
      }

      const keepPurchaseOrder =
        Number(existing.vendor_id) === parsedVendorId;
      await connection.query(
        `
        UPDATE bills
        SET
          vendor_invoice_number = ?,
          invoice_attachment_path = ?,
          vendor_id = ?,
          vendor_name = ?,
          purchase_order_id = ?,
          purchase_order_number = ?,
          bill_date = ?,
          due_date = ?,
          sub_total = ?,
          tax_amount = ?,
          total = ?
        WHERE id = ?
        `,
        [
          vendorInvoiceNumber?.toString().trim() || null,
          invoiceAttachmentPath?.toString().trim() || null,
          parsedVendorId,
          vendorRows[0].display_name,
          keepPurchaseOrder ? existing.purchase_order_id : null,
          keepPurchaseOrder ? existing.purchase_order_number : null,
          finalBillDate,
          normalizeDate(dueDate),
          calculatedSubTotal,
          finalTaxAmount,
          calculatedTotal,
          id,
        ]
      );

      await connection.query(
        'DELETE FROM bill_items WHERE bill_id = ?',
        [id]
      );
      for (const line of preparedItems) {
        await connection.query(
          `
          INSERT INTO bill_items (
            bill_id,
            source_type,
            item_id,
            part_id,
            item_name,
            description,
            qty,
            rate,
            amount
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          `,
          [
            id,
            line.sourceType,
            line.itemId,
            line.partId,
            line.itemName,
            line.description || null,
            line.qty,
            line.rate,
            line.amount,
          ]
        );
      }

      await connection.commit();
      transactionStarted = false;

      const [savedRows] = await db.query(
        `
        SELECT
          bills.id,
          bills.bill_number,
          bills.vendor_invoice_number,
          bills.invoice_attachment_path,
          bills.vendor_id,
          bills.vendor_name,
          bills.purchase_order_id,
          bills.purchase_order_number,
          DATE_FORMAT(bills.bill_date, '%Y-%m-%d') AS bill_date,
          CASE
            WHEN bills.due_date IS NULL THEN NULL
            ELSE DATE_FORMAT(bills.due_date, '%Y-%m-%d')
          END AS due_date,
          bills.sub_total,
          bills.tax_amount,
          bills.total,
          bills.amount_paid,
          0 AS is_voided,
          bills.created_at,
          bills.updated_at
        FROM bills
        WHERE bills.id = ?
        LIMIT 1
        `,
        [id]
      );
      const [savedItems] = await db.query(
        `
        SELECT
          id,
          bill_id,
          source_type,
          item_id,
          part_id,
          item_name,
          description,
          qty,
          rate,
          amount
        FROM bill_items
        WHERE bill_id = ?
        ORDER BY id ASC
        `,
        [id]
      );

      return res.status(200).json({
        success: true,
        message: 'Bill updated successfully',
        data: mapBill(savedRows[0], savedItems.map(mapBillItem)),
      });
    } catch (error) {
      if (connection && transactionStarted) {
        await connection.rollback();
      }
      console.error('Update bill error:', error);
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Failed to update bill',
        error: error.message,
      });
    } finally {
      if (connection) connection.release();
    }
  }
);

// ============================================================
// RECORD PAYMENT
//
// PUT /api/bills/:id/payment
//
// body:
// {
//   "amountPaid": 1000
// }
//
// This amount is ADDED to existing amount_paid.
// ============================================================

router.put(
  '/:id/payment',
  async (req, res) => {
    let connection;
    let transactionStarted = false;

    try {
      const {
        id,
      } = req.params;

      const payment =
        Number(
          toNumber(
            req.body.amountPaid
          ).toFixed(2)
        );

      const paymentDate =
        normalizeDate(req.body.paymentDate) ??
        new Date().toISOString().substring(0, 10);

      const paymentMode =
        req.body.paymentMode
          ?.toString()
          .trim() ?? '';

      const reference =
        req.body.reference
          ?.toString()
          .trim() ?? '';

      const paidBy =
        req.body.paidBy
          ?.toString()
          .trim() ?? '';

      const notes =
        req.body.notes
          ?.toString()
          .trim() ?? '';

      if (
        payment <= 0
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Payment amount must be greater than zero',
          });
      }

      const dateParts =
        /^(\d{4})-(\d{2})-(\d{2})$/.exec(paymentDate);
      const parsedPaymentDate = dateParts
        ? new Date(`${paymentDate}T00:00:00.000Z`)
        : null;

      if (
        !parsedPaymentDate ||
        Number.isNaN(parsedPaymentDate.getTime()) ||
        parsedPaymentDate
          .toISOString()
          .substring(0, 10) !== paymentDate
      ) {
        return res.status(400).json({
          success: false,
          message: 'A valid payment date is required',
        });
      }

      if (!paymentMode || paymentMode.length > 60) {
        return res.status(400).json({
          success: false,
          message: 'A valid payment mode is required',
        });
      }

      if (reference.length > 255) {
        return res.status(400).json({
          success: false,
          message: 'Payment reference cannot exceed 255 characters',
        });
      }

      if (paidBy.length > 255 || notes.length > 2000) {
        return res.status(400).json({
          success: false,
          message: 'Paid By must be 255 characters or fewer and Notes must be 2000 characters or fewer',
        });
      }

      connection = await db.getConnection();
      await connection.beginTransaction();
      transactionStarted = true;

      const [billRows] =
        await connection.query(
          `
          SELECT
            bills.id,
            bills.total,
            bills.amount_paid,
            EXISTS (
              SELECT 1
              FROM bill_voids
              WHERE bill_voids.bill_id = CAST(bills.id AS CHAR)
            ) AS is_voided

          FROM bills

          WHERE bills.id = ?

          LIMIT 1
          FOR UPDATE
          `,
          [
            id,
          ]
        );

      if (
        billRows.length === 0
      ) {
        await connection.rollback();
        transactionStarted = false;
        return res
          .status(404)
          .json({
            success: false,

            message:
              'Bill not found',
          });
      }

      if (
        billRows[0].is_voided === true ||
        billRows[0].is_voided === 1 ||
        billRows[0].is_voided === '1'
      ) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(409).json({
          success: false,
          message: 'A voided bill cannot receive payments',
        });
      }

      const currentAmountPaid =
        toNumber(
          billRows[0]
            .amount_paid
        );

      const total =
        toNumber(
          billRows[0]
            .total
        );

      const amountDue = Number(
        (total - currentAmountPaid).toFixed(2)
      );

      if (payment > amountDue) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(400).json({
          success: false,
          message: 'Payment amount cannot exceed the amount due',
        });
      }

      const newAmountPaid = Number(
        (currentAmountPaid + payment).toFixed(2)
      );

      await connection.query(
        `
        INSERT INTO bill_payments (
          bill_id,
          amount,
          payment_date,
          payment_mode,
          reference_number,
          paid_by,
          notes
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        `,
        [
          id.toString(),
          payment,
          paymentDate,
          paymentMode,
          reference || null,
          paidBy || null,
          notes || null,
        ]
      );

      await connection.query(
        `
        UPDATE bills

        SET amount_paid = ?

        WHERE id = ?
        `,
        [
          newAmountPaid,

          id,
        ]
      );

      await connection.commit();
      transactionStarted = false;

      const [updatedRows] =
        await db.query(
          `
          SELECT
            id,

            bill_number,

            vendor_invoice_number,
            invoice_attachment_path,

            vendor_id,
            vendor_name,

            purchase_order_id,
            purchase_order_number,

            DATE_FORMAT(
              bill_date,
              '%Y-%m-%d'
            ) AS bill_date,

            CASE
              WHEN due_date
                IS NULL
                THEN NULL

              ELSE DATE_FORMAT(
                due_date,
                '%Y-%m-%d'
              )
            END AS due_date,

            sub_total,
            tax_amount,
            total,
            amount_paid,

            EXISTS (
              SELECT 1
              FROM bill_voids
              WHERE bill_voids.bill_id = CAST(bills.id AS CHAR)
            ) AS is_voided,

            created_at,
            updated_at

          FROM bills

          WHERE bills.id = ?

          LIMIT 1
          `,
          [
            id,
          ]
        );

      const [itemRows] =
        await db.query(
          `
          SELECT
            id,
            bill_id,

            source_type,

            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM bill_items

          WHERE bill_id = ?

          ORDER BY id ASC
          `,
          [
            id,
          ]
        );

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Payment recorded successfully',

          data:
            mapBill(
              updatedRows[0],

              itemRows.map(
                mapBillItem
              )
            ),
        });
    } catch (error) {
      if (transactionStarted && connection) {
        await connection.rollback();
      }

      console.error(
        'Record bill payment error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to record payment',

          error:
            error.message,
        });
    } finally {
      if (connection) connection.release();
    }
  }
);

// ============================================================
// VOID BILL
//
// POST /api/bills/:id/void
// ============================================================

router.post(
  '/:id/void',
  async (req, res) => {
    let connection;
    let transactionStarted = false;

    try {
      const { id } = req.params;
      connection = await db.getConnection();
      await connection.beginTransaction();
      transactionStarted = true;

      const [billRows] = await connection.query(
        `
        SELECT id
        FROM bills
        WHERE id = ?
        LIMIT 1
        FOR UPDATE
        `,
        [id]
      );

      if (billRows.length === 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(404).json({
          success: false,
          message: 'Bill not found',
        });
      }

      await connection.query(
        `
        INSERT IGNORE INTO bill_voids (bill_id)
        VALUES (?)
        `,
        [id.toString()]
      );

      await connection.commit();
      transactionStarted = false;

      const [updatedRows] = await db.query(
        `
        SELECT
          bills.id,
          bills.bill_number,
          bills.vendor_invoice_number,
          bills.invoice_attachment_path,
          bills.vendor_id,
          bills.vendor_name,
          bills.purchase_order_id,
          bills.purchase_order_number,
          DATE_FORMAT(bills.bill_date, '%Y-%m-%d') AS bill_date,
          CASE
            WHEN bills.due_date IS NULL THEN NULL
            ELSE DATE_FORMAT(bills.due_date, '%Y-%m-%d')
          END AS due_date,
          bills.sub_total,
          bills.tax_amount,
          bills.total,
          bills.amount_paid,
          EXISTS (
            SELECT 1
            FROM bill_voids
            WHERE bill_voids.bill_id = CAST(bills.id AS CHAR)
          ) AS is_voided,
          bills.created_at,
          bills.updated_at
        FROM bills
        WHERE bills.id = ?
        LIMIT 1
        `,
        [id]
      );

      const [itemRows] = await db.query(
        `
        SELECT
          id,
          bill_id,
          source_type,
          item_id,
          part_id,
          item_name,
          description,
          qty,
          rate,
          amount
        FROM bill_items
        WHERE bill_id = ?
        ORDER BY id ASC
        `,
        [id]
      );

      return res.status(200).json({
        success: true,
        message: 'Bill voided successfully',
        data: mapBill(updatedRows[0], itemRows.map(mapBillItem)),
      });
    } catch (error) {
      if (connection && transactionStarted) {
        await connection.rollback();
      }

      console.error('Void bill error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to void bill',
        error: error.message,
      });
    } finally {
      if (connection) connection.release();
    }
  }
);

// ============================================================
// DELETE BILL
//
// DELETE /api/bills/:id
// ============================================================

router.delete(
  '/:id',
  async (req, res) => {
    let connection;
    let transactionStarted = false;

    try {
      const {
        id,
      } = req.params;

      connection = await db.getConnection();
      await connection.beginTransaction();
      transactionStarted = true;

      await connection.query(
        `
        DELETE FROM bill_payments
        WHERE bill_id = ?
        `,
        [id.toString()]
      );

      await connection.query(
        `
        DELETE FROM bill_voids
        WHERE bill_id = ?
        `,
        [id.toString()]
      );

      const [result] =
        await connection.query(
          `
          DELETE FROM bills

          WHERE id = ?
          `,
          [
            id,
          ]
        );

      if (
        result.affectedRows === 0
      ) {
        await connection.rollback();
        transactionStarted = false;
        return res
          .status(404)
          .json({
            success: false,

            message:
              'Bill not found',
          });
      }

      await connection.commit();
      transactionStarted = false;

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Bill deleted successfully',
        });
    } catch (error) {
        if (connection && transactionStarted) {
          await connection.rollback();
        }

        console.error(
        'Delete bill error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to delete bill',

          error:
            error.message,
        });
    } finally {
      if (connection) connection.release();
    }
  }
);

module.exports = router;