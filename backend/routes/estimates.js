const express = require('express');
const db = require('../config/db');

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

function toNumber(value, fallback = 0) {
  const number = Number(value);

  return Number.isFinite(number)
    ? number
    : fallback;
}

function mapEstimate(row, items = []) {
  return {
    id: Number(row.id),

    estimateNumber:
      row.estimate_number ?? '',

    customerId:
      Number(row.customer_id),

    customerName:
      row.customer_name ?? '',

    salesPerson:
      row.sales_person ?? '',

    date:
      row.estimate_date ?? '',

    expiryDate:
      row.expiry_date ?? null,

    subTotal:
      toNumber(row.sub_total),

    total:
      toNumber(row.total),

    status:
      row.status ?? 'Draft',

    items,

    createdAt:
      row.created_at ?? null,

    updatedAt:
      row.updated_at ?? null,
  };
}

function mapEstimateItem(row) {
  return {
    id: Number(row.id),

    estimateId:
      Number(row.estimate_id),

    sourceType:
      row.source_type,

    itemId:
      row.item_id == null
        ? null
        : Number(row.item_id),

    partId:
      row.part_id == null
        ? null
        : Number(row.part_id),

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

// ============================================================
// GET NEXT ESTIMATE NUMBER
//
// GET /api/estimates/next-number
// ============================================================

router.get(
  '/next-number',
  async (req, res) => {
    try {
      const [rows] = await db.query(`
        SELECT
          MAX(
            CAST(
              SUBSTRING(
                estimate_number,
                5
              ) AS UNSIGNED
            )
          ) AS max_number
        FROM estimates
        WHERE estimate_number LIKE 'EST-%'
      `);

      const maxNumber =
        Number(
          rows[0]?.max_number ?? 0
        );

      const nextNumber =
        maxNumber + 1;

      res.status(200).json({
        success: true,
        data: {
          estimateNumber:
            `EST-${nextNumber}`,
        },
      });
    } catch (error) {
      console.error(
        'Get next estimate number error:',
        error
      );

      res.status(500).json({
        success: false,
        message:
          'Failed to generate estimate number',
        error: error.message,
      });
    }
  }
);

// ============================================================
// GET ALL ESTIMATES
//
// GET /api/estimates
// ============================================================

router.get('/', async (req, res) => {
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
        sales_person,

        DATE_FORMAT(
          estimate_date,
          '%Y-%m-%d'
        ) AS estimate_date,

        CASE
          WHEN expiry_date IS NULL
            THEN NULL
          ELSE DATE_FORMAT(
            expiry_date,
            '%Y-%m-%d'
          )
        END AS expiry_date,

        sub_total,
        total,
        status,
        created_at,
        updated_at

      FROM estimates

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

      values.push(status);
    }

    if (
      customer &&
      customer.trim() !== ''
    ) {
      sql += `
        AND customer_name LIKE ?
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
        AND estimate_date >= ?
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
        AND estimate_date <= ?
      `;

      values.push(
        dateTo.trim()
      );
    }

    sql += `
      ORDER BY id DESC
    `;

    const [rows] = await db.query(
      sql,
      values
    );

    res.status(200).json({
      success: true,
      data: rows.map(
        (row) => mapEstimate(row),
      ),
    });
  } catch (error) {
    console.error(
      'Get estimates error:',
      error
    );

    res.status(500).json({
      success: false,
      message:
        'Failed to fetch estimates',
      error: error.message,
    });
  }
});

// ============================================================
// GET SINGLE ESTIMATE WITH ITEMS
//
// GET /api/estimates/:id
// ============================================================

router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [estimateRows] =
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
            WHEN expiry_date IS NULL
              THEN NULL
            ELSE DATE_FORMAT(
              expiry_date,
              '%Y-%m-%d'
            )
          END AS expiry_date,

          sub_total,
          total,
          status,
          created_at,
          updated_at

        FROM estimates

        WHERE id = ?

        LIMIT 1
        `,
        [id]
      );

    if (estimateRows.length === 0) {
      return res.status(404).json({
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
        [id]
      );

    res.status(200).json({
      success: true,
      data: mapEstimate(
        estimateRows[0],
        itemRows.map(
          mapEstimateItem
        ),
      ),
    });
  } catch (error) {
    console.error(
      'Get estimate error:',
      error
    );

    res.status(500).json({
      success: false,
      message:
        'Failed to fetch estimate',
      error: error.message,
    });
  }
});

// ============================================================
// CREATE ESTIMATE
//
// POST /api/estimates
// ============================================================

router.post('/', async (req, res) => {
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
      estimateNumber.trim() === ''
    ) {
      return res.status(400).json({
        success: false,
        message:
          'Estimate number is required',
      });
    }

    const parsedCustomerId =
      Number(customerId);

    if (
      !Number.isInteger(
        parsedCustomerId
      ) ||
      parsedCustomerId <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          'Please select a valid customer',
      });
    }

    if (
      !date ||
      date.trim() === ''
    ) {
      return res.status(400).json({
        success: false,
        message:
          'Estimate date is required',
      });
    }

    if (
      !Array.isArray(items) ||
      items.length === 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          'At least one item is required',
      });
    }

    connection =
      await db.getConnection();

    await connection.beginTransaction();

    // --------------------------------------------------------
    // GET CUSTOMER
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
        [parsedCustomerId]
      );

    if (customerRows.length === 0) {
      await connection.rollback();

      return res.status(404).json({
        success: false,
        message:
          'Selected customer not found',
      });
    }

    const customer =
      customerRows[0];

    // --------------------------------------------------------
    // PREPARE ITEMS
    // --------------------------------------------------------

    const preparedItems = [];

    let calculatedSubTotal = 0;

    for (const item of items) {
      const sourceType =
        item.sourceType;

      if (
        sourceType !== 'Item' &&
        sourceType !== 'Part'
      ) {
        await connection.rollback();

        return res.status(400).json({
          success: false,
          message:
            'Invalid item source type',
        });
      }

      const itemId =
        sourceType === 'Item'
          ? Number(item.itemId)
          : null;

      const partId =
        sourceType === 'Part'
          ? Number(item.partId)
          : null;

      if (
        sourceType === 'Item' &&
        (
          !Number.isInteger(itemId) ||
          itemId <= 0
        )
      ) {
        await connection.rollback();

        return res.status(400).json({
          success: false,
          message:
            'Invalid item selected',
        });
      }

      if (
        sourceType === 'Part' &&
        (
          !Number.isInteger(partId) ||
          partId <= 0
        )
      ) {
        await connection.rollback();

        return res.status(400).json({
          success: false,
          message:
            'Invalid part selected',
        });
      }

      const qty =
        toNumber(item.qty);

      const rate =
        toNumber(item.rate);

      if (qty <= 0) {
        await connection.rollback();

        return res.status(400).json({
          success: false,
          message:
            'Quantity must be greater than zero',
        });
      }

      if (rate < 0) {
        await connection.rollback();

        return res.status(400).json({
          success: false,
          message:
            'Rate cannot be negative',
        });
      }

      let itemName = '';
      let description = '';

      // ------------------------------------------------------
      // ITEM SOURCE
      // ------------------------------------------------------

      if (sourceType === 'Item') {
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
            [itemId]
          );

        if (rows.length === 0) {
          await connection.rollback();

          return res.status(404).json({
            success: false,
            message:
              'Selected item not found',
          });
        }

        itemName =
          rows[0].name ?? '';

        description =
          item.description ??
          rows[0].description ??
          '';
      }

      // ------------------------------------------------------
      // PART SOURCE
      // ------------------------------------------------------

      if (sourceType === 'Part') {
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
            [partId]
          );

        if (rows.length === 0) {
          await connection.rollback();

          return res.status(404).json({
            success: false,
            message:
              'Selected part not found',
          });
        }

        itemName =
          rows[0].name ?? '';

        description =
          item.description ??
          rows[0].description ??
          '';
      }

      const amount =
        Number(
          (qty * rate).toFixed(2)
        );

      calculatedSubTotal += amount;

      preparedItems.push({
        sourceType,
        itemId:
          sourceType === 'Item'
            ? itemId
            : null,

        partId:
          sourceType === 'Part'
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
        calculatedSubTotal.toFixed(2)
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
          estimateNumber.trim(),

          parsedCustomerId,

          customer.display_name,

          salesPerson &&
          salesPerson.trim() !== ''
            ? salesPerson.trim()
            : null,

          date,

          expiryDate &&
          expiryDate.trim() !== ''
            ? expiryDate
            : null,

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
      const item of preparedItems
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

          item.sourceType,

          item.itemId,

          item.partId,

          item.itemName,

          item.description ||
          null,

          item.qty,

          item.rate,

          item.amount,
        ]
      );
    }

    await connection.commit();

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
            WHEN expiry_date IS NULL
              THEN NULL
            ELSE DATE_FORMAT(
              expiry_date,
              '%Y-%m-%d'
            )
          END AS expiry_date,

          sub_total,
          total,
          status,
          created_at,
          updated_at

        FROM estimates

        WHERE id = ?

        LIMIT 1
        `,
        [estimateId]
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
        [estimateId]
      );

    res.status(201).json({
      success: true,

      message:
        'Estimate created successfully',

      data: mapEstimate(
        savedRows[0],

        savedItems.map(
          mapEstimateItem
        ),
      ),
    });
  } catch (error) {
    if (connection) {
      try {
        await connection.rollback();
      } catch (_) {}
    }

    console.error(
      'Create estimate error:',
      error
    );

    if (
      error.code === 'ER_DUP_ENTRY'
    ) {
      return res.status(409).json({
        success: false,
        message:
          'Estimate number already exists',
      });
    }

    res.status(500).json({
      success: false,
      message:
        'Failed to create estimate',
      error: error.message,
    });
  } finally {
    if (connection) {
      connection.release();
    }
  }
});

// ============================================================
// UPDATE STATUS
//
// PUT /api/estimates/:id/status
// ============================================================

router.put(
  '/:id/status',
  async (req, res) => {
    try {
      const { id } = req.params;

      const { status } = req.body;

      if (
        !ALLOWED_STATUSES.includes(
          status
        )
      ) {
        return res.status(400).json({
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
        return res.status(404).json({
          success: false,
          message:
            'Estimate not found',
        });
      }

      res.status(200).json({
        success: true,
        message:
          'Estimate status updated successfully',
      });
    } catch (error) {
      console.error(
        'Update estimate status error:',
        error
      );

      res.status(500).json({
        success: false,
        message:
          'Failed to update estimate status',
        error: error.message,
      });
    }
  }
);

// ============================================================
// DELETE ESTIMATE
//
// DELETE /api/estimates/:id
//
// estimate_items automatically delete because ON DELETE CASCADE.
// ============================================================

router.delete(
  '/:id',
  async (req, res) => {
    try {
      const { id } = req.params;

      const [result] =
        await db.query(
          `
          DELETE FROM estimates

          WHERE id = ?
          `,
          [id]
        );

      if (
        result.affectedRows === 0
      ) {
        return res.status(404).json({
          success: false,
          message:
            'Estimate not found',
        });
      }

      res.status(200).json({
        success: true,
        message:
          'Estimate deleted successfully',
      });
    } catch (error) {
      console.error(
        'Delete estimate error:',
        error
      );

      res.status(500).json({
        success: false,
        message:
          'Failed to delete estimate',
        error: error.message,
      });
    }
  }
);

module.exports = router;