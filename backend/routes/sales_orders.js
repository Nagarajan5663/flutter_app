const express = require('express');
const db = require('../config/db');

const {
  getNextTransactionNumber,
} = require('../utils/transaction_number');

const router = express.Router();

const ALLOWED_STATUSES = [
  'Draft',
  'Confirmed',
  'Fulfilled',
  'Cancelled',
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

// ============================================================
// UPDATE SALES ORDER STATUS
// ============================================================

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