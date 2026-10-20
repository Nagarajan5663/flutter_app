require('dotenv').config();
const mysql = require('mysql2/promise');

async function test() {
  let connection;

  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT || 3306),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      connectTimeout: 10000,
    });

    console.log('MySQL authentication successful!');
  } catch (error) {
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);
  } finally {
    if (connection) await connection.end();
  }
}

test();