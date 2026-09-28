const express = require('express');
const db = require('../config/db');

const router = express.Router();

const ALLOWED_STATUSES = [
  'Draft',
  'Ordered',
  'Received',
  'Cancelled',
];

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

  const text = value.toString().trim();

  if (!text) {
    return null;
  }

  return text.length >= 10
    ? text.substring(0, 10)
    : text;
}

function mapPurchaseOrderItem(row) {
  return {
    id:
      row.id?.toString() ?? null,

    purchaseOrderId:
      row.purchase_order_id
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
      toNumber(row.qty),

    rate:
      toNumber(row.rate),

    amount:
      toNumber(row.amount),
  };
}

function mapPurchaseOrder(
  row,
  items = [],
) {
  return {
    id:
      row.id?.toString() ?? null,

    poNumber:
      row.po_number ?? '',

    vendorId:
      row.vendor_id
          ?.toString() ??
      '',

    vendorName:
      row.vendor_name ?? '',

    date:
      row.order_date ?? '',

    deliveryExpectedDate:
      row.delivery_expected_date ??
      null,

    paymentTerms:
      row.payment_terms ?? '',

    dueDate:
      row.due_date ?? null,

    referenceNumber:
      row.reference_number ?? '',

    subTotal:
      toNumber(
        row.sub_total,
      ),

    total:
      toNumber(
        row.total,
      ),

    items,

    status:
      row.status ?? 'Draft',

    createdAt:
      row.created_at ?? null,

    updatedAt:
      row.updated_at ?? null,
  };
}

// ============================================================
// RESOLVE EXISTING ITEM / PART
//
// Current Flutter PurchaseOrderItemModel does not contain
// itemId / partId / sourceType.
//
// Therefore we resolve the selected saved product by its exact
// item name.
//
// If the same name exists in BOTH items and parts, purchase price
// is also used to distinguish them.
// ============================================================

async function resolveCatalogProduct(
  connection,
  itemName,
  rate
) {
  const name =
    itemName?.trim() ?? '';

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

      purchasePrice:
        toNumber(
          row.purchase_price
        ),

      description:
        row.description ?? '',
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

      purchasePrice:
        toNumber(
          row.purchase_price
        ),

      description:
        row.description ?? '',
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

  // ----------------------------------------------------------
  // Same name found more than once.
  // Try purchase price to identify the selected record.
  // ----------------------------------------------------------

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
      `More than one Item/Part uses the name "${name}". Please use unique Item/Part names.`
    );

  error.statusCode = 400;

  throw error;
}

// ============================================================
// NEXT PO NUMBER
//
// GET /api/purchase-orders/next-number
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
                  po_number,
                  4
                )
                AS UNSIGNED
              )
            ) AS max_number

          FROM purchase_orders

          WHERE po_number
            LIKE 'PO-%'
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
          poNumber:
            `PO-${maxNumber + 1}`,
        },
      });
    } catch (error) {
      console.error(
        'Get next PO number error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to generate purchase order number',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// GET ALL PURCHASE ORDERS
//
// GET /api/purchase-orders
//
// Supports existing PurchaseOrderFilter:
//
// status_filter
// vendor_filter
// reference_filter
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
        reference_filter,
        date_from,
        date_to,
      } = req.query;

      let sql = `
        SELECT
          id,
          po_number,

          vendor_id,
          vendor_name,

          DATE_FORMAT(
            order_date,
            '%Y-%m-%d'
          ) AS order_date,

          CASE
            WHEN delivery_expected_date
              IS NULL
              THEN NULL
            ELSE DATE_FORMAT(
              delivery_expected_date,
              '%Y-%m-%d'
            )
          END AS delivery_expected_date,

          payment_terms,

          CASE
            WHEN due_date
              IS NULL
              THEN NULL
            ELSE DATE_FORMAT(
              due_date,
              '%Y-%m-%d'
            )
          END AS due_date,

          reference_number,

          sub_total,
          total,

          status,

          created_at,
          updated_at

        FROM purchase_orders

        WHERE 1 = 1
      `;

      const values = [];

      // --------------------------------------------------------
      // STATUS
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
      // VENDOR
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
      // REFERENCE
      // --------------------------------------------------------

      if (
        reference_filter &&
        reference_filter
            .trim() !== ''
      ) {
        sql += `
          AND reference_number
            LIKE ?
        `;

        values.push(
          `%${reference_filter.trim()}%`
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
          AND order_date >= ?
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
          AND order_date <= ?
        `;

        values.push(
          dateTo
        );
      }

      sql += `
        ORDER BY id DESC
      `;

      const [orderRows] =
        await db.query(
          sql,
          values
        );

      if (
        orderRows.length === 0
      ) {
        return res
            .status(200)
            .json({
          success: true,
          data: [],
        });
      }

      // --------------------------------------------------------
      // Load all line items too.
      //
      // This is important because your current Flutter
      // PurchaseOrderModel calculates total from items.
      // --------------------------------------------------------

      const ids =
        orderRows.map(
          (row) =>
            Number(row.id)
        );

      const placeholders =
        ids.map(
          () => '?'
        ).join(',');

      const [itemRows] =
        await db.query(
          `
          SELECT
            id,
            purchase_order_id,

            source_type,
            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM purchase_order_items

          WHERE purchase_order_id
            IN (${placeholders})

          ORDER BY
            purchase_order_id ASC,
            id ASC
          `,
          ids
        );

      const groupedItems = {};

      for (const item of itemRows) {
        const orderId =
          Number(
            item.purchase_order_id
          );

        if (
          !groupedItems[orderId]
        ) {
          groupedItems[orderId] = [];
        }

        groupedItems[
          orderId
        ].push(
          mapPurchaseOrderItem(
            item
          )
        );
      }

      const data =
        orderRows.map(
          (order) => {
            const orderId =
              Number(order.id);

            return mapPurchaseOrder(
              order,

              groupedItems[
                orderId
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
        'Get purchase orders error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to fetch purchase orders',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// GET SINGLE PURCHASE ORDER
//
// GET /api/purchase-orders/:id
// ============================================================

router.get(
  '/:id',
  async (req, res) => {
    try {
      const { id } =
        req.params;

      const [orderRows] =
        await db.query(
          `
          SELECT
            id,
            po_number,

            vendor_id,
            vendor_name,

            DATE_FORMAT(
              order_date,
              '%Y-%m-%d'
            ) AS order_date,

            CASE
              WHEN delivery_expected_date
                IS NULL
                THEN NULL
              ELSE DATE_FORMAT(
                delivery_expected_date,
                '%Y-%m-%d'
              )
            END AS delivery_expected_date,

            payment_terms,

            CASE
              WHEN due_date
                IS NULL
                THEN NULL
              ELSE DATE_FORMAT(
                due_date,
                '%Y-%m-%d'
              )
            END AS due_date,

            reference_number,

            sub_total,
            total,

            status,

            created_at,
            updated_at

          FROM purchase_orders

          WHERE id = ?

          LIMIT 1
          `,
          [id]
        );

      if (
        orderRows.length === 0
      ) {
        return res
            .status(404)
            .json({
          success: false,

          message:
            'Purchase order not found',
        });
      }

      const [itemRows] =
        await db.query(
          `
          SELECT
            id,
            purchase_order_id,

            source_type,
            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM purchase_order_items

          WHERE purchase_order_id = ?

          ORDER BY id ASC
          `,
          [id]
        );

      res.status(200).json({
        success: true,

        data:
          mapPurchaseOrder(
            orderRows[0],

            itemRows.map(
              mapPurchaseOrderItem
            )
          ),
      });
    } catch (error) {
      console.error(
        'Get purchase order error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to fetch purchase order',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// CREATE PURCHASE ORDER
//
// POST /api/purchase-orders
// ============================================================

router.post(
  '/',
  async (req, res) => {
    let connection;

    try {
      const {
        poNumber,
        vendorId,

        date,

        deliveryExpectedDate,

        paymentTerms,

        dueDate,

        referenceNumber,

        items,
      } = req.body;

      // --------------------------------------------------------
      // PO NUMBER
      // --------------------------------------------------------

      if (
        !poNumber ||
        poNumber
            .trim() === ''
      ) {
        return res
            .status(400)
            .json({
          success: false,

          message:
            'Purchase order number is required',
        });
      }

      // --------------------------------------------------------
      // VENDOR
      // --------------------------------------------------------

      const parsedVendorId =
        Number(vendorId);

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

      const orderDate =
        normalizeDate(date);

      if (!orderDate) {
        return res
            .status(400)
            .json({
          success: false,

          message:
            'Purchase order date is required',
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
      // GET SAVED VENDOR
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
              'Every purchase order row must have an item',
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

        subTotal += amount;

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
          subTotal.toFixed(2)
        );

      const total =
        subTotal;

      // --------------------------------------------------------
      // INSERT PO
      // --------------------------------------------------------

      const [orderResult] =
        await connection.query(
          `
          INSERT INTO purchase_orders (
            po_number,

            vendor_id,
            vendor_name,

            order_date,

            delivery_expected_date,

            payment_terms,

            due_date,

            reference_number,

            sub_total,
            total,

            status
          )
          VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
          )
          `,
          [
            poNumber.trim(),

            parsedVendorId,

            vendor.display_name,

            orderDate,

            normalizeDate(
              deliveryExpectedDate
            ),

            paymentTerms &&
            paymentTerms
                .trim() !== ''
              ? paymentTerms.trim()
              : '100% Advance',

            normalizeDate(
              dueDate
            ),

            referenceNumber &&
            referenceNumber
                .trim() !== ''
              ? referenceNumber.trim()
              : null,

            subTotal,
            total,

            'Draft',
          ]
        );

      const purchaseOrderId =
        orderResult.insertId;

      // --------------------------------------------------------
      // INSERT PO ITEMS
      // --------------------------------------------------------

      for (
        const line
        of preparedItems
      ) {
        await connection.query(
          `
          INSERT INTO purchase_order_items (
            purchase_order_id,

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
            purchaseOrderId,

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
      // FETCH SAVED PO
      // --------------------------------------------------------

      const [savedRows] =
        await db.query(
          `
          SELECT
            id,
            po_number,

            vendor_id,
            vendor_name,

            DATE_FORMAT(
              order_date,
              '%Y-%m-%d'
            ) AS order_date,

            CASE
              WHEN delivery_expected_date
                IS NULL
                THEN NULL
              ELSE DATE_FORMAT(
                delivery_expected_date,
                '%Y-%m-%d'
              )
            END AS delivery_expected_date,

            payment_terms,

            CASE
              WHEN due_date
                IS NULL
                THEN NULL
              ELSE DATE_FORMAT(
                due_date,
                '%Y-%m-%d'
              )
            END AS due_date,

            reference_number,

            sub_total,
            total,

            status,

            created_at,
            updated_at

          FROM purchase_orders

          WHERE id = ?

          LIMIT 1
          `,
          [
            purchaseOrderId
          ]
        );

      const [savedItems] =
        await db.query(
          `
          SELECT
            id,
            purchase_order_id,

            source_type,
            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM purchase_order_items

          WHERE purchase_order_id = ?

          ORDER BY id ASC
          `,
          [
            purchaseOrderId
          ]
        );

      res.status(201).json({
        success: true,

        message:
          'Purchase order created successfully',

        data:
          mapPurchaseOrder(
            savedRows[0],

            savedItems.map(
              mapPurchaseOrderItem
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
        'Create purchase order error:',
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
            'Purchase order number already exists',
        });
      }

      if (error.statusCode) {
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
          'Failed to create purchase order',

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
// UPDATE STATUS
//
// PUT /api/purchase-orders/:id/status
// ============================================================

router.put(
  '/:id/status',
  async (req, res) => {
    try {
      const { id } =
        req.params;

      const { status } =
        req.body;

      if (
        !ALLOWED_STATUSES.includes(
          status
        )
      ) {
        return res
            .status(400)
            .json({
          success: false,

          message:
            'Invalid purchase order status',
        });
      }

      const [result] =
        await db.query(
          `
          UPDATE purchase_orders

          SET status = ?

          WHERE id = ?
          `,
          [
            status,
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
            'Purchase order not found',
        });
      }

      res.status(200).json({
        success: true,

        message:
          'Purchase order status updated successfully',
      });
    } catch (error) {
      console.error(
        'Update PO status error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to update purchase order status',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// DELETE PURCHASE ORDER
//
// purchase_order_items delete automatically because
// ON DELETE CASCADE.
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
          DELETE FROM purchase_orders

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
            'Purchase order not found',
        });
      }

      res.status(200).json({
        success: true,

        message:
          'Purchase order deleted successfully',
      });
    } catch (error) {
      console.error(
        'Delete purchase order error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to delete purchase order',

        error:
          error.message,
      });
    }
  }
);

module.exports = router;