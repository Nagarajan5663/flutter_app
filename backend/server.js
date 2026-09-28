require('dotenv').config();

const express =
  require('express');

const cors =
  require('cors');

const db =
  require('./config/db');

// ============================================================
// ROUTES
// ============================================================

const transactionNumberSeriesRoutes =
  require(
    './routes/transaction_number_series'
  );

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

const vendorsRoutes =
  require('./routes/vendors');

const purchaseOrdersRoutes =
  require('./routes/purchase_orders');

const billsRoutes =
  require('./routes/bills');

// ============================================================
// APP
// ============================================================

const app =
  express();

// ============================================================
// MIDDLEWARE
// ============================================================

app.use(
  cors({
    origin:
      true,

    credentials:
      true,
  })
);

app.use(
  express.json({
    limit:
      '10mb',
  })
);

app.use(
  express.urlencoded({
    extended:
      true,

    limit:
      '10mb',
  })
);

// ============================================================
// ROOT
// ============================================================

app.get(
  '/',
  (req, res) => {
    res.status(200).json({
      success:
        true,

      message:
        'Codexia backend is running',
    });
  }
);

// ============================================================
// DATABASE TEST
// ============================================================

app.get(
  '/api/test-db',
  async (req, res) => {
    try {
      const [rows] =
        await db.query(
          `
          SELECT
            DATABASE()
              AS database_name,

            NOW()
              AS server_time
          `
        );

      return res
        .status(200)
        .json({
          success:
            true,

          message:
            'Hostinger MySQL connected successfully',

          data:
            rows[0],
        });
    } catch (error) {
      console.error(
        'Database test error:',
        error
      );

      return res
        .status(500)
        .json({
          success:
            false,

          message:
            'Database connection failed',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// MYSQL SIMPLE TEST
// ============================================================

app.get(
  '/api/mysql-test',
  async (req, res) => {
    try {
      const [rows] =
        await db.query(
          `
          SELECT 1 AS test
          `
        );

      return res
        .status(200)
        .json({
          success:
            true,

          message:
            'MySQL database connected successfully',

          data:
            rows,
        });
    } catch (error) {
      console.error(
        'MySQL test error:',
        error
      );

      return res
        .status(500)
        .json({
          success:
            false,

          message:
            'MySQL connection failed',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// TRANSACTION NUMBER SERIES
// ============================================================

app.use(
  '/api/transaction-number-series',
  transactionNumberSeriesRoutes
);

// ============================================================
// ITEMS
// ============================================================

app.use(
  '/api/items',
  itemsRoutes
);

// ============================================================
// PARTS
// ============================================================

app.use(
  '/api/parts',
  partsRoutes
);

// ============================================================
// CUSTOMERS
// ============================================================

app.use(
  '/api/customers',
  customersRoutes
);

// ============================================================
// ESTIMATES
// ============================================================

app.use(
  '/api/estimates',
  estimatesRoutes
);

// ============================================================
// SALES ORDERS
// ============================================================

app.use(
  '/api/sales-orders',
  salesOrdersRoutes
);

// ============================================================
// VENDORS
// ============================================================

app.use(
  '/api/vendors',
  vendorsRoutes
);

// ============================================================
// PURCHASE ORDERS
// ============================================================

app.use(
  '/api/purchase-orders',
  purchaseOrdersRoutes
);

// ============================================================
// BILLS
// ============================================================

app.use(
  '/api/bills',
  billsRoutes
);

// ============================================================
// HEALTH
// ============================================================

app.get(
  '/api/health',
  (req, res) => {
    res.status(200).json({
      success:
        true,

      message:
        'Codexia API is healthy',

      services: {
        backend:
          true,

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

        vendors:
          '/api/vendors',

        purchaseOrders:
          '/api/purchase-orders',

        bills:
          '/api/bills',
      },
    });
  }
);

// ============================================================
// 404
// ============================================================

app.use(
  (req, res) => {
    res.status(404).json({
      success:
        false,

      message:
        `API route not found: ${req.method} ${req.originalUrl}`,
    });
  }
);

// ============================================================
// GLOBAL ERROR HANDLER
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

    res.status(500).json({
      success:
        false,

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
  Number(
    process.env.PORT
  ) || 3000;

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
      `Health               : http://localhost:${PORT}/api/health`
    );

    console.log(
      '======================================================'
    );
  }
);