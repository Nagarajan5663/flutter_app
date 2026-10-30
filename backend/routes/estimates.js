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
  'Accepted',
  'Declined',
  'Expired',
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

function mapEstimateItem(row) {
  return {
    id:
      Number(row.id),

    estimateId:
      Number(
        row.estimate_id
      ),

    sourceType:
      row.source_type ??
      'Item',

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

function mapEstimate(
  row,
  items = []
) {
  return {
    id:
      Number(row.id),

    estimateNumber:
      row.estimate_number ??
      '',

    customerId:
      Number(
        row.customer_id
      ),

    customerName:
      row.customer_name ??
      '',

    customerEmail: row.customer_email ?? '',
    customerPhone: row.customer_phone ?? '',

    salesPerson:
      row.sales_person ??
      '',

    date:
      row.estimate_date ??
      '',

    expiryDate:
      row.expiry_date ??
      null,

    subTotal:
      toNumber(
        row.sub_total
      ),

    total:
      toNumber(
        row.total
      ),

    status:
      row.status ??
      'Draft',

    approvalStatus:
      row.approval_status ?? 'Pending',
    approvedAt: row.approved_at ?? null,
    approvedBy: row.approved_by == null ? null : Number(row.approved_by),

    items,

    createdAt:
      row.created_at ??
      null,

    updatedAt:
      row.updated_at ??
      null,
  };
}

// ============================================================
// NEXT ESTIMATE NUMBER
//
// GET /api/estimates/next-number
//
// Prefix and starting number come from:
// transaction_number_series
//
// module = Estimate
// ============================================================

router.get(
  '/next-number',
  async (req, res) => {
    try {
      const result =
        await getNextTransactionNumber({
          module:
            'Estimate',

          table:
            'estimates',

          numberColumn:
            'estimate_number',

          padding:
            4,
        });

      return res
        .status(200)
        .json({
          success: true,

          data: {
            estimateNumber:
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
        'Get next estimate number error:',
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
            'Failed to generate estimate number',
        });
    }
  }
);

// ============================================================
// GET ALL ESTIMATES
//
// GET /api/estimates
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
          estimate_number,

          customer_id,
          customer_name,
          (SELECT email FROM customers WHERE customers.id = estimates.customer_id LIMIT 1) AS customer_email,
          (SELECT phone FROM customers WHERE customers.id = estimates.customer_id LIMIT 1) AS customer_phone,

          sales_person,

          DATE_FORMAT(
            estimate_date,
            '%Y-%m-%d'
          ) AS estimate_date,

          CASE
            WHEN expiry_date
              IS NULL
              THEN NULL

            ELSE DATE_FORMAT(
              expiry_date,
              '%Y-%m-%d'
            )
          END AS expiry_date,

          sub_total,
          total,
          status,
          approval_status,
          approved_at,
          approved_by,
          (SELECT id FROM sales_orders WHERE estimate_id = estimates.id LIMIT 1) AS sales_order_id,
          (SELECT so_number FROM sales_orders WHERE estimate_id = estimates.id LIMIT 1) AS sales_order_number,

          created_at,
          updated_at

        FROM estimates

        WHERE 1 = 1
      `;

      const values = [];

      // STATUS

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

      // CUSTOMER

      if (
        customer &&
        customer
          .toString()
          .trim() !== ''
      ) {
        sql += `
          AND customer_name
            LIKE ?
        `;

        values.push(
          `%${customer
            .toString()
            .trim()}%`
        );
      }

      // DATE FROM

      const normalizedDateFrom =
        normalizeDate(
          dateFrom
        );

      if (
        normalizedDateFrom
      ) {
        sql += `
          AND estimate_date >= ?
        `;

        values.push(
          normalizedDateFrom
        );
      }

      // DATE TO

      const normalizedDateTo =
        normalizeDate(
          dateTo
        );

      if (
        normalizedDateTo
      ) {
        sql += `
          AND estimate_date <= ?
        `;

        values.push(
          normalizedDateTo
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
              (row) =>
                mapEstimate(
                  row
                )
            ),
        });
    } catch (error) {
      console.error(
        'Get estimates error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to fetch estimates',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// GET SINGLE ESTIMATE
//
// GET /api/estimates/:id
// ============================================================

router.get(
  '/:id',
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      const [estimateRows] =
        await db.query(
          `
          SELECT
            id,
            estimate_number,

            customer_id,
            customer_name,
            (SELECT email FROM customers WHERE customers.id = estimates.customer_id LIMIT 1) AS customer_email,
            (SELECT phone FROM customers WHERE customers.id = estimates.customer_id LIMIT 1) AS customer_phone,

            sales_person,

            DATE_FORMAT(
              estimate_date,
              '%Y-%m-%d'
            ) AS estimate_date,

            CASE
              WHEN expiry_date
                IS NULL
                THEN NULL

              ELSE DATE_FORMAT(
                expiry_date,
                '%Y-%m-%d'
              )
            END AS expiry_date,

            sub_total,
            total,
            status,
            approval_status,
            approved_at,
            approved_by,
            (SELECT id FROM sales_orders WHERE estimate_id = estimates.id LIMIT 1) AS sales_order_id,
            (SELECT so_number FROM sales_orders WHERE estimate_id = estimates.id LIMIT 1) AS sales_order_number,

            created_at,
            updated_at

          FROM estimates

          WHERE id = ?

          LIMIT 1
          `,
          [
            id,
          ]
        );

      if (
        estimateRows.length === 0
      ) {
        return res
          .status(404)
          .json({
            success: false,

            message:
              'Estimate not found',
          });
      }

      const [itemRows] =
        await db.query(
          `
          SELECT
            id,
            estimate_id,

            source_type,

            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM estimate_items

          WHERE estimate_id = ?

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
            mapEstimate(
              estimateRows[0],

              itemRows.map(
                mapEstimateItem
              )
            ),
        });
    } catch (error) {
      console.error(
        'Get estimate error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to fetch estimate',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// CREATE ESTIMATE
//
// POST /api/estimates
// ============================================================

router.post(
  '/',
  async (req, res) => {
    let connection;

    try {
      const {
        estimateNumber,

        customerId,

        salesPerson,

        date,

        expiryDate,

        items,
      } = req.body;

      // --------------------------------------------------------
      // VALIDATION
      // --------------------------------------------------------

      if (
        !estimateNumber ||
        estimateNumber
          .toString()
          .trim() === ''
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Estimate number is required',
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

      const estimateDate =
        normalizeDate(
          date
        );

      if (!estimateDate) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Estimate date is required',
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
      // CUSTOMER
      // --------------------------------------------------------

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

        let itemName = '';

        let description = '';

        // ITEM

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

        // PART

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

          itemId,

          partId,

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

      // --------------------------------------------------------
      // INSERT ESTIMATE
      // --------------------------------------------------------

      const [estimateResult] =
        await connection.query(
          `
          INSERT INTO estimates (
            estimate_number,

            customer_id,
            customer_name,

            sales_person,

            estimate_date,
            expiry_date,

            sub_total,
            total,

            status
          )
          VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?
          )
          `,
          [
            estimateNumber
              .toString()
              .trim(),

            parsedCustomerId,

            customer.display_name,

            salesPerson &&
            salesPerson
              .toString()
              .trim() !== ''
              ? salesPerson
                  .toString()
                  .trim()
              : null,

            estimateDate,

            normalizeDate(
              expiryDate
            ),

            calculatedSubTotal,

            calculatedTotal,

            'Draft',
          ]
        );

      const estimateId =
        estimateResult.insertId;

      // --------------------------------------------------------
      // INSERT ESTIMATE ITEMS
      // --------------------------------------------------------

      for (
        const line
        of preparedItems
      ) {
        await connection.query(
          `
          INSERT INTO estimate_items (
            estimate_id,

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
            estimateId,

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
      // RETURN SAVED ESTIMATE
      // --------------------------------------------------------

      const [savedRows] =
        await db.query(
          `
          SELECT
            id,
            estimate_number,

            customer_id,
            customer_name,

            sales_person,

            DATE_FORMAT(
              estimate_date,
              '%Y-%m-%d'
            ) AS estimate_date,

            CASE
              WHEN expiry_date
                IS NULL
                THEN NULL

              ELSE DATE_FORMAT(
                expiry_date,
                '%Y-%m-%d'
              )
            END AS expiry_date,

            sub_total,
            total,
            status,
            approval_status,
            approved_at,
            approved_by,
            (SELECT id FROM sales_orders WHERE estimate_id = estimates.id LIMIT 1) AS sales_order_id,
            (SELECT so_number FROM sales_orders WHERE estimate_id = estimates.id LIMIT 1) AS sales_order_number,

            created_at,
            updated_at

          FROM estimates

          WHERE id = ?

          LIMIT 1
          `,
          [
            estimateId,
          ]
        );

      const [savedItems] =
        await db.query(
          `
          SELECT
            id,
            estimate_id,

            source_type,

            item_id,
            part_id,

            item_name,
            description,

            qty,
            rate,
            amount

          FROM estimate_items

          WHERE estimate_id = ?

          ORDER BY id ASC
          `,
          [
            estimateId,
          ]
        );

      return res
        .status(201)
        .json({
          success: true,

          message:
            'Estimate created successfully',

          data:
            mapEstimate(
              savedRows[0],

              savedItems.map(
                mapEstimateItem
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
        'Create estimate error:',
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
              'Estimate number already exists',
          });
      }

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to create estimate',

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
// UPDATE ESTIMATE STATUS
//
// PUT /api/estimates/:id/status
// ============================================================

router.post(
  '/:id/approve',
  requireSalesWorkflowUser,
  async (req, res) => {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid estimate ID.' });
    }
    try {
      const [rows] = await db.query(
        'SELECT id, status, approval_status, approved_at, approved_by FROM estimates WHERE id = ? LIMIT 1',
        [id],
      );
      if (!rows.length) return res.status(404).json({ success: false, message: 'Estimate not found.' });
      if (['Declined', 'Expired'].includes(rows[0].status)) {
        return res.status(409).json({ success: false, message: `A ${rows[0].status} Estimate cannot be approved.` });
      }
      if (rows[0].approval_status !== 'Approved') {
        await db.query(
          'UPDATE estimates SET approval_status = ?, approved_at = NOW(), approved_by = ? WHERE id = ?',
          ['Approved', req.workflowUser.id, id],
        );
      }
      const [updated] = await db.query(`
        SELECT id, estimate_number, customer_id, customer_name, sales_person,
          DATE_FORMAT(estimate_date,'%Y-%m-%d') AS estimate_date,
          DATE_FORMAT(expiry_date,'%Y-%m-%d') AS expiry_date,
          sub_total,total,status,approval_status,approved_at,approved_by,created_at,updated_at
        FROM estimates WHERE id = ? LIMIT 1
      `, [id]);
      const [items] = await db.query(`
        SELECT id,estimate_id,source_type,item_id,part_id,item_name,description,qty,rate,amount
        FROM estimate_items WHERE estimate_id = ? ORDER BY id ASC
      `, [id]);
      return res.status(200).json({ success: true, data: mapEstimate(updated[0], items.map(mapEstimateItem)) });
    } catch (error) {
      console.error('Approve estimate error:', error);
      return res.status(500).json({ success: false, message: 'Failed to approve Estimate.' });
    }
  },
);

router.put(
  '/:id',
  async (req, res) => {
    const id = Number(req.params.id);
    const { customerId, salesPerson, date, expiryDate, items } = req.body || {};
    if (!Number.isInteger(id) || id <= 0 || !Number.isInteger(Number(customerId)) || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Estimate details and at least one item are required.' });
    }
    let connection;
    try {
      connection = await db.getConnection();
      await connection.beginTransaction();
      const [rows] = await connection.query(
        'SELECT id, customer_id, approval_status FROM estimates WHERE id = ? FOR UPDATE', [id],
      );
      if (!rows.length) {
        await connection.rollback();
        return res.status(404).json({ success: false, message: 'Estimate not found.' });
      }
      if (rows[0].approval_status === 'Approved') {
        await connection.rollback();
        return res.status(409).json({ success: false, message: 'Approved Estimates cannot be edited.' });
      }
      const [linked] = await connection.query('SELECT id FROM sales_orders WHERE estimate_id = ? LIMIT 1', [id]);
      if (linked.length) {
        await connection.rollback();
        return res.status(409).json({ success: false, message: 'An Estimate converted to a Sales Order cannot be edited.' });
      }
      const [customers] = await connection.query('SELECT display_name FROM customers WHERE id = ? LIMIT 1', [Number(customerId)]);
      if (!customers.length) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'Selected customer was not found.' });
      }
      let subtotal = 0;
      const lines = items.map((item) => {
        const qty = Number(item.qty);
        const rate = Number(item.rate);
        if (!Number.isFinite(qty) || qty <= 0 || !Number.isFinite(rate) || rate < 0) throw new Error('Each line needs a valid quantity and rate.');
        const amount = Number((qty * rate).toFixed(2));
        subtotal += amount;
        const sourceType = item.sourceType === 'Part' ? 'Part' : 'Item';
        return [id, sourceType, sourceType === 'Item' ? Number(item.itemId) || null : null,
          sourceType === 'Part' ? Number(item.partId) || null : null, String(item.itemName || ''),
          item.description || null, qty, rate, amount];
      });
      subtotal = Number(subtotal.toFixed(2));
      await connection.query(
        `UPDATE estimates SET customer_id=?,customer_name=?,sales_person=?,estimate_date=?,expiry_date=?,sub_total=?,total=? WHERE id=?`,
        [Number(customerId), customers[0].display_name, salesPerson || null, normalizeDate(date), normalizeDate(expiryDate), subtotal, subtotal, id],
      );
      await connection.query('DELETE FROM estimate_items WHERE estimate_id = ?', [id]);
      for (const line of lines) {
        await connection.query(
          `INSERT INTO estimate_items (estimate_id,source_type,item_id,part_id,item_name,description,qty,rate,amount) VALUES (?,?,?,?,?,?,?,?,?)`, line,
        );
      }
      await connection.commit();
      return res.status(200).json({ success: true, message: 'Estimate updated successfully.' });
    } catch (error) {
      if (connection) await connection.rollback();
      console.error('Update estimate error:', error);
      return res.status(500).json({ success: false, message: error.message || 'Failed to update Estimate.' });
    } finally {
      if (connection) connection.release();
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
          .includes(
            status
          )
      ) {
        return res
          .status(400)
          .json({
            success: false,

            message:
              'Invalid estimate status',
          });
      }

      const [result] =
        await db.query(
          `
          UPDATE estimates

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
              'Estimate not found',
          });
      }

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Estimate status updated successfully',
        });
    } catch (error) {
      console.error(
        'Update estimate status error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to update estimate status',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// DELETE ESTIMATE
//
// DELETE /api/estimates/:id
// ============================================================

router.delete(
  '/:id',
  async (req, res) => {
    try {
      const {
        id,
      } = req.params;

      const [linkedOrders] = await db.query(
        'SELECT id FROM sales_orders WHERE estimate_id = ? LIMIT 1', [id],
      );
      if (linkedOrders.length) {
        return res.status(409).json({ success: false, message: 'Estimate has a Sales Order and cannot be deleted.' });
      }

      const [result] =
        await db.query(
          `
          DELETE FROM estimates

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
              'Estimate not found',
          });
      }

      return res
        .status(200)
        .json({
          success: true,

          message:
            'Estimate deleted successfully',
        });
    } catch (error) {
      console.error(
        'Delete estimate error:',
        error
      );

      return res
        .status(500)
        .json({
          success: false,

          message:
            'Failed to delete estimate',

          error:
            error.message,
        });
    }
  }
);

module.exports = router;
