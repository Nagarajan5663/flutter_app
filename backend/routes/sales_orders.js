const express = require('express');
const db = require('../config/db');

const {
  getNextTransactionNumber,
} = require('../utils/transaction_number');
const { requireSalesWorkflowUser } = require('../middleware/workflow_auth');

const router = express.Router();

const ALLOWED_STATUSES = [
  'Draft',
  'Approved',
  'Sent',
  'Rejected',
];

const ALLOWED_PURCHASE_STATUSES = [
  'Not Started',
  'Partial',
  'Completed',
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

function mapSalesOrderItem(row) {
  return {
    id:
      Number(row.id),

    salesOrderId:
      Number(
        row.sales_order_id
      ),

    sourceType:
      row.source_type ?? 'Item',

    itemId:
      row.item_id == null
        ? null
        : Number(
            row.item_id
          ),

    partId:
      row.part_id == null
        ? null
        : Number(
            row.part_id
          ),

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

function mapSalesOrder(
  row,
  items = []
) {
  return {
    id:
      Number(row.id),

    orderNumber:
      row.so_number ?? '',

    customerId:
      Number(
        row.customer_id
      ),

    customerName:
      row.customer_name ?? '',

    customerEmail: row.customer_email ?? '',
    customerPhone: row.customer_phone ?? '',

    estimateId:
      row.estimate_id == null
        ? null
        : Number(
            row.estimate_id
          ),

    estimateNumber:
      row.estimate_number ?? '',

    salesPerson:
      row.sales_person ?? '',

    date:
      row.order_date ?? '',

    expectedShipmentDate:
      row.expected_shipment_date ??
      null,

    subTotal:
      toNumber(
        row.sub_total
      ),

    total:
      toNumber(
        row.total
      ),

    notes:
      row.notes ?? '',

    termsAndConditions:
      row.terms_and_conditions ??
      '',

    status:
      row.status ?? 'Draft',

    approvalStatus: row.approval_status ?? 'Pending',
    approvedAt: row.approved_at ?? null,
    approvedBy: row.approved_by == null ? null : Number(row.approved_by),

    purchaseStatus:
      row.purchase_status ??
      'Not Started',

    items,

    createdAt:
      row.created_at ?? null,

    updatedAt:
      row.updated_at ?? null,
  };
}

// ============================================================
// NEXT SALES ORDER NUMBER
//
// Prefix + starting number come from:
// transaction_number_series
//
// GET /api/sales-orders/next-number
// ============================================================

router.get(
  '/next-number',
  async (req, res) => {
    try {
      const result =
        await getNextTransactionNumber({
          module:
            'Sales Order',

          table:
            'sales_orders',

          numberColumn:
            'so_number',

          padding:
            4,
        });

      return res
        .status(200)
        .json({
          success: true,

          data: {
            orderNumber:
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
        'Get next sales order number error:',
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
            'Failed to generate sales order number',
        });
    }
  }
);

// ============================================================
// GET ALL SALES ORDERS
// ============================================================

router.get(
  '/',
  async (req, res) => {
    try {
      const {
        status,
        customer,
        dateFrom,
        dateTo,
      } = req.query;

      let sql = `
        SELECT
          id,
          so_number,
          customer_id,
          customer_name,
          (SELECT email FROM customers WHERE customers.id = sales_orders.customer_id LIMIT 1) AS customer_email,
          (SELECT phone FROM customers WHERE customers.id = sales_orders.customer_id LIMIT 1) AS customer_phone,
          estimate_id,
          estimate_number,
          sales_person,

          DATE_FORMAT(
            order_date,
            '%Y-%m-%d'
          ) AS order_date,

          CASE
            WHEN expected_shipment_date
              IS NULL
              THEN NULL

            ELSE DATE_FORMAT(
              expected_shipment_date,
              '%Y-%m-%d'
            )
          END AS expected_shipment_date,

          sub_total,
          total,
          notes,
          terms_and_conditions,
          status,
          approval_status,
          approved_at,
          approved_by,
          (SELECT id FROM invoices WHERE sales_order_id = sales_orders.id LIMIT 1) AS invoice_id,
          (SELECT invoice_number FROM invoices WHERE sales_order_id = sales_orders.id LIMIT 1) AS invoice_number,
          purchase_status,
          created_at,
          updated_at

        FROM sales_orders

        WHERE 1 = 1
      `;

      const values = [];

      if (
        status &&
        status !== 'All'
      ) {
        sql += `
          AND status = ?
        `;

        values.push(
          status
        );
      }

      if (
        customer &&
        customer.trim() !== ''
      ) {
        sql += `
          AND customer_name
            LIKE ?
        `;

        values.push(
          `%${customer.trim()}%`
        );
      }

      if (
        dateFrom &&
        dateFrom.trim() !== ''
      ) {
        sql += `
          AND order_date >= ?
        `;

        values.push(
          dateFrom.trim()
        );
      }

      if (
        dateTo &&
        dateTo.trim() !== ''
      ) {
        sql += `
          AND order_date <= ?
        `;

        values.push(
          dateTo.trim()
        );
      }

      sql += `
        ORDER BY id DESC
      `;

      const [rows] =
        await db.query(
          sql,
          values
        );

      return res
        .status(200)
        .json({
          success: true,

          data:
            rows.map(
              mapSalesOrder
            ),
        });
    } catch (error) {
      console.error(
        'Get sales orders error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to fetch sales orders',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// GET SINGLE SALES ORDER
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
            so_number,
            customer_id,
            customer_name,
            (SELECT email FROM customers WHERE customers.id = sales_orders.customer_id LIMIT 1) AS customer_email,
            (SELECT phone FROM customers WHERE customers.id = sales_orders.customer_id LIMIT 1) AS customer_phone,
            estimate_id,
            estimate_number,
            sales_person,

            DATE_FORMAT(
              order_date,
              '%Y-%m-%d'
            ) AS order_date,

            CASE
              WHEN expected_shipment_date
                IS NULL
                THEN NULL

              ELSE DATE_FORMAT(
                expected_shipment_date,
                '%Y-%m-%d'
              )
            END AS expected_shipment_date,

            sub_total,
            total,
            notes,
            terms_and_conditions,
            status,
            approval_status,
            approved_at,
            approved_by,
            (SELECT id FROM invoices WHERE sales_order_id = sales_orders.id LIMIT 1) AS invoice_id,
            (SELECT invoice_number FROM invoices WHERE sales_order_id = sales_orders.id LIMIT 1) AS invoice_number,
            purchase_status,
            created_at,
            updated_at

          FROM sales_orders

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
              'Sales order not found',
          });
      }

      const [itemRows] =
        await db.query(
          `
          SELECT
            id,
            sales_order_id,
            source_type,
            item_id,
            part_id,
            item_name,
            description,
            qty,
            rate,
            amount

          FROM sales_order_items

          WHERE sales_order_id = ?

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
            mapSalesOrder(
              orderRows[0],

              itemRows.map(
                mapSalesOrderItem
              )
            ),
        });
    } catch (error) {
      console.error(
        'Get sales order error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to fetch sales order',

          error:
            error.message,
        });
    }
  }
);

// Convert one approved Estimate into one Sales Order. The source row lock and
// unique estimate_id index make repeated and concurrent requests idempotent.
router.post(
  '/from-estimate/:estimateId',
  requireSalesWorkflowUser,
  async (req, res) => {
    const estimateId = Number(req.params.estimateId);
    if (!Number.isInteger(estimateId) || estimateId <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid Estimate ID.' });
    }
    const connection = await db.getConnection();
    try {
      await connection.beginTransaction();
      const [estimateRows] = await connection.query(`
        SELECT id,estimate_number,customer_id,customer_name,sales_person,estimate_date,
          sub_total,total,status,approval_status
        FROM estimates WHERE id = ? FOR UPDATE
      `, [estimateId]);
      if (!estimateRows.length) {
        await connection.rollback();
        return res.status(404).json({ success: false, message: 'Estimate not found.' });
      }
      const estimate = estimateRows[0];
      if (estimate.approval_status !== 'Approved') {
        await connection.rollback();
        return res.status(409).json({ success: false, message: 'Estimate must be approved before creating a Sales Order.' });
      }
      const [existing] = await connection.query('SELECT id FROM sales_orders WHERE estimate_id = ? LIMIT 1', [estimateId]);
      let salesOrderId;
      let alreadyExists = existing.length > 0;
      if (alreadyExists) {
        salesOrderId = existing[0].id;
      } else {
        if (['Declined', 'Expired'].includes(estimate.status)) {
          await connection.rollback();
          return res.status(409).json({ success: false, message: `A ${estimate.status} Estimate cannot be converted.` });
        }
        const number = await getNextTransactionNumber({
          module: 'Sales Order', table: 'sales_orders', numberColumn: 'so_number', padding: 4, connection,
        });
        const [created] = await connection.query(`
          INSERT INTO sales_orders (
            so_number,customer_id,customer_name,estimate_id,estimate_number,sales_person,
            order_date,expected_shipment_date,sub_total,total,notes,terms_and_conditions,status,purchase_status
          ) VALUES (?,?,?,?,?,?,CURRENT_DATE(),NULL,?,?,NULL,NULL,'Draft','Not Started')
        `, [number.transactionNumber, estimate.customer_id, estimate.customer_name,
          estimate.id, estimate.estimate_number, estimate.sales_person, estimate.sub_total, estimate.total]);
        salesOrderId = created.insertId;

        const [estimateItems] = await connection.query(`
          SELECT source_type,item_id,part_id,item_name,description,qty,rate,amount
          FROM estimate_items WHERE estimate_id = ? ORDER BY id ASC
        `, [estimateId]);
        for (const line of estimateItems) {
          await connection.query(`
            INSERT INTO sales_order_items (sales_order_id,source_type,item_id,part_id,item_name,description,qty,rate,amount)
            VALUES (?,?,?,?,?,?,?,?,?)
          `, [salesOrderId,line.source_type,line.item_id,line.part_id,line.item_name,line.description,line.qty,line.rate,line.amount]);
        }
      }
      await connection.commit();

      const [orderRows] = await db.query(`
        SELECT id,so_number,customer_id,customer_name,estimate_id,estimate_number,sales_person,
          DATE_FORMAT(order_date,'%Y-%m-%d') AS order_date,
          DATE_FORMAT(expected_shipment_date,'%Y-%m-%d') AS expected_shipment_date,
          sub_total,total,notes,terms_and_conditions,status,approval_status,approved_at,approved_by,
          purchase_status,created_at,updated_at
        FROM sales_orders WHERE id = ? LIMIT 1
      `, [salesOrderId]);
      const [orderItems] = await db.query(`
        SELECT id,sales_order_id,source_type,item_id,part_id,item_name,description,qty,rate,amount
        FROM sales_order_items WHERE sales_order_id = ? ORDER BY id ASC
      `, [salesOrderId]);
      return res.status(alreadyExists ? 200 : 201).json({
        success: true,
        message: alreadyExists ? 'Existing Sales Order returned.' : 'Sales Order created from Estimate.',
        data: mapSalesOrder(orderRows[0], orderItems.map(mapSalesOrderItem)),
      });
    } catch (error) {
      try { await connection.rollback(); } catch (_) {}
      if (error.code === 'ER_DUP_ENTRY') {
        const [rows] = await db.query('SELECT id FROM sales_orders WHERE estimate_id = ? LIMIT 1', [estimateId]);
        if (rows.length) return res.status(200).json({ success: true, message: 'Existing Sales Order returned.', data: { id: Number(rows[0].id) } });
      }
      console.error('Convert Estimate to Sales Order error:', error);
      return res.status(500).json({ success: false, message: 'Failed to create Sales Order from Estimate.' });
    } finally {
      connection.release();
    }
  },
);

// ============================================================
// CREATE SALES ORDER
// ============================================================

router.post(
  '/',
  async (req, res) => {
    let connection;

    try {
      const {
        orderNumber,
        customerId,

        estimateId,
        estimateNumber,

        salesPerson,

        date,
        expectedShipmentDate,

        items,

        notes,
        termsAndConditions,
      } = req.body;

      if (estimateId != null && Number(estimateId) > 0) {
        return res.status(400).json({
          success: false,
          message: 'Create a Sales Order from the approved Estimate using its workflow action.',
        });
      }

      if (
        !orderNumber ||
        orderNumber.trim() === ''
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Sales order number is required',
          });
      }

      const parsedCustomerId =
        Number(
          customerId
        );

      if (
        !Number.isInteger(
          parsedCustomerId
        ) ||
        parsedCustomerId <= 0
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Please select a valid customer',
          });
      }

      if (
        !date ||
        date.trim() === ''
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Sales order date is required',
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

      // CUSTOMER

      const [customerRows] =
        await connection.query(
          `
          SELECT
            id,
            display_name

          FROM customers

          WHERE id = ?

          LIMIT 1
          `,
          [
            parsedCustomerId,
          ]
        );

      if (
        customerRows.length === 0
      ) {
        await connection
          .rollback();

        return res
          .status(404)
          .json({
            success: false,

            message:
              'Selected customer not found',
          });
      }

      const customer =
        customerRows[0];

      // OPTIONAL ESTIMATE

      let finalEstimateId =
        null;

      let finalEstimateNumber =
        estimateNumber &&
        estimateNumber
          .toString()
          .trim() !== ''
          ? estimateNumber
              .toString()
              .trim()
          : null;

      if (
        estimateId != null &&
        Number(
          estimateId
        ) > 0
      ) {
        const parsedEstimateId =
          Number(
            estimateId
          );

        const [estimateRows] =
          await connection.query(
            `
            SELECT
              id,
              estimate_number

            FROM estimates

            WHERE id = ?

            LIMIT 1
            `,
            [
              parsedEstimateId,
            ]
          );

        if (
          estimateRows.length === 0
        ) {
          await connection
            .rollback();

          return res
            .status(404)
            .json({
              success: false,

              message:
                'Selected estimate not found',
            });
        }

        finalEstimateId =
          parsedEstimateId;

        finalEstimateNumber =
          estimateRows[0]
            .estimate_number;
      }

      // ITEMS

      const preparedItems =
        [];

      let calculatedSubTotal =
        0;

      for (
        const line
        of items
      ) {
        const sourceType =
          line.sourceType;

        if (
          sourceType !== 'Item' &&
          sourceType !== 'Part'
        ) {
          await connection
            .rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                'Invalid item source type',
            });
        }

        const itemId =
          sourceType === 'Item'
            ? Number(
                line.itemId
              )
            : null;

        const partId =
          sourceType === 'Part'
            ? Number(
                line.partId
              )
            : null;

        if (
          sourceType === 'Item' &&
          (
            !Number.isInteger(
              itemId
            ) ||
            itemId <= 0
          )
        ) {
          await connection
            .rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                'Invalid item selected',
            });
        }

        if (
          sourceType === 'Part' &&
          (
            !Number.isInteger(
              partId
            ) ||
            partId <= 0
          )
        ) {
          await connection
            .rollback();

          return res
            .status(400)
            .json({
              success: false,

              message:
                'Invalid part selected',
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
                'Quantity must be greater than zero',
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
                'Rate cannot be negative',
            });
        }

        let itemName =
          '';

        let description =
          '';

        if (
          sourceType === 'Item'
        ) {
          const [rows] =
            await connection.query(
              `
              SELECT
                id,
                name,
                description

              FROM items

              WHERE id = ?

              LIMIT 1
              `,
              [
                itemId,
              ]
            );

          if (
            rows.length === 0
          ) {
            await connection
              .rollback();

            return res
              .status(404)
              .json({
                success: false,

                message:
                  'Selected item not found',
              });
          }

          itemName =
            rows[0].name ??
            '';

          description =
            line.description ??
            rows[0]
              .description ??
            '';
        }

        if (
          sourceType === 'Part'
        ) {
          const [rows] =
            await connection.query(
              `
              SELECT
                id,
                name,
                description

              FROM parts

              WHERE id = ?

              LIMIT 1
              `,
              [
                partId,
              ]
            );

          if (
            rows.length === 0
          ) {
            await connection
              .rollback();

            return res
              .status(404)
              .json({
                success: false,

                message:
                  'Selected part not found',
              });
          }

          itemName =
            rows[0].name ??
            '';

          description =
            line.description ??
            rows[0]
              .description ??
            '';
        }

        const amount =
          Number(
            (
              qty * rate
            ).toFixed(2)
          );

        calculatedSubTotal +=
          amount;

        preparedItems.push({
          sourceType,

          itemId:
            sourceType ===
            'Item'
              ? itemId
              : null,

          partId:
            sourceType ===
            'Part'
              ? partId
              : null,

          itemName,

          description,

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

      const calculatedTotal =
        calculatedSubTotal;

      const [orderResult] =
        await connection.query(
          `
          INSERT INTO sales_orders (
            so_number,

            customer_id,
            customer_name,

            estimate_id,
            estimate_number,

            sales_person,

            order_date,
            expected_shipment_date,

            sub_total,
            total,

            notes,
            terms_and_conditions,

            status,
            purchase_status
          )
          VALUES (
            ?, ?, ?,
            ?, ?,
            ?,
            ?, ?,
            ?, ?,
            ?, ?,
            ?, ?
          )
          `,
          [
            orderNumber.trim(),

            parsedCustomerId,
            customer.display_name,

            finalEstimateId,
            finalEstimateNumber,

            salesPerson &&
            salesPerson
              .toString()
              .trim() !== ''
              ? salesPerson
                  .toString()
                  .trim()
              : null,

            date,

            expectedShipmentDate &&
            expectedShipmentDate
              .toString()
              .trim() !== ''
              ? expectedShipmentDate
                  .toString()
                  .trim()
              : null,

            calculatedSubTotal,

            calculatedTotal,

            notes &&
            notes
              .toString()
              .trim() !== ''
              ? notes
                  .toString()
                  .trim()
              : null,

            termsAndConditions &&
            termsAndConditions
              .toString()
              .trim() !== ''
              ? termsAndConditions
                  .toString()
                  .trim()
              : null,

            'Draft',

            'Not Started',
          ]
        );

      const salesOrderId =
        orderResult.insertId;

      for (
        const line
        of preparedItems
      ) {
        await connection.query(
          `
          INSERT INTO sales_order_items (
            sales_order_id,

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
            salesOrderId,

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
            so_number,
            customer_id,
            customer_name,
            estimate_id,
            estimate_number,
            sales_person,

            DATE_FORMAT(
              order_date,
              '%Y-%m-%d'
            ) AS order_date,

            CASE
              WHEN expected_shipment_date
                IS NULL
                THEN NULL

              ELSE DATE_FORMAT(
                expected_shipment_date,
                '%Y-%m-%d'
              )
            END AS expected_shipment_date,

            sub_total,
            total,
            notes,
            terms_and_conditions,
            status,
            approval_status,
            approved_at,
            approved_by,
            (SELECT id FROM invoices WHERE sales_order_id = sales_orders.id LIMIT 1) AS invoice_id,
            (SELECT invoice_number FROM invoices WHERE sales_order_id = sales_orders.id LIMIT 1) AS invoice_number,
            purchase_status,
            created_at,
            updated_at

          FROM sales_orders

          WHERE id = ?

          LIMIT 1
          `,
          [
            salesOrderId,
          ]
        );

      const [savedItems] =
        await db.query(
          `
          SELECT
            id,
            sales_order_id,
            source_type,
            item_id,
            part_id,
            item_name,
            description,
            qty,
            rate,
            amount

          FROM sales_order_items

          WHERE sales_order_id = ?

          ORDER BY id ASC
          `,
          [
            salesOrderId,
          ]
        );

      return res
        .status(201)
        .json({
          success: true,

          message:
            'Sales order created successfully',

          data:
            mapSalesOrder(
              savedRows[0],

              savedItems.map(
                mapSalesOrderItem
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
        'Create sales order error:',
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
              'Sales order number already exists',
          });
      }

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to create sales order',

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

router.put('/:id', async (req, res) => {
  const id = Number(req.params.id);
  const {
    customerId,
    salesPerson = '',
    date,
    expectedShipmentDate,
    items,
    notes = '',
    termsAndConditions = '',
  } = req.body;

  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ success: false, message: 'Invalid Sales Order ID.' });
  }
  if (!date || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ success: false, message: 'A date and at least one item are required.' });
  }

  const parsedCustomerId = Number(customerId);
  if (!Number.isInteger(parsedCustomerId) || parsedCustomerId <= 0) {
    return res.status(400).json({ success: false, message: 'Please select a valid customer.' });
  }

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [orders] = await connection.query(
      'SELECT id FROM sales_orders WHERE id = ? FOR UPDATE',
      [id],
    );
    if (!orders.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Sales Order not found.' });
    }

    const [customers] = await connection.query(
      'SELECT id, display_name FROM customers WHERE id = ? LIMIT 1',
      [parsedCustomerId],
    );
    if (!customers.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Selected customer not found.' });
    }

    const preparedItems = [];
    let total = 0;
    for (const line of items) {
      const sourceType = line.sourceType;
      if (sourceType !== 'Item' && sourceType !== 'Part') {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'Invalid item source type.' });
      }

      const sourceId = Number(sourceType === 'Item' ? line.itemId : line.partId);
      if (!Number.isInteger(sourceId) || sourceId <= 0) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: `Invalid ${sourceType.toLowerCase()} selected.` });
      }
      const qty = toNumber(line.qty, -1);
      const rate = toNumber(line.rate, -1);
      if (qty <= 0 || rate < 0) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'Item quantity must be greater than zero and rate cannot be negative.' });
      }

      const table = sourceType === 'Item' ? 'items' : 'parts';
      const [catalogRows] = await connection.query(
        `SELECT id, name, description FROM ${table} WHERE id = ? LIMIT 1`,
        [sourceId],
      );
      if (!catalogRows.length) {
        await connection.rollback();
        return res.status(404).json({ success: false, message: `Selected ${sourceType.toLowerCase()} not found.` });
      }

      const amount = Number((qty * rate).toFixed(2));
      total += amount;
      preparedItems.push({
        sourceType,
        itemId: sourceType === 'Item' ? sourceId : null,
        partId: sourceType === 'Part' ? sourceId : null,
        itemName: catalogRows[0].name ?? '',
        description: line.description ?? catalogRows[0].description ?? '',
        qty,
        rate,
        amount,
      });
    }

    total = Number(total.toFixed(2));
    await connection.query('DELETE FROM sales_order_items WHERE sales_order_id = ?', [id]);
    for (const line of preparedItems) {
      await connection.query(`
        INSERT INTO sales_order_items
          (sales_order_id,source_type,item_id,part_id,item_name,description,qty,rate,amount)
        VALUES (?,?,?,?,?,?,?,?,?)
      `, [id,line.sourceType,line.itemId,line.partId,line.itemName,line.description,line.qty,line.rate,line.amount]);
    }
    await connection.query(`
      UPDATE sales_orders
      SET customer_id=?,customer_name=?,sales_person=?,order_date=?,expected_shipment_date=?,
          sub_total=?,total=?,notes=?,terms_and_conditions=?
      WHERE id=?
    `, [
      parsedCustomerId,
      customers[0].display_name,
      salesPerson,
      date,
      expectedShipmentDate || null,
      total,
      notes || null,
      termsAndConditions || null,
      id,
    ]);

    await connection.commit();
    return res.status(200).json({ success: true, message: 'Sales Order updated successfully.' });
  } catch (error) {
    try { await connection.rollback(); } catch (_) {}
    console.error('Update Sales Order error:', error);
    return res.status(400).json({ success: false, message: error.message || 'Failed to update Sales Order.' });
  } finally {
    connection.release();
  }
});

// ============================================================
// UPDATE SALES ORDER STATUS
// ============================================================

router.post(
  '/:id/approve',
  requireSalesWorkflowUser,
  async (req, res) => {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid Sales Order ID.' });
    }
    try {
      const [rows] = await db.query(
        'SELECT id,status,approval_status FROM sales_orders WHERE id = ? LIMIT 1', [id],
      );
      if (!rows.length) return res.status(404).json({ success: false, message: 'Sales Order not found.' });
      if (rows[0].status === 'Rejected') {
        return res.status(409).json({ success: false, message: 'A Rejected Sales Order cannot be approved.' });
      }
      await db.query(
        `UPDATE sales_orders
         SET status = 'Approved',
             approval_status = 'Approved',
             approved_at = COALESCE(approved_at, NOW()),
             approved_by = COALESCE(approved_by, ?)
         WHERE id = ?`,
        [req.workflowUser.id, id],
      );
      const [updated] = await db.query(`
        SELECT id,so_number,customer_id,customer_name,estimate_id,estimate_number,sales_person,
          DATE_FORMAT(order_date,'%Y-%m-%d') AS order_date,
          DATE_FORMAT(expected_shipment_date,'%Y-%m-%d') AS expected_shipment_date,
          sub_total,total,notes,terms_and_conditions,status,approval_status,approved_at,approved_by,
          purchase_status,created_at,updated_at
        FROM sales_orders WHERE id = ? LIMIT 1
      `, [id]);
      const [items] = await db.query(`
        SELECT id,sales_order_id,source_type,item_id,part_id,item_name,description,qty,rate,amount
        FROM sales_order_items WHERE sales_order_id = ? ORDER BY id ASC
      `, [id]);
      return res.status(200).json({ success: true, data: mapSalesOrder(updated[0], items.map(mapSalesOrderItem)) });
    } catch (error) {
      console.error('Approve Sales Order error:', error);
      return res.status(500).json({ success: false, message: 'Failed to approve Sales Order.' });
    }
  },
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
              'Invalid sales order status',
          });
      }

      const [result] =
        await db.query(
          `
          UPDATE sales_orders

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
              'Sales order not found',
          });
      }

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Sales order status updated successfully',
        });
    } catch (error) {
      console.error(
        'Update sales order status error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to update sales order status',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// UPDATE PURCHASE STATUS
// ============================================================

router.put(
  '/:id/purchase-status',
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      const {
        purchaseStatus,
      } = req.body;

      if (
        !ALLOWED_PURCHASE_STATUSES
          .includes(
            purchaseStatus
          )
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Invalid purchase status',
          });
      }

      const [result] =
        await db.query(
          `
          UPDATE sales_orders

          SET purchase_status = ?

          WHERE id = ?
          `,
          [
            purchaseStatus,
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
              'Sales order not found',
          });
      }

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Purchase status updated successfully',
        });
    } catch (error) {
      console.error(
        'Update purchase status error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to update purchase status',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// DELETE SALES ORDER
// ============================================================

router.delete(
  '/:id',
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      const [linkedInvoices] = await db.query(
        'SELECT id FROM invoices WHERE sales_order_id = ? LIMIT 1', [id],
      );
      if (linkedInvoices.length) {
        return res.status(409).json({ success: false, message: 'Sales Order has an Invoice and cannot be deleted.' });
      }

      const [result] =
        await db.query(
          `
          DELETE FROM sales_orders

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
              'Sales order not found',
          });
      }

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Sales order deleted successfully',
        });
    } catch (error) {
      console.error(
        'Delete sales order error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to delete sales order',

          error:
            error.message,
        });
    }
  }
);

module.exports = router;
