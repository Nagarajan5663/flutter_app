require('dotenv').config();

const express = require('express');
const cors = require('cors');
const db = require('./config/db');
const { syncDatabase } = require('./database/sync');

// ============================================================
// ROUTES
// ============================================================

const transactionNumberSeriesRoutes =
  require('./routes/transaction_number_series');

const itemsRoutes =
  require('./routes/items');

const partsRoutes =
  require('./routes/parts');

const customersRoutes =
  require('./routes/customers');

const estimatesRoutes =
  require('./routes/estimates');

const salesOrdersRoutes =
  require('./routes/sales_orders');

const invoicesRoutes =
  require('./routes/invoices');

const paymentsReceivedRoutes =
  require('./routes/payments_received');

const deliveryChallansRoutes =
  require('./routes/delivery_challans');

const vendorsRoutes =
  require('./routes/vendors');

const purchaseOrdersRoutes =
  require('./routes/purchase_orders');

const billsRoutes =
  require('./routes/bills');

const usersRoutes =
  require('./routes/users');

const rolesRoutes =
  require('./routes/roles');

const emailTestRoutes =
  require('./routes/email_test');

// ============================================================
// APP
// ============================================================

const app = express();

// ============================================================
// MIDDLEWARE
// ============================================================

app.use(
  cors({
    origin: true,
    credentials: true,
  })
);

app.use(
  express.json({
    limit: '10mb',
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: '10mb',
  })
);

// ============================================================
// ROOT
// ============================================================

app.get(
  '/',
  (req, res) => {
    return res.status(200).json({
      success: true,
      message: 'Codexia backend is running',
    });
  }
);

// ============================================================
// DATABASE TEST
//
// GET /api/test-db
// ============================================================

app.get(
  '/api/test-db',
  async (req, res) => {
    try {
      const [rows] =
        await db.query(`
          SELECT
            DATABASE() AS database_name,
            NOW() AS server_time
        `);

      return res.status(200).json({
        success: true,
        message: 'Hostinger MySQL connected successfully',
        data: rows[0],
      });
    } catch (error) {
      console.error(
        'Database test error:',
        error
      );

      return res.status(500).json({
        success: false,
        message: 'Database connection failed',
        error: error.message,
      });
    }
  }
);

// ============================================================
// MYSQL SIMPLE TEST
//
// GET /api/mysql-test
// ============================================================

app.get(
  '/api/mysql-test',
  async (req, res) => {
    try {
      const [rows] =
        await db.query(`
          SELECT 1 AS test
        `);

      return res.status(200).json({
        success: true,
        message: 'MySQL database connected successfully',
        data: rows,
      });
    } catch (error) {
      console.error(
        'MySQL test error:',
        error
      );

      return res.status(500).json({
        success: false,
        message: 'MySQL connection failed',
        error: error.message,
      });
    }
  }
);

// ============================================================
// TRANSACTION NUMBER SERIES
//
// /api/transaction-number-series
// ============================================================

app.use(
  '/api/transaction-number-series',
  transactionNumberSeriesRoutes
);

// ============================================================
// ITEMS
//
// /api/items
// ============================================================

app.use(
  '/api/items',
  itemsRoutes
);

// ============================================================
// PARTS
//
// /api/parts
// ============================================================

app.use(
  '/api/parts',
  partsRoutes
);

// ============================================================
// CUSTOMERS
//
// /api/customers
// ============================================================

app.use(
  '/api/customers',
  customersRoutes
);

// ============================================================
// ESTIMATES
//
// /api/estimates
// ============================================================

app.use(
  '/api/estimates',
  estimatesRoutes
);

// ============================================================
// SALES ORDERS
//
// /api/sales-orders
// ============================================================

app.use(
  '/api/sales-orders',
  salesOrdersRoutes
);

app.use('/api/invoices', invoicesRoutes);
app.use('/api/payments-received', paymentsReceivedRoutes);
app.use('/api/delivery-challans', deliveryChallansRoutes);

// ============================================================
// VENDORS
//
// /api/vendors
// ============================================================

app.use(
  '/api/vendors',
  vendorsRoutes
);

// ============================================================
// PURCHASE ORDERS
//
// /api/purchase-orders
// ============================================================

app.use(
  '/api/purchase-orders',
  purchaseOrdersRoutes
);

// ============================================================
// BILLS
//
// /api/bills
// ============================================================

app.use(
  '/api/bills',
  billsRoutes
);

// ============================================================
// USERS
//
// /api/users
// ============================================================

app.use(
  '/api/users',
  usersRoutes
);

// ============================================================
// ROLES
//
// /api/roles
// ============================================================

app.use(
  '/api/roles',
  rolesRoutes
);

// ============================================================
// EMAIL TEST
//
// /api/email-test
//
// GET  /api/email-test/verify
// POST /api/email-test/send
// ============================================================

app.use(
  '/api/email-test',
  emailTestRoutes
);

// ============================================================
// HEALTH
//
// GET /api/health
// ============================================================

app.get(
  '/api/health',
  (req, res) => {
    return res.status(200).json({
      success: true,

      message:
        'Codexia API is healthy',

      services: {
        backend: true,

        transactionNumberSeries:
          '/api/transaction-number-series',

        items:
          '/api/items',

        parts:
          '/api/parts',

        customers:
          '/api/customers',

        estimates:
          '/api/estimates',

        salesOrders:
          '/api/sales-orders',

        invoices:
          '/api/invoices',

        deliveryChallans:
          '/api/delivery-challans',

        vendors:
          '/api/vendors',

        purchaseOrders:
          '/api/purchase-orders',

        bills:
          '/api/bills',

        users:
          '/api/users',

        roles:
          '/api/roles',

        emailTest:
          '/api/email-test',
      },
    });
  }
);

// ============================================================
// 404
//
// This must stay AFTER all API routes.
// ============================================================

app.use(
  (req, res) => {
    return res.status(404).json({
      success: false,

      message:
        `API route not found: ${req.method} ${req.originalUrl}`,
    });
  }
);

// ============================================================
// GLOBAL ERROR HANDLER
//
// This must stay at the bottom before app.listen().
// ============================================================

app.use(
  (
    error,
    req,
    res,
    next
  ) => {
    console.error(
      'Unhandled server error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Internal server error',

      error:
        error.message,
    });
  }
);

// ============================================================
// START SERVER
// ============================================================

const PORT =
  Number(process.env.PORT) ||
  3000;

(async () => {
  try {
    await syncDatabase();

    app.listen(
      PORT,
      () => {
        console.log(
          '======================================================'
        );

        console.log(
          `Codexia backend running on http://localhost:${PORT}`
        );

        console.log(
          '------------------------------------------------------'
        );

        console.log(
          `DB Test              : http://localhost:${PORT}/api/test-db`
        );

        console.log(
          `MySQL Test           : http://localhost:${PORT}/api/mysql-test`
        );

        console.log(
          `Transaction Series   : http://localhost:${PORT}/api/transaction-number-series`
        );

        console.log(
          `Items                : http://localhost:${PORT}/api/items`
        );

        console.log(
          `Parts                : http://localhost:${PORT}/api/parts`
        );

        console.log(
          `Customers            : http://localhost:${PORT}/api/customers`
        );

        console.log(
          `Estimates            : http://localhost:${PORT}/api/estimates`
        );

        console.log(
          `Sales Orders         : http://localhost:${PORT}/api/sales-orders`
        );

        console.log(
          `Next Sales Order     : http://localhost:${PORT}/api/sales-orders/next-number`
        );

        console.log(
          `Vendors              : http://localhost:${PORT}/api/vendors`
        );

        console.log(
          `Purchase Orders      : http://localhost:${PORT}/api/purchase-orders`
        );

        console.log(
          `Next Purchase Order  : http://localhost:${PORT}/api/purchase-orders/next-number`
        );

        console.log(
          `Bills                : http://localhost:${PORT}/api/bills`
        );

        console.log(
          `Users                : http://localhost:${PORT}/api/users`
        );

        console.log(
          `Roles                : http://localhost:${PORT}/api/roles`
        );

        console.log(
          `Email Test           : http://localhost:${PORT}/api/email-test/verify`
        );

        console.log(
          `Health               : http://localhost:${PORT}/api/health`
        );

        console.log(
          '======================================================'
        );
      }
    );
  } catch (error) {
    console.error('Database sync failed before startup:', error.message);
    process.exitCode = 1;
    await db.end();
  }
})();
