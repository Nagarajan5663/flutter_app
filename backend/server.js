require('dotenv').config();

const express = require('express');
const cors = require('cors');

const db = require('./config/db');

const app = express();

app.use(cors());
app.use(express.json());


// TEST DB
app.get('/api/test-db', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT 1 AS connected'
    );

    res.json({
      success: true,
      message: 'Database connected',
      data: rows,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});


// CHECK TABLE
app.get(
  '/api/check-transaction-series',
  async (req, res) => {
    try {
      const [rows] = await db.query(
        "SHOW TABLES LIKE 'transaction_number_series'"
      );

      res.json({
        exists: rows.length > 0,
        result: rows,
      });
    } catch (error) {
      res.status(500).json({
        error: error.message,
      });
    }
  },
);


// GET TRANSACTION NUMBER SERIES
app.get(
  '/api/transaction-number-series',
  async (req, res) => {
    try {
      const [rows] = await db.query(
        'SELECT * FROM transaction_number_series ORDER BY id ASC'
      );

      res.json({
        success: true,
        data: rows,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  },
);


const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(
    `Server running on port ${PORT}`
  );
});