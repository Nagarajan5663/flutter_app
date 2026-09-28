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

        dateFrom,
        dateTo,

        date_from,
        date_to,
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

          created_at,
          updated_at

        FROM bills

        WHERE 1 = 1
      `;

      const values = [];

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
              po_number

            FROM purchase_orders

            WHERE id = ?

            LIMIT 1
            `,
            [
              parsedPoId,
            ]
          );

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
          parsedPoId;

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
    try {
      const {
        id,
      } = req.params;

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

      const [billRows] =
        await db.query(
          `
          SELECT
            id,
            total,
            amount_paid

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

      const newAmountPaid =
        Math.min(
          total,

          Number(
            (
              currentAmountPaid +
              payment
            ).toFixed(2)
          )
        );

      await db.query(
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
      const {
        id,
      } = req.params;

      const [result] =
        await db.query(
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
        return res
          .status(404)
          .json({
            success: false,

            message:
              'Bill not found',
          });
      }

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Bill deleted successfully',
        });
    } catch (error) {
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
    }
  }
);

module.exports = router;