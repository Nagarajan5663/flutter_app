const express = require('express');
const db = require('../config/db');

const router = express.Router();

// ============================================================
// HELPERS
// ============================================================

function toNumber(value, fallback = 0) {
  const number = Number(value);

  return Number.isFinite(number)
    ? number
    : fallback;
}

function normalizeDate(value) {
  if (!value) {
    return null;
  }

  const text = value
    .toString()
    .trim();

  if (!text) {
    return null;
  }

  return text.length >= 10
    ? text.substring(0, 10)
    : text;
}

function calculateStatus(
  total,
  amountPaid
) {
  const finalTotal =
    toNumber(total);

  const paid =
    toNumber(amountPaid);

  if (paid <= 0) {
    return 'Unpaid';
  }

  if (paid >= finalTotal) {
    return 'Paid';
  }

  return 'Partially Paid';
}

function mapBillItem(row) {
  return {
    id:
      row.id?.toString() ??
      null,

    billId:
      row.bill_id
          ?.toString() ??
      '',

    sourceType:
      row.source_type ?? '',

    itemId:
      row.item_id == null
        ? null
        : row.item_id.toString(),

    partId:
      row.part_id == null
        ? null
        : row.part_id.toString(),

    itemName:
      row.item_name ?? '',

    description:
      row.description ?? '',

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
      row.id?.toString() ??
      null,

    billNumber:
      row.bill_number ?? '',

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
      row.vendor_name ?? '',

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
      row.bill_date ?? '',

    dueDate:
      row.due_date ?? null,

    items,

    subTotal:
      toNumber(
        row.sub_total
      ),

    taxAmount:
      toNumber(
        row.tax_amount
      ),

    total:
      toNumber(
        row.total
      ),

    amountPaid:
      toNumber(
        row.amount_paid
      ),

    amountDue:
      Math.max(
        0,
        toNumber(row.total) -
            toNumber(
              row.amount_paid
            )
      ),

    status:
      row.status ??
      calculateStatus(
        row.total,
        row.amount_paid
      ),

    createdAt:
      row.created_at ?? null,

    updatedAt:
      row.updated_at ?? null,
  };
}

// ============================================================
// CURRENT PURCHASE ITEM MODEL ONLY SENDS:
//
// itemName
// description
// qty
// rate
//
// So resolve actual Item / Part from DB by exact name.
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

    error.statusCode = 400;

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
      [name]
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
      [name]
    );

  const candidates = [];

  for (const row of itemRows) {
    candidates.push({
      sourceType:
        'Item',

      itemId:
        Number(row.id),

      partId:
        null,

      name:
        row.name,

      description:
        row.description ?? '',

      purchasePrice:
        toNumber(
          row.purchase_price
        ),
    });
  }

  for (const row of partRows) {
    candidates.push({
      sourceType:
        'Part',

      itemId:
        null,

      partId:
        Number(row.id),

      name:
        row.name,

      description:
        row.description ?? '',

      purchasePrice:
        toNumber(
          row.purchase_price
        ),
    });
  }

  if (candidates.length === 0) {
    const error =
      new Error(
        `Selected item "${name}" was not found in Items or Parts`
      );

    error.statusCode = 404;

    throw error;
  }

  if (candidates.length === 1) {
    return candidates[0];
  }

  // Same name exists in Items and Parts.
  // Use purchase price to identify the selected one.

  const matchingRate =
    candidates.filter(
      (candidate) =>
        Math.abs(
          candidate.purchasePrice -
            rate
        ) < 0.005
    );

  if (matchingRate.length === 1) {
    return matchingRate[0];
  }

  const error =
    new Error(
      `More than one Item/Part uses the name "${name}". Please keep Item/Part names unique.`
    );

  error.statusCode = 400;

  throw error;
}

// ============================================================
// GET NEXT BILL NUMBER
//
// GET /api/bills/next-number
// ============================================================

router.get(
  '/next-number',
  async (req, res) => {
    try {
      const [rows] =
        await db.query(
          `
          SELECT
            MAX(
              CAST(
                SUBSTRING(
                  bill_number,
                  6
                )
                AS UNSIGNED
              )
            ) AS max_number

          FROM bills

          WHERE bill_number
            LIKE 'BILL-%'
          `
        );

      const maxNumber =
        Number(
          rows[0]
              ?.max_number ??
            0
        );

      res.status(200).json({
        success: true,

        data: {
          billNumber:
            `BILL-${maxNumber + 1}`,
        },
      });
    } catch (error) {
      console.error(
        'Get next bill number error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to generate bill number',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// GET ALL BILLS
//
// GET /api/bills
//
// Filters:
// status_filter
// vendor_filter
// date_from
// date_to
// ============================================================

router.get(
  '/',
  async (req, res) => {
    try {
      const {
        status_filter,
        vendor_filter,
        date_from,
        date_to,
      } = req.query;

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
            WHEN due_date IS NULL
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
          status,

          created_at,
          updated_at

        FROM bills

        WHERE 1 = 1
      `;

      const values = [];

      // --------------------------------------------------------
      // STATUS FILTER
      // --------------------------------------------------------

      if (
        status_filter &&
        status_filter !== 'All'
      ) {
        sql += `
          AND status = ?
        `;

        values.push(
          status_filter
        );
      }

      // --------------------------------------------------------
      // VENDOR FILTER
      // --------------------------------------------------------

      if (
        vendor_filter &&
        vendor_filter
            .trim() !== ''
      ) {
        sql += `
          AND vendor_name LIKE ?
        `;

        values.push(
          `%${vendor_filter.trim()}%`
        );
      }

      // --------------------------------------------------------
      // DATE FROM
      // --------------------------------------------------------

      const dateFrom =
        normalizeDate(
          date_from
        );

      if (dateFrom) {
        sql += `
          AND bill_date >= ?
        `;

        values.push(
          dateFrom
        );
      }

      // --------------------------------------------------------
      // DATE TO
      // --------------------------------------------------------

      const dateTo =
        normalizeDate(
          date_to
        );

      if (dateTo) {
        sql += `
          AND bill_date <= ?
        `;

        values.push(
          dateTo
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

      // --------------------------------------------------------
      // LOAD ITEMS FOR ALL BILLS
      //
      // Flutter BillModel calculates total from its items,
      // therefore GET needs to include line items.
      // --------------------------------------------------------

      const ids =
        billRows.map(
          (row) =>
            Number(row.id)
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

          WHERE bill_id IN (
            ${placeholders}
          )

          ORDER BY
            bill_id ASC,
            id ASC
          `,
          ids
        );

      const groupedItems = {};

      for (const row of itemRows) {
        const billId =
          Number(
            row.bill_id
          );

        if (
          !groupedItems[billId]
        ) {
          groupedItems[billId] = [];
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
            const billId =
              Number(row.id);

            return mapBill(
              row,

              groupedItems[
                billId
              ] ?? []
            );
          }
        );

      res.status(200).json({
        success: true,

        data,
      });
    } catch (error) {
      console.error(
        'Get bills error:',
        error
      );

      res.status(500).json({
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
// GET SINGLE BILL
//
// GET /api/bills/:id
// ============================================================

router.get(
  '/:id',
  async (req, res) => {
    try {
      const { id } =
        req.params;

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
              WHEN due_date IS NULL
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
            status,

            created_at,
            updated_at

          FROM bills

          WHERE id = ?

          LIMIT 1
          `,
          [id]
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
          [id]
        );

      res.status(200).json({
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

      res.status(500).json({
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
      // BILL NUMBER
      // --------------------------------------------------------

      if (
        !billNumber ||
        billNumber
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

      // --------------------------------------------------------
      // VENDOR
      // --------------------------------------------------------

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

      // --------------------------------------------------------
      // DATE
      // --------------------------------------------------------

      const finalBillDate =
        normalizeDate(
          billDate
        );

      if (!finalBillDate) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Bill date is required',
          });
      }

      // --------------------------------------------------------
      // ITEMS
      // --------------------------------------------------------

      if (
        !Array.isArray(items) ||
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
      // LOAD VENDOR FROM DB
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
            parsedVendorId
          ]
        );

      if (
        vendorRows.length === 0
      ) {
        await connection.rollback();

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
        purchaseOrderId != null &&
        Number(
          purchaseOrderId
        ) > 0
      ) {
        const parsedPoId =
          Number(
            purchaseOrderId
          );

        const [poRows] =
          await connection.query(
            `
            SELECT
              id,
              po_number,
              vendor_id

            FROM purchase_orders

            WHERE id = ?

            LIMIT 1
            `,
            [parsedPoId]
          );

        if (
          poRows.length === 0
        ) {
          await connection.rollback();

          return res
            .status(404)
            .json({
              success: false,

              message:
                'Selected purchase order not found',
            });
        }

        if (
          Number(
            poRows[0].vendor_id
          ) !==
          parsedVendorId
        ) {
          await connection.rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                'Purchase order does not belong to selected vendor',
            });
        }

        finalPurchaseOrderId =
          parsedPoId;

        finalPurchaseOrderNumber =
          poRows[0]
            .po_number;
      }

      // --------------------------------------------------------
      // PREPARE ITEMS
      // --------------------------------------------------------

      const preparedItems = [];

      let subTotal = 0;

      for (
        const line
        of items
      ) {
        const itemName =
          line.itemName
            ?.toString()
            .trim() ??
          '';

        if (!itemName) {
          await connection.rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                'Every bill row must contain an item',
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

        if (qty <= 0) {
          await connection.rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                `Quantity for "${itemName}" must be greater than zero`,
            });
        }

        if (rate < 0) {
          await connection.rollback();

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

        subTotal +=
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

      subTotal =
        Number(
          subTotal
            .toFixed(2)
        );

      // --------------------------------------------------------
      // TAX / TOTAL
      // --------------------------------------------------------

      const finalTaxAmount =
        toNumber(
          taxAmount
        );

      if (
        finalTaxAmount < 0
      ) {
        await connection.rollback();

        return res
          .status(400)
          .json({
            success: false,

            message:
              'Tax cannot be negative',
          });
      }

      const total =
        Number(
          (
            subTotal +
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

      if (
        finalAmountPaid >
        total
      ) {
        await connection.rollback();

        return res
          .status(400)
          .json({
            success: false,

            message:
              'Amount paid cannot be greater than bill total',
          });
      }

      const status =
        calculateStatus(
          total,
          finalAmountPaid
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

            amount_paid,
            status
          )
          VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
          )
          `,
          [
            billNumber.trim(),

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

            subTotal,

            finalTaxAmount,

            total,

            finalAmountPaid,

            status,
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

      await connection.commit();

      // --------------------------------------------------------
      // FETCH SAVED BILL
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
              WHEN due_date IS NULL
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
            status,

            created_at,
            updated_at

          FROM bills

          WHERE id = ?

          LIMIT 1
          `,
          [billId]
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
          [billId]
        );

      res.status(201).json({
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

      res.status(500).json({
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
// RECORD PAYMENT
//
// PUT /api/bills/:id/payment
//
// Body:
// {
//   "amountPaid": 1000
// }
//
// amountPaid here means NEW payment amount.
// It gets added to existing amount_paid.
// ============================================================

router.put(
  '/:id/payment',
  async (req, res) => {
    let connection;

    try {
      const { id } =
        req.params;

      const payment =
        toNumber(
          req.body.amountPaid
        );

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

      connection =
        await db.getConnection();

      await connection
        .beginTransaction();

      const [rows] =
        await connection.query(
          `
          SELECT
            id,
            total,
            amount_paid

          FROM bills

          WHERE id = ?

          FOR UPDATE
          `,
          [id]
        );

      if (
        rows.length === 0
      ) {
        await connection.rollback();

        return res
          .status(404)
          .json({
            success: false,

            message:
              'Bill not found',
          });
      }

      const total =
        toNumber(
          rows[0].total
        );

      const currentPaid =
        toNumber(
          rows[0]
            .amount_paid
        );

      const amountDue =
        Math.max(
          0,
          total -
            currentPaid
        );

      if (
        amountDue <= 0
      ) {
        await connection.rollback();

        return res
          .status(400)
          .json({
            success: false,

            message:
              'This bill is already fully paid',
          });
      }

      if (
        payment >
        amountDue
      ) {
        await connection.rollback();

        return res
          .status(400)
          .json({
            success: false,

            message:
              `Payment cannot exceed amount due (${amountDue.toFixed(2)})`,
          });
      }

      const newAmountPaid =
        Number(
          (
            currentPaid +
            payment
          ).toFixed(2)
        );

      const newStatus =
        calculateStatus(
          total,
          newAmountPaid
        );

      await connection.query(
        `
        UPDATE bills

        SET
          amount_paid = ?,
          status = ?

        WHERE id = ?
        `,
        [
          newAmountPaid,
          newStatus,
          id,
        ]
      );

      await connection.commit();

      // --------------------------------------------------------
      // Return updated bill
      // --------------------------------------------------------

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
              WHEN due_date IS NULL
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
            status,

            created_at,
            updated_at

          FROM bills

          WHERE id = ?

          LIMIT 1
          `,
          [id]
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
          [id]
        );

      res.status(200).json({
        success: true,

        message:
          'Payment recorded successfully',

        data:
          mapBill(
            billRows[0],

            itemRows.map(
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
        'Record bill payment error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to record payment',

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
// DELETE BILL
//
// DELETE /api/bills/:id
// ============================================================

router.delete(
  '/:id',
  async (req, res) => {
    try {
      const { id } =
        req.params;

      const [result] =
        await db.query(
          `
          DELETE FROM bills

          WHERE id = ?
          `,
          [id]
        );

      if (
        result.affectedRows === 0
      ) {
        return res
          .status(404)
          .json({
            success: false,

            message:
              'Bill not found',
          });
      }

      res.status(200).json({
        success: true,

        message:
          'Bill deleted successfully',
      });
    } catch (error) {
      console.error(
        'Delete bill error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to delete bill',

        error:
          error.message,
      });
    }
  }
);

module.exports = router;