const express = require('express');
const db = require('../config/db');

const {
  getNextTransactionNumber,
} = require('../utils/transaction_number');
const { requireSalesWorkflowUser } = require('../middleware/workflow_auth');

const router = express.Router();

const ALLOWED_STATUSES = [
  'Draft',
  'Sent',
  'Closed',
  'Ordered',
  'Received',
  'Cancelled',
];

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

function normalizeDate(
  value
) {
  if (!value) {
    return null;
  }

  const text =
    value
      .toString()
      .trim();

  if (!text) {
    return null;
  }

  return text.length >= 10
    ? text.substring(
        0,
        10
      )
    : text;
}

function mapPurchaseOrderItem(
  row
) {
  return {
    id:
      row.id
        ?.toString() ??
      null,

    purchaseOrderId:
      row.purchase_order_id
        ?.toString() ??
      '',

    sourceType:
      row.source_type ?? '',

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

function mapPurchaseOrder(
  row,
  items = []
) {
  return {
    id:
      row.id
        ?.toString() ??
      null,

    poNumber:
      row.po_number ?? '',

    salesOrderId: row.sales_order_id == null ? null : String(row.sales_order_id),
    salesOrderNumber: row.sales_order_number ?? null,

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
      row.reference_number ??
      '',

    subTotal:
      toNumber(
        row.sub_total
      ),

    total:
      toNumber(
        row.total
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
// RESOLVE ITEM / PART
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

  const candidates =
    [];

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
      `More than one Item/Part uses the name "${name}". Please use unique Item/Part names.`
    );

  error.statusCode =
    400;

  throw error;
}

// ============================================================
// NEXT PURCHASE ORDER NUMBER
// ============================================================

router.get(
  '/next-number',
  async (req, res) => {
    try {
      const result =
        await getNextTransactionNumber({
          module:
            'Purchase Order',

          table:
            'purchase_orders',

          numberColumn:
            'po_number',

          padding:
            4,
        });

      return res
        .status(200)
        .json({
          success: true,

          data: {
            poNumber:
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
        'Get next PO number error:',
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
            'Failed to generate purchase order number',
        });
    }
  }
);

// ============================================================
// GET ALL
// ============================================================

router.get(
  '/',
  async (req, res) => {
    try {
      const {
        status_filter,
        vendor_filter,
        vendor_id,
        reference_filter,
        date_from,
        date_to,
      } = req.query;

      let sql = `
        SELECT
          id,
          po_number,
          sales_order_id,
          sales_order_number,

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

      const values =
        [];

      if (
        status_filter &&
        status_filter !==
          'All'
      ) {
        sql += `
          AND status = ?
        `;

        values.push(
          status_filter
        );
      }

      if (
        vendor_filter &&
        vendor_filter
          .trim() !== ''
      ) {
        sql += `
          AND vendor_name
            LIKE ?
        `;

        values.push(
          `%${vendor_filter.trim()}%`
        );
      }

      if (vendor_id) {
        sql += `
          AND vendor_id = ?
        `;

        values.push(vendor_id);
      }

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

      const ids =
        orderRows.map(
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

      const groupedItems =
        {};

      for (
        const item
        of itemRows
      ) {
        const orderId =
          Number(
            item.purchase_order_id
          );

        if (
          !groupedItems[
            orderId
          ]
        ) {
          groupedItems[
            orderId
          ] = [];
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
              Number(
                order.id
              );

            return mapPurchaseOrder(
              order,

              groupedItems[
                orderId
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
        'Get purchase orders error:',
        error
      );

      return res
        .status(500)
        .json({
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
// GET SINGLE
// ============================================================

router.get(
  '/:id',
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      const [orderRows] =
        await db.query(
          `
          SELECT
            id,
            po_number,
            sales_order_id,
            sales_order_number,
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
            id,
          ]
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
          [
            id,
          ]
        );

      return res
        .status(200)
        .json({
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

      return res
        .status(500)
        .json({
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
// ============================================================

router.post('/from-sales-order/:salesOrderId', requireSalesWorkflowUser, async (req, res) => {
  const salesOrderId = Number(req.params.salesOrderId);
  const vendorId = Number(req.body?.vendorId);
  if (!Number.isInteger(salesOrderId) || salesOrderId <= 0) {
    return res.status(400).json({ success: false, message: 'Invalid Sales Order ID.' });
  }
  if (!Number.isInteger(vendorId) || vendorId <= 0) {
    return res.status(400).json({ success: false, message: 'Please select a valid vendor.' });
  }

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [orders] = await connection.query(`
      SELECT id,so_number,order_date,expected_shipment_date,sub_total,total,notes,status,approval_status
      FROM sales_orders WHERE id=? FOR UPDATE
    `, [salesOrderId]);
    if (!orders.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Sales Order not found.' });
    }
    const order = orders[0];
    if (order.approval_status !== 'Approved') {
      await connection.rollback();
      return res.status(409).json({ success: false, message: 'Sales Order must be approved before conversion.' });
    }
    if (order.status === 'Rejected') {
      await connection.rollback();
      return res.status(409).json({ success: false, message: 'A Rejected Sales Order cannot be converted.' });
    }

    const [vendors] = await connection.query('SELECT id,display_name FROM vendors WHERE id=? LIMIT 1', [vendorId]);
    if (!vendors.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Selected vendor not found.' });
    }
    const [existing] = await connection.query('SELECT id FROM purchase_orders WHERE sales_order_id=? LIMIT 1', [salesOrderId]);
    let purchaseOrderId;
    const alreadyExists = existing.length > 0;
    if (alreadyExists) {
      purchaseOrderId = existing[0].id;
    } else {
      const [sourceItems] = await connection.query(`
        SELECT source_type,item_id,part_id,item_name,description,qty,rate,amount
        FROM sales_order_items WHERE sales_order_id=? ORDER BY id ASC
      `, [salesOrderId]);
      if (!sourceItems.length) {
        await connection.rollback();
        return res.status(409).json({ success: false, message: 'Sales Order has no items to convert.' });
      }
      const number = await getNextTransactionNumber({
        module: 'Purchase Order', table: 'purchase_orders', numberColumn: 'po_number', padding: 4, connection,
      });
      const [created] = await connection.query(`
        INSERT INTO purchase_orders (
          po_number,vendor_id,vendor_name,order_date,delivery_expected_date,payment_terms,
          due_date,reference_number,sub_total,total,status,sales_order_id,sales_order_number
        ) VALUES (?,?,?,CURRENT_DATE(),?,'100% Advance',NULL,?,?,?,?,?,?)
      `, [number.transactionNumber, vendorId, vendors[0].display_name,
        order.expected_shipment_date || null, order.so_number, order.sub_total, order.total, 'Draft', salesOrderId, order.so_number]);
      purchaseOrderId = created.insertId;
      for (const line of sourceItems) {
        await connection.query(`
          INSERT INTO purchase_order_items
            (purchase_order_id,source_type,item_id,part_id,item_name,description,qty,rate,amount)
          VALUES (?,?,?,?,?,?,?,?,?)
        `, [purchaseOrderId,line.source_type,line.item_id,line.part_id,line.item_name,line.description,line.qty,line.rate,line.amount]);
      }
    }

    const [purchaseOrders] = await connection.query(`
      SELECT id,po_number,vendor_id,vendor_name,order_date,delivery_expected_date,payment_terms,due_date,
        reference_number,sub_total,total,status,sales_order_id,sales_order_number
      FROM purchase_orders WHERE id=? LIMIT 1
    `, [purchaseOrderId]);
    const [items] = await connection.query(`
      SELECT id,purchase_order_id,source_type,item_id,part_id,item_name,description,qty,rate,amount
      FROM purchase_order_items WHERE purchase_order_id=? ORDER BY id ASC
    `, [purchaseOrderId]);
    await connection.commit();
    return res.status(alreadyExists ? 200 : 201).json({
      success: true,
      message: alreadyExists ? 'Existing Purchase Order returned.' : 'Purchase Order created from Sales Order.',
      data: mapPurchaseOrder(purchaseOrders[0], items.map(mapPurchaseOrderItem)),
    });
  } catch (error) {
    try { await connection.rollback(); } catch (_) {}
    if (error.code === 'ER_DUP_ENTRY') {
      try {
        const [rows] = await db.query(`
          SELECT id,po_number,vendor_id,vendor_name,order_date,delivery_expected_date,payment_terms,due_date,
            reference_number,sub_total,total,status,sales_order_id,sales_order_number
          FROM purchase_orders WHERE sales_order_id=? LIMIT 1
        `, [salesOrderId]);
        if (rows.length) {
          const [items] = await db.query(`
            SELECT id,purchase_order_id,source_type,item_id,part_id,item_name,description,qty,rate,amount
            FROM purchase_order_items WHERE purchase_order_id=? ORDER BY id ASC
          `, [rows[0].id]);
          return res.status(200).json({ success: true, message: 'Existing Purchase Order returned.', data: mapPurchaseOrder(rows[0], items.map(mapPurchaseOrderItem)) });
        }
      } catch (_) {}
    }
    console.error('Convert Sales Order to Purchase Order error:', error);
    return res.status(500).json({ success: false, message: 'Failed to create Purchase Order from Sales Order.' });
  } finally {
    connection.release();
  }
});

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

      const orderDate =
        normalizeDate(
          date
        );

      if (!orderDate) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Purchase order date is required',
          });
      }

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

      const preparedItems =
        [];

      let subTotal =
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

        if (!itemName) {
          await connection
            .rollback();

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
          subTotal.toFixed(2)
        );

      const total =
        subTotal;

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
              .toString()
              .trim() !== ''
              ? paymentTerms
                  .toString()
                  .trim()
              : '100% Advance',

            normalizeDate(
              dueDate
            ),

            referenceNumber &&
            referenceNumber
              .toString()
              .trim() !== ''
              ? referenceNumber
                  .toString()
                  .trim()
              : null,

            subTotal,

            total,

            'Draft',
          ]
        );

      const purchaseOrderId =
        orderResult.insertId;

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

      await connection
        .commit();

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
            purchaseOrderId,
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
            purchaseOrderId,
          ]
        );

      return res
        .status(201)
        .json({
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
// UPDATE PURCHASE ORDER
// ============================================================

router.put(
  '/:id',
  async (req, res) => {
    let connection;

    try {
      const id = Number(req.params.id);
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

      if (!Number.isInteger(id) || id <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Invalid purchase order ID',
        });
      }
      if (!poNumber || poNumber.toString().trim() === '') {
        return res.status(400).json({
          success: false,
          message: 'Purchase order number is required',
        });
      }

      const parsedVendorId = Number(vendorId);
      if (!Number.isInteger(parsedVendorId) || parsedVendorId <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Please select a valid vendor',
        });
      }

      const orderDate = normalizeDate(date);
      if (!orderDate) {
        return res.status(400).json({
          success: false,
          message: 'Purchase order date is required',
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

      const [orderRows] = await connection.query(
        'SELECT id FROM purchase_orders WHERE id = ? LIMIT 1',
        [id]
      );
      if (orderRows.length === 0) {
        await connection.rollback();
        return res.status(404).json({
          success: false,
          message: 'Purchase order not found',
        });
      }

      const [vendorRows] = await connection.query(
        'SELECT id, display_name FROM vendors WHERE id = ? LIMIT 1',
        [parsedVendorId]
      );
      if (vendorRows.length === 0) {
        await connection.rollback();
        return res.status(404).json({
          success: false,
          message: 'Selected vendor not found',
        });
      }

      const preparedItems = [];
      let subTotal = 0;
      for (const line of items) {
        const itemName = line.itemName?.toString().trim() ?? '';
        if (!itemName) {
          await connection.rollback();
          return res.status(400).json({
            success: false,
            message: 'Every purchase order row must have an item',
          });
        }

        const qty = toNumber(line.qty);
        const rate = toNumber(line.rate);
        if (qty <= 0 || rate < 0) {
          await connection.rollback();
          return res.status(400).json({
            success: false,
            message: `Invalid quantity or rate for "${itemName}"`,
          });
        }

        const product = await resolveCatalogProduct(connection, itemName, rate);
        const amount = Number((qty * rate).toFixed(2));
        subTotal += amount;
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
      subTotal = Number(subTotal.toFixed(2));

      await connection.query(
        `
        UPDATE purchase_orders
        SET
          po_number = ?,
          vendor_id = ?,
          vendor_name = ?,
          order_date = ?,
          delivery_expected_date = ?,
          payment_terms = ?,
          due_date = ?,
          reference_number = ?,
          sub_total = ?,
          total = ?,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
        `,
        [
          poNumber.trim(),
          parsedVendorId,
          vendorRows[0].display_name,
          orderDate,
          normalizeDate(deliveryExpectedDate),
          paymentTerms?.toString().trim() || '100% Advance',
          normalizeDate(dueDate),
          referenceNumber?.toString().trim() || null,
          subTotal,
          subTotal,
          id,
        ]
      );

      await connection.query(
        'DELETE FROM purchase_order_items WHERE purchase_order_id = ?',
        [id]
      );
      for (const line of preparedItems) {
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
      return res.status(200).json({
        success: true,
        message: 'Purchase order updated successfully',
      });
    } catch (error) {
      if (connection) {
        await connection.rollback();
      }
      console.error('Update purchase order error:', error);
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Failed to update purchase order',
      });
    } finally {
      if (connection) connection.release();
    }
  }
);

router.put(
  '/:id/status',
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      const {
        status,
      } = req.body;

      if (
        !ALLOWED_STATUSES
          .includes(status)
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

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Purchase order status updated successfully',
        });
    } catch (error) {
      console.error(
        'Update PO status error:',
        error
      );

      return res
        .status(500)
        .json({
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
// DELETE
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
          DELETE FROM purchase_orders

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
              'Purchase order not found',
          });
      }

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Purchase order deleted successfully',
        });
    } catch (error) {
      console.error(
        'Delete purchase order error:',
        error
      );

      return res
        .status(500)
        .json({
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
