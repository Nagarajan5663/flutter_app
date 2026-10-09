const express = require('express');
const db = require('../config/db');
const { getNextTransactionNumber } = require('../utils/transaction_number');
const { requireSalesWorkflowUser } = require('../middleware/workflow_auth');
const { sendEmail } = require('../utils/email');

const router = express.Router();
const PAYMENT_STATUSES = ['Unpaid', 'Partially Paid', 'Paid'];
const DOCUMENT_STATUSES = ['Draft', 'Sent', 'Void'];

function num(value, fallback = 0) {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function mapItem(row) {
  return {
    id: Number(row.id), sourceType: row.source_type,
    itemId: row.item_id == null ? null : Number(row.item_id),
    partId: row.part_id == null ? null : Number(row.part_id),
    itemName: row.item_name || '', description: row.description || '',
    quantity: num(row.qty), rate: num(row.rate), amount: num(row.amount),
  };
}

function paymentStatus(row) {
  const paid = num(row.amount_paid);
  const total = num(row.total);
  if (paid <= 0) return 'Unpaid';
  if (paid >= total) return 'Paid';
  return 'Partially Paid';
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  })[character]);
}

function mapInvoice(row, items = []) {
  return {
    id: Number(row.id), invoiceNumber: row.invoice_number,
    soId: row.sales_order_id == null ? null : String(row.sales_order_id),
    soNumber: row.sales_order_number || null,
    estimateId: row.estimate_id == null ? null : String(row.estimate_id),
    estimateNumber: row.estimate_number || null,
    customerId: String(row.customer_id), customerName: row.customer_name,
    customerEmail: row.customer_email || '',
    customerPhone: row.customer_phone || '',
    date: row.invoice_date, dueDate: row.due_date || null,
    creditTerms: row.credit_terms || 'Immediate Payment',
    items, subTotal: num(row.sub_total), tax: num(row.tax), total: num(row.total),
    amountPaid: num(row.amount_paid), amountDue: Math.max(0, num(row.total) - num(row.amount_paid)),
    status: paymentStatus(row), approvalStatus: row.approval_status || 'Pending',
    documentStatus: row.document_status || 'Draft',
    approvedAt: row.approved_at || null, approvedBy: row.approved_by == null ? null : Number(row.approved_by),
    deliveryChallanId: row.delivery_challan_id == null ? null : String(row.delivery_challan_id),
    deliveryChallanNumber: row.challan_number || null,
    notes: row.notes || '',
    termsAndConditions: row.terms_and_conditions || '',
  };
}

async function loadInvoice(queryable, id) {
  const [rows] = await queryable.query(`
    SELECT id,invoice_number,sales_order_id,sales_order_number,estimate_id,estimate_number,
      customer_id,customer_name,DATE_FORMAT(invoice_date,'%Y-%m-%d') AS invoice_date,
      DATE_FORMAT(due_date,'%Y-%m-%d') AS due_date,credit_terms,sub_total,tax,total,amount_paid,
      notes,terms_and_conditions,approval_status,document_status,approved_at,approved_by,
      (SELECT email FROM customers WHERE customers.id = invoices.customer_id) AS customer_email,
      (SELECT phone FROM customers WHERE customers.id = invoices.customer_id) AS customer_phone
      ,(SELECT id FROM delivery_challans WHERE invoice_id = invoices.id LIMIT 1) AS delivery_challan_id
      ,(SELECT challan_number FROM delivery_challans WHERE invoice_id = invoices.id LIMIT 1) AS challan_number
    FROM invoices WHERE id = ? LIMIT 1
  `, [id]);
  if (!rows.length) return null;
  const [items] = await queryable.query(`
    SELECT id,source_type,item_id,part_id,item_name,description,qty,rate,amount
    FROM invoice_items WHERE invoice_id = ? ORDER BY id ASC
  `, [id]);
  return mapInvoice(rows[0], items.map(mapItem));
}

function itemValues(line) {
  const sourceType = line.sourceType || 'Item';
  if (!['Item', 'Part'].includes(sourceType)) throw new Error('Invalid item source type.');
  const qty = num(line.quantity ?? line.qty);
  const rate = num(line.rate);
  if (qty <= 0 || rate < 0) throw new Error('Invoice quantities must be positive and rates cannot be negative.');
  const itemId = sourceType === 'Item' ? Number(line.itemId) || null : null;
  const partId = sourceType === 'Part' ? Number(line.partId ?? line.itemId) || null : null;
  return [sourceType, itemId, partId, String(line.itemName || '').trim(), String(line.description || ''), qty, rate, Number((qty * rate).toFixed(2))];
}

router.get('/next-number', async (req, res) => {
  try {
    const value = await getNextTransactionNumber({ module: 'Invoice', table: 'invoices', numberColumn: 'invoice_number' });
    return res.json({ success: true, data: { invoiceNumber: value.transactionNumber } });
  } catch (error) {
    return res.status(error.statusCode || 500).json({ success: false, message: error.message });
  }
});

router.get('/', async (req, res) => {
  try {
    const { status, customer, dateFrom, dateTo } = req.query;
    let sql = `SELECT id,invoice_number,sales_order_id,sales_order_number,estimate_id,estimate_number,customer_id,customer_name,
      DATE_FORMAT(invoice_date,'%Y-%m-%d') AS invoice_date,DATE_FORMAT(due_date,'%Y-%m-%d') AS due_date,
      credit_terms,sub_total,tax,total,amount_paid,notes,approval_status,document_status,approved_at,approved_by FROM invoices WHERE 1=1`;
    const values = [];
    if (customer) { sql += ' AND customer_name LIKE ?'; values.push(`%${customer}%`); }
    if (dateFrom) { sql += ' AND invoice_date >= ?'; values.push(dateFrom); }
    if (dateTo) { sql += ' AND invoice_date <= ?'; values.push(dateTo); }
    if (status && PAYMENT_STATUSES.includes(status)) {
      if (status === 'Unpaid') sql += ' AND amount_paid <= 0';
      if (status === 'Paid') sql += ' AND amount_paid >= total';
      if (status === 'Partially Paid') sql += ' AND amount_paid > 0 AND amount_paid < total';
    }
    if (status && DOCUMENT_STATUSES.includes(status)) {
      sql += ' AND document_status = ?';
      values.push(status);
    }
    sql += ' ORDER BY invoice_date DESC,id DESC';
    const [rows] = await db.query(sql, values);
    const data = [];
    for (const row of rows) data.push(await loadInvoice(db, row.id));
    return res.json({ success: true, data });
  } catch (error) {
    console.error('Get invoices error:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch invoices.' });
  }
});

router.post('/from-sales-order/:salesOrderId', requireSalesWorkflowUser, async (req, res) => {
  const sourceId = Number(req.params.salesOrderId);
  if (!Number.isInteger(sourceId) || sourceId <= 0) return res.status(400).json({ success: false, message: 'Invalid Sales Order ID.' });
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [orders] = await connection.query(`
      SELECT id,so_number,customer_id,customer_name,estimate_id,estimate_number,order_date,sub_total,total,notes,terms_and_conditions,status,approval_status
      FROM sales_orders WHERE id = ? FOR UPDATE
    `, [sourceId]);
    if (!orders.length) { await connection.rollback(); return res.status(404).json({ success: false, message: 'Sales Order not found.' }); }
    const order = orders[0];
    if (order.approval_status !== 'Approved') { await connection.rollback(); return res.status(409).json({ success: false, message: 'Sales Order must be approved before creating an Invoice.' }); }
    const [existing] = await connection.query('SELECT id FROM invoices WHERE sales_order_id=? LIMIT 1', [sourceId]);
    let invoiceId;
    const alreadyExists = existing.length > 0;
    if (alreadyExists) invoiceId = existing[0].id;
    else {
      if (order.status === 'Rejected') { await connection.rollback(); return res.status(409).json({ success: false, message: 'A Rejected Sales Order cannot be converted.' }); }
      const number = await getNextTransactionNumber({ module: 'Invoice', table: 'invoices', numberColumn: 'invoice_number', connection });
      const [created] = await connection.query(`
        INSERT INTO invoices (invoice_number,sales_order_id,sales_order_number,estimate_id,estimate_number,customer_id,customer_name,
          invoice_date,credit_terms,sub_total,tax,total,amount_paid,notes,terms_and_conditions,approval_status)
        VALUES (?,?,?,?,?,?,?,CURRENT_DATE(),'Immediate Payment',?,?,?,0,?,?,'Pending')
      `, [number.transactionNumber,order.id,order.so_number,order.estimate_id,order.estimate_number,order.customer_id,
        order.customer_name,order.sub_total,Number((num(order.total)-num(order.sub_total)).toFixed(2)),order.total,order.notes,order.terms_and_conditions]);
      invoiceId = created.insertId;
      const [sourceItems] = await connection.query('SELECT source_type,item_id,part_id,item_name,description,qty,rate,amount FROM sales_order_items WHERE sales_order_id=? ORDER BY id ASC', [sourceId]);
      for (const line of sourceItems) await connection.query(`
        INSERT INTO invoice_items (invoice_id,source_type,item_id,part_id,item_name,description,qty,rate,amount) VALUES (?,?,?,?,?,?,?,?,?)
      `, [invoiceId,line.source_type,line.item_id,line.part_id,line.item_name,line.description,line.qty,line.rate,line.amount]);
    }
    await connection.commit();
    return res.status(alreadyExists ? 200 : 201).json({ success: true, message: alreadyExists ? 'Existing Invoice returned.' : 'Invoice created from Sales Order.', data: await loadInvoice(db, invoiceId) });
  } catch (error) {
    try { await connection.rollback(); } catch (_) {}
    console.error('Convert Sales Order to Invoice error:', error);
    return res.status(500).json({ success: false, message: 'Failed to create Invoice from Sales Order.' });
  } finally { connection.release(); }
});

router.post('/:id/clone', async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ success: false, message: 'Invalid Invoice ID.' });
  }
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [rows] = await connection.query(
      'SELECT * FROM invoices WHERE id = ? FOR UPDATE',
      [id]
    );
    if (!rows.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Invoice not found.' });
    }
    const source = rows[0];
    const number = await getNextTransactionNumber({
      module: 'Invoice',
      table: 'invoices',
      numberColumn: 'invoice_number',
      connection,
    });
    const [created] = await connection.query(
      `INSERT INTO invoices (
        invoice_number, sales_order_id, sales_order_number, estimate_id,
        estimate_number, customer_id, customer_name, invoice_date, due_date,
        credit_terms, sub_total, tax, total, amount_paid, notes,
        terms_and_conditions, approval_status, document_status
      ) VALUES (?, NULL, NULL, NULL, NULL, ?, ?, CURRENT_DATE(), ?, ?, ?, ?, ?, 0, ?, ?, 'Pending', 'Draft')`,
      [
        number.transactionNumber,
        source.customer_id,
        source.customer_name,
        source.due_date,
        source.credit_terms,
        source.sub_total,
        source.tax,
        source.total,
        source.notes,
        source.terms_and_conditions,
      ]
    );
    await connection.query(
      `INSERT INTO invoice_items (
        invoice_id, source_type, item_id, part_id, item_name,
        description, qty, rate, amount
      )
      SELECT ?, source_type, item_id, part_id, item_name, description, qty, rate, amount
      FROM invoice_items WHERE invoice_id = ?`,
      [created.insertId, id]
    );
    await connection.commit();
    return res.status(201).json({
      success: true,
      data: await loadInvoice(db, created.insertId),
    });
  } catch (error) {
    try { await connection.rollback(); } catch (rollbackError) {
      console.error('Rollback invoice clone error:', rollbackError);
    }
    console.error('Clone invoice error:', error);
    return res.status(500).json({ success: false, message: 'Failed to clone invoice.' });
  } finally {
    connection.release();
  }
});

router.patch('/:id/status', async (req, res) => {
  const { status } = req.body;
  if (!DOCUMENT_STATUSES.includes(status)) {
    return res.status(400).json({
      success: false,
      message: 'Invoice status must be Draft, Sent, or Void.',
    });
  }
  try {
    const [result] = await db.query(
      'UPDATE invoices SET document_status = ? WHERE id = ?',
      [status, req.params.id]
    );
    if (!result.affectedRows) {
      const [existing] = await db.query(
        'SELECT id FROM invoices WHERE id = ? LIMIT 1',
        [req.params.id]
      );
      if (existing.length > 0) {
        return res.json({
          success: true,
          data: await loadInvoice(db, req.params.id),
        });
      }
      return res.status(404).json({ success: false, message: 'Invoice not found.' });
    }
    return res.json({ success: true, data: await loadInvoice(db, req.params.id) });
  } catch (error) {
    console.error('Update invoice status error:', error);
    return res.status(500).json({ success: false, message: 'Failed to update invoice status.' });
  }
});

router.post('/:id/email', async (req, res) => {
  const { subject } = req.body;
  if (typeof subject !== 'string' || !subject.trim() || subject.length > 200) {
    return res.status(400).json({ success: false, message: 'A valid email subject is required.' });
  }
  try {
    const invoice = await loadInvoice(db, req.params.id);
    if (!invoice) return res.status(404).json({ success: false, message: 'Invoice not found.' });
    if (!invoice.customerEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(invoice.customerEmail)) {
      return res.status(400).json({ success: false, message: 'This customer does not have a valid email address.' });
    }
    const itemRows = invoice.items.map((item) => `
      <tr><td>${escapeHtml(item.itemName)}</td><td>${escapeHtml(item.description)}</td>
      <td>${num(item.quantity).toFixed(2)}</td><td>INR ${num(item.rate).toFixed(2)}</td>
      <td>INR ${num(item.amount).toFixed(2)}</td></tr>
    `).join('');
    const notes = invoice.notes
      ? `<p><strong>Notes:</strong><br>${escapeHtml(invoice.notes).replace(/\r?\n/g, '<br>')}</p>`
      : '';
    const terms = invoice.termsAndConditions
      ? `<p><strong>Terms and Conditions:</strong><br>${escapeHtml(invoice.termsAndConditions).replace(/\r?\n/g, '<br>')}</p>`
      : '';
    const html = `
      <h2>Invoice ${escapeHtml(invoice.invoiceNumber)}</h2>
      <p>Customer: ${escapeHtml(invoice.customerName)}<br>
      Date: ${escapeHtml(invoice.date)}<br>
      Due date: ${escapeHtml(invoice.dueDate || '-')}<br>
      Sales Order: ${escapeHtml(invoice.soNumber || '-')}<br>
      Estimate: ${escapeHtml(invoice.estimateNumber || '-')}<br>
      Delivery Challan: ${escapeHtml(invoice.deliveryChallanNumber || '-')}<br>
      Document Status: ${escapeHtml(invoice.documentStatus)}<br>
      Approval Status: ${escapeHtml(invoice.approvalStatus)}<br>
      Payment Status: ${escapeHtml(invoice.status)}<br>
      Credit Terms: ${escapeHtml(invoice.creditTerms)}</p>
      <table border="1" cellpadding="6" cellspacing="0">
        <thead><tr><th>Item</th><th>Description</th><th>Qty</th><th>Rate</th><th>Amount</th></tr></thead>
        <tbody>${itemRows}</tbody>
      </table>
      <p>Subtotal: INR ${invoice.subTotal.toFixed(2)}<br>
      Tax: INR ${invoice.tax.toFixed(2)}<br>
      <strong>Total: INR ${invoice.total.toFixed(2)}</strong><br>
      Amount Paid: INR ${invoice.amountPaid.toFixed(2)}<br>
      Amount Due: INR ${invoice.amountDue.toFixed(2)}</p>
      ${notes}
      ${terms}
    `;
    await sendEmail(invoice.customerEmail, subject.trim(), html);
    return res.json({ success: true, message: 'Invoice email sent successfully.' });
  } catch (error) {
    console.error('Send invoice email error:', error);
    return res.status(500).json({ success: false, message: 'Failed to send invoice email.' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const invoice = await loadInvoice(db, Number(req.params.id));
    if (!invoice) return res.status(404).json({ success: false, message: 'Invoice not found.' });
    return res.json({ success: true, data: invoice });
  } catch (error) { return res.status(500).json({ success: false, message: 'Failed to fetch Invoice.' }); }
});

router.post('/:id/approve', requireSalesWorkflowUser, async (req, res) => {
  const id = Number(req.params.id);
  try {
    const [rows] = await db.query('SELECT id,approval_status FROM invoices WHERE id=? LIMIT 1', [id]);
    if (!rows.length) return res.status(404).json({ success: false, message: 'Invoice not found.' });
    if (rows[0].approval_status !== 'Approved') await db.query('UPDATE invoices SET approval_status=?,approved_at=NOW(),approved_by=? WHERE id=?', ['Approved',req.workflowUser.id,id]);
    return res.json({ success: true, data: await loadInvoice(db,id) });
  } catch (error) { console.error('Approve Invoice error:', error); return res.status(500).json({ success: false, message: 'Failed to approve Invoice.' }); }
});

router.post('/', (req, res) => res.status(409).json({
  success: false,
  message: 'Invoices must be created from an approved Sales Order using the workflow action.',
}));

router.put('/:id', async (req, res) => {
  const id = Number(req.params.id);
  const { date, dueDate, creditTerms, items = [], tax = 0, notes = '', termsAndConditions = '' } = req.body;
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [rows] = await connection.query('SELECT id,amount_paid,approval_status FROM invoices WHERE id=? FOR UPDATE', [id]);
    if (!rows.length) { await connection.rollback(); return res.status(404).json({ success: false, message: 'Invoice not found.' }); }
    if (rows[0].approval_status === 'Approved') { await connection.rollback(); return res.status(409).json({ success: false, message: 'Approved Invoices cannot be edited.' }); }
    if (num(tax) < 0) { await connection.rollback(); return res.status(400).json({ success: false, message: 'Tax cannot be negative.' }); }
    const safeItems = items.map(itemValues);
    const subTotal = Number(safeItems.reduce((sum, line) => sum + line[5] * line[6], 0).toFixed(2));
    const total = Number((subTotal + num(tax)).toFixed(2));
    await connection.query('DELETE FROM invoice_items WHERE invoice_id=?', [id]);
    for (const line of safeItems) await connection.query(`
      INSERT INTO invoice_items (invoice_id,source_type,item_id,part_id,item_name,description,qty,rate,amount)
      VALUES (?,?,?,?,?,?,?,?,?)
    `, [id,...line]);
    await connection.query('UPDATE invoices SET invoice_date=?,due_date=?,credit_terms=?,sub_total=?,tax=?,total=?,notes=?,terms_and_conditions=? WHERE id=?',
      [date,dueDate||null,creditTerms||'Immediate Payment',subTotal,num(tax),total,notes||null,termsAndConditions||null,id]);
    await connection.commit();
    return res.json({ success: true, data: await loadInvoice(db,id) });
  } catch (error) { try { await connection.rollback(); } catch (_) {} return res.status(400).json({ success: false, message: error.message || 'Failed to update Invoice.' }); }
  finally { connection.release(); }
});

router.delete('/:id', async (req, res) => {
  try {
    const [linked] = await db.query('SELECT id FROM delivery_challans WHERE invoice_id=? LIMIT 1', [req.params.id]);
    if (linked.length) return res.status(409).json({ success: false, message: 'Invoice has a Delivery Challan and cannot be deleted.' });
    const [result] = await db.query('DELETE FROM invoices WHERE id=?', [req.params.id]);
    if (!result.affectedRows) return res.status(404).json({ success: false, message: 'Invoice not found.' });
    return res.json({ success: true, message: 'Invoice deleted.' });
  } catch (error) { return res.status(500).json({ success: false, message: 'Failed to delete Invoice.' }); }
});

module.exports = router;
