
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const db = require('./config/db');

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

    if (res.headersSent) {
      return next(error);
    }

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
//
// Do not automatically execute SQL migration files.
// Existing tables are managed separately in phpMyAdmin.
// ============================================================

const PORT =
  Number(process.env.PORT) ||
  3000;

app.listen(
  PORT,
  '0.0.0.0',
  () => {
    console.log(
      '======================================================'
    );

    console.log(
      `Codexia backend running on port ${PORT}`
    );

    console.log(
      '------------------------------------------------------'
    );

    console.log(
      `DB Test              : /api/test-db`
    );

    console.log(
      `MySQL Test           : /api/mysql-test`
    );

    console.log(
      `Transaction Series   : /api/transaction-number-series`
    );

    console.log(
      `Items                : /api/items`
    );

    console.log(
      `Parts                : /api/parts`
    );

    console.log(
      `Customers            : /api/customers`
    );

    console.log(
      `Estimates            : /api/estimates`
    );

    console.log(
      `Sales Orders         : /api/sales-orders`
    );

    console.log(
      `Next Sales Order     : /api/sales-orders/next-number`
    );

    console.log(
      `Invoices             : /api/invoices`
    );

    console.log(
      `Payments Received    : /api/payments-received`
    );

    console.log(
      `Delivery Challans    : /api/delivery-challans`
    );

    console.log(
      `Vendors              : /api/vendors`
    );

    console.log(
      `Purchase Orders      : /api/purchase-orders`
    );

    console.log(
      `Next Purchase Order  : /api/purchase-orders/next-number`
    );

    console.log(
      `Bills                : /api/bills`
    );

    console.log(
      `Users                : /api/users`
    );

    console.log(
      `Roles                : /api/roles`
    );

    console.log(
      `Email Test           : /api/email-test/verify`
    );

    console.log(
      `Health               : /api/health`
    );

    console.log(
      '======================================================'
    );
  }
);
