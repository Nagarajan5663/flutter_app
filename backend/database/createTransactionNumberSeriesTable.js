const db = require('../config/db');

async function createTransactionNumberSeriesTable() {
  try {
    await db.query(`
      CREATE TABLE IF NOT EXISTS transaction_number_series (
        id INT AUTO_INCREMENT PRIMARY KEY,
        module VARCHAR(100) NOT NULL UNIQUE,
        prefix VARCHAR(50) DEFAULT '',
        starting_number INT NOT NULL DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          ON UPDATE CURRENT_TIMESTAMP
      )
    `);

    console.log(
      'transaction_number_series table ready'
    );
  } catch (error) {
    console.error(
      'Error creating transaction_number_series:',
      error.message
    );
  }
}

module.exports =
  createTransactionNumberSeriesTable;