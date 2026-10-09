const express = require('express');
const db = require('../config/db');
const { getNextTransactionNumber } = require('../utils/transaction_number');

const router = express.Router();

function mapPayment(row) {
  return {
    id: String(row.id),
    paymentNumber: row.payment_number,
    customerId: String(row.customer_id),
    customerName: row.customer_name,
    invoiceId: String(row.invoice_id),
    invoiceNumber: row.invoice_number,
    paymentDate: row.payment_date,
    amountReceived: Number(row.amount_received),
    paymentMode: row.payment_mode,
    utrReference: row.utr_reference || '',
    remarks: row.remarks || '',
  };
}

router.get('/next-number', async (req, res) => {
  try {
    const result = await getNextTransactionNumber({
      module: 'Payment Received',
      table: 'payment_received',
      numberColumn: 'payment_number',
    });
    return res.json({
      success: true,
      data: { paymentNumber: result.transactionNumber },
    });
  } catch (error) {
    console.error('Get next payment number error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Failed to generate payment number',
    });
  }
});

router.get('/', async (req, res) => {
  try {
    const { customer, invoice, dateFrom, dateTo } = req.query;
    let sql = `
      SELECT payment.id, payment.payment_number, payment.customer_id,
        customer.display_name AS customer_name, payment.invoice_id,
        invoice.invoice_number, DATE_FORMAT(payment.payment_date, '%Y-%m-%d') AS payment_date,
        payment.amount_received, payment.payment_mode, payment.utr_reference, payment.remarks
      FROM payment_received AS payment
      INNER JOIN customers AS customer ON customer.id = payment.customer_id
      INNER JOIN invoices AS invoice ON invoice.id = payment.invoice_id
      WHERE 1 = 1
    `;
    const values = [];

    if (customer) {
      sql += ' AND customer.display_name LIKE ?';
      values.push(`%${customer}%`);
    }
    if (invoice) {
      sql += ' AND invoice.invoice_number LIKE ?';
      values.push(`%${invoice}%`);
    }
    if (dateFrom) {
      sql += ' AND payment.payment_date >= ?';
      values.push(dateFrom);
    }
    if (dateTo) {
      sql += ' AND payment.payment_date <= ?';
      values.push(dateTo);
    }
    sql += ' ORDER BY payment.payment_date DESC, payment.id DESC';

    const [rows] = await db.query(sql, values);
    return res.json({ success: true, data: rows.map(mapPayment) });
  } catch (error) {
    console.error('Get payments received error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch payments received',
    });
  }
});

router.post('/', async (req, res) => {
  const {
    customerId,
    invoiceId,
    paymentDate,
    amountReceived,
    paymentMode,
    utrReference,
    remarks,
  } = req.body;
  const customerIdValue = Number(customerId);
  const invoiceIdValue = Number(invoiceId);
  const amount = Number(amountReceived);
  const date = typeof paymentDate === 'string' ? paymentDate.slice(0, 10) : '';

  if (
    !Number.isInteger(customerIdValue) ||
    customerIdValue <= 0 ||
    !Number.isInteger(invoiceIdValue) ||
    invoiceIdValue <= 0 ||
    !Number.isFinite(amount) ||
    amount <= 0 ||
    !/^\d{4}-\d{2}-\d{2}$/.test(date) ||
    !paymentMode
  ) {
    return res.status(400).json({
      success: false,
      message: 'A valid payment number, customer, invoice, date, amount, and mode are required.',
    });
  }

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const [invoices] = await connection.query(
      `
      SELECT id, customer_id, total, amount_paid
      FROM invoices
      WHERE id = ? AND customer_id = ?
      FOR UPDATE
      `,
      [invoiceIdValue, customerIdValue]
    );
    if (invoices.length === 0) {
      await connection.rollback();
      return res.status(404).json({
        success: false,
        message: 'Invoice not found for the selected customer.',
      });
    }
    const amountDue = Number(invoices[0].total) - Number(invoices[0].amount_paid);
    if (amount > amountDue) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: `Payment amount cannot exceed the invoice balance of ${amountDue.toFixed(2)}.`,
      });
    }

    const number = await getNextTransactionNumber({
      module: 'Payment Received',
      table: 'payment_received',
      numberColumn: 'payment_number',
      connection,
    });

    const [result] = await connection.query(
      `
      INSERT INTO payment_received (
        payment_number, customer_id, invoice_id, payment_date,
        amount_received, payment_mode, utr_reference, remarks
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        number.transactionNumber,
        customerIdValue,
        invoiceIdValue,
        date,
        amount,
        paymentMode,
        utrReference || null,
        remarks || null,
      ]
    );

    await connection.query(
      'UPDATE invoices SET amount_paid = LEAST(total, amount_paid + ?) WHERE id = ?',
      [amount, invoiceIdValue]
    );

    const [rows] = await connection.query(
      `
      SELECT payment.id, payment.payment_number, payment.customer_id,
        customer.display_name AS customer_name, payment.invoice_id,
        invoice.invoice_number, DATE_FORMAT(payment.payment_date, '%Y-%m-%d') AS payment_date,
        payment.amount_received, payment.payment_mode, payment.utr_reference, payment.remarks
      FROM payment_received AS payment
      INNER JOIN customers AS customer ON customer.id = payment.customer_id
      INNER JOIN invoices AS invoice ON invoice.id = payment.invoice_id
      WHERE payment.id = ?
      `,
      [result.insertId]
    );

    await connection.commit();
    return res.status(201).json({
      success: true,
      message: 'Payment recorded successfully',
      data: mapPayment(rows[0]),
    });
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error('Rollback payment received error:', rollbackError);
    }
    console.error('Create payment received error:', error);
    return res.status(500).json({
      success: false,
      message: error.code === 'ER_DUP_ENTRY'
        ? 'Payment number already exists.'
        : 'Failed to record payment',
    });
  } finally {
    connection.release();
  }
});

router.put('/:id', async (req, res) => {
  const amount = Number(req.body.amountReceived);
  const date = typeof req.body.paymentDate === 'string'
    ? req.body.paymentDate.slice(0, 10)
    : '';
  if (!Number.isFinite(amount) || amount <= 0 ||
      !/^\d{4}-\d{2}-\d{2}$/.test(date) ||
      typeof req.body.paymentMode !== 'string' || !req.body.paymentMode.trim()) {
    return res.status(400).json({
      success: false,
      message: 'A valid date, amount, and payment mode are required.',
    });
  }

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [payments] = await connection.query(
      `SELECT id, invoice_id, amount_received
       FROM payment_received WHERE id = ? FOR UPDATE`,
      [req.params.id]
    );
    if (!payments.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Payment not found.' });
    }

    const existing = payments[0];
    const [invoices] = await connection.query(
      `SELECT total, amount_paid FROM invoices WHERE id = ? FOR UPDATE`,
      [existing.invoice_id]
    );
    if (!invoices.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Invoice not found.' });
    }
    const available = Number(invoices[0].total) -
      Number(invoices[0].amount_paid) + Number(existing.amount_received);
    if (amount > available) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: `Payment amount cannot exceed the invoice balance of ${available.toFixed(2)}.`,
      });
    }

    await connection.query(
      `UPDATE payment_received
       SET payment_date = ?, amount_received = ?, payment_mode = ?,
         utr_reference = ?, remarks = ?
       WHERE id = ?`,
      [
        date,
        amount,
        req.body.paymentMode.trim(),
        req.body.utrReference || null,
        req.body.remarks || null,
        existing.id,
      ]
    );
    await connection.query(
      `UPDATE invoices
       SET amount_paid = GREATEST(0, amount_paid - ? + ?)
       WHERE id = ?`,
      [existing.amount_received, amount, existing.invoice_id]
    );
    await connection.commit();

    const [rows] = await connection.query(
      `SELECT payment.id, payment.payment_number, payment.customer_id,
        customer.display_name AS customer_name, payment.invoice_id,
        invoice.invoice_number,
        DATE_FORMAT(payment.payment_date, '%Y-%m-%d') AS payment_date,
        payment.amount_received, payment.payment_mode,
        payment.utr_reference, payment.remarks
       FROM payment_received AS payment
       INNER JOIN customers AS customer ON customer.id = payment.customer_id
       INNER JOIN invoices AS invoice ON invoice.id = payment.invoice_id
       WHERE payment.id = ?`,
      [existing.id]
    );
    return res.json({ success: true, data: mapPayment(rows[0]) });
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error('Rollback payment update error:', rollbackError);
    }
    console.error('Update payment received error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update payment',
    });
  } finally {
    connection.release();
  }
});

router.delete('/:id', async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const [payments] = await connection.query(
      `
      SELECT id, invoice_id, amount_received
      FROM payment_received
      WHERE id = ?
      FOR UPDATE
      `,
      [req.params.id]
    );
    if (payments.length === 0) {
      await connection.rollback();
      return res.status(404).json({
        success: false,
        message: 'Payment not found.',
      });
    }

    const payment = payments[0];
    await connection.query(
      'UPDATE invoices SET amount_paid = GREATEST(0, amount_paid - ?) WHERE id = ?',
      [payment.amount_received, payment.invoice_id]
    );
    await connection.query('DELETE FROM payment_received WHERE id = ?', [payment.id]);

    await connection.commit();
    return res.json({ success: true, message: 'Payment deleted.' });
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error('Rollback payment deletion error:', rollbackError);
    }
    console.error('Delete payment received error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete payment',
    });
  } finally {
    connection.release();
  }
});

module.exports = router;
