const { test, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

let state;

class FakeConnection {
  constructor() { this.unlock = null; }
  async beginTransaction() {}
  async commit() {}
  async rollback() {}
  release() { this.unlock?.(); this.unlock = null; }
  async query(sql, params = []) { return queryState(sql, params, this); }
}

function queryState(sql, params = [], connection) {
  const text = sql.replace(/\s+/g, ' ').trim();
  if (/FROM sales_orders WHERE id\s*=\s*\? FOR UPDATE/.test(text)) {
    const previous = state.lockTails.get(params[0]) || Promise.resolve();
    let unlock;
    const hold = new Promise((resolve) => { unlock = resolve; });
    state.lockTails.set(params[0], previous.then(() => hold));
    return previous.then(() => {
      connection.unlock = unlock;
      return [state.order ? [state.order] : []];
    });
  }
  if (text.includes('FROM vendors WHERE id=?')) return [[state.vendor && Number(params[0]) === state.vendor.id ? state.vendor : null].filter(Boolean)];
  if (text.includes('FROM sales_order_items WHERE sales_order_id=?')) return [state.items];
  if (text.includes('FROM purchase_orders WHERE sales_order_id=?')) return [[state.purchaseOrder].filter(Boolean)];
  if (text.includes('FROM delivery_challans WHERE sales_order_id=?')) return [[state.challan].filter(Boolean)];
  if (text.includes('FROM invoices WHERE sales_order_id=?')) return [[state.invoice].filter(Boolean)];
  if (text.includes('FROM transaction_number_series')) {
    const module = params[0];
    const prefix = { 'Purchase Order': 'PO-', 'Delivery Challan': 'DC-', Invoice: 'INV-' }[module];
    return [[{ prefix, starting_number: 1 }]];
  }
  if (text.includes('SELECT MAX(')) return [[{ max_number: 0 }]];

  if (text.startsWith('INSERT INTO purchase_orders')) {
    const [po_number, vendor_id, vendor_name, delivery_expected_date, reference_number, sub_total, total, status, sales_order_id, sales_order_number] = params;
    state.purchaseOrder = { id: 51, po_number, vendor_id, vendor_name, order_date: '2026-10-08', delivery_expected_date,
      payment_terms: '100% Advance', due_date: null, reference_number, sub_total, total, status, sales_order_id, sales_order_number };
    state.purchaseOrderItems = [];
    return [{ insertId: 51 }];
  }
  if (text.startsWith('INSERT INTO purchase_order_items')) {
    const [purchase_order_id, source_type, item_id, part_id, item_name, description, qty, rate, amount] = params;
    state.purchaseOrderItems.push({ id: state.purchaseOrderItems.length + 1, purchase_order_id, source_type, item_id, part_id, item_name, description, qty, rate, amount });
    return [{ insertId: state.purchaseOrderItems.length }];
  }
  if (text.includes('FROM purchase_orders WHERE id=?')) return [[state.purchaseOrder].filter((row) => row && row.id === Number(params[0]))];
  if (text.includes('FROM purchase_order_items WHERE purchase_order_id=?')) return [state.purchaseOrderItems];

  if (text.startsWith('INSERT INTO delivery_challans')) {
    const [challan_number, sales_order_id, sales_order_number, estimate_id, estimate_number, customer_id, customer_name, notes, total] = params;
    state.challan = { id: 61, challan_number, invoice_id: null, invoice_number: null, sales_order_id, sales_order_number,
      estimate_id, estimate_number, customer_id, customer_name, challan_date: '2026-10-08', delivery_date: null,
      transportation_details: '', notes, total, status: 'Pending' };
    state.challanItems = [];
    return [{ insertId: 61 }];
  }
  if (text.startsWith('INSERT INTO delivery_challan_items')) {
    const [delivery_challan_id, source_type, item_id, part_id, item_name, description, qty, rate, amount] = params;
    state.challanItems.push({ id: state.challanItems.length + 1, delivery_challan_id, source_type, item_id, part_id, item_name, description, qty, rate, amount });
    return [{ insertId: state.challanItems.length }];
  }
  if (text.includes('FROM delivery_challans WHERE id=?')) return [[state.challan].filter((row) => row && row.id === Number(params[0]))];
  if (text.includes('FROM delivery_challan_items WHERE delivery_challan_id=?')) return [state.challanItems];

  if (text.startsWith('INSERT INTO invoices')) {
    const [invoice_number, sales_order_id, sales_order_number, estimate_id, estimate_number, customer_id, customer_name,
      sub_total, tax, total, notes, terms_and_conditions] = params;
    state.invoice = { id: 41, invoice_number, sales_order_id, sales_order_number, estimate_id, estimate_number, customer_id,
      customer_name, invoice_date: '2026-10-08', due_date: null, credit_terms: 'Immediate Payment', sub_total,
      tax, total, amount_paid: 0, notes, terms_and_conditions, approval_status: 'Pending' };
    state.invoiceItems = [];
    return [{ insertId: 41 }];
  }
  if (text.startsWith('INSERT INTO invoice_items')) {
    state.invoiceItems.push({ id: state.invoiceItems.length + 1 });
    return [{ insertId: state.invoiceItems.length }];
  }
  if (/FROM invoices WHERE id\s*=\s*\?/.test(text)) return [[state.invoice].filter((row) => row && row.id === Number(params[0]))];
  if (/FROM invoice_items WHERE invoice_id\s*=\s*\?/.test(text)) return [state.invoiceItems];
  throw new Error(`Unexpected mock SQL: ${text}`);
}

const mysql = require('mysql2/promise');
const fakePool = {
  getConnection: async () => new FakeConnection(),
  query: async (sql, params) => queryState(sql, params, new FakeConnection()),
};
mysql.createPool = () => fakePool;

const purchaseOrders = require('../routes/purchase_orders');
const challans = require('../routes/delivery_challans');
const invoices = require('../routes/invoices');

function handler(router, routePath) {
  const layer = router.stack.find((item) => item.route?.path === routePath && item.route.methods.post);
  assert.ok(layer, `POST ${routePath} route exists`);
  return layer.route.stack.at(-1).handle;
}

async function invoke(routeHandler, params = {}, body = {}) {
  const response = {
    statusCode: 200,
    status(code) { this.statusCode = code; return this; },
    json(value) { this.body = value; return this; },
  };
  await routeHandler({ params, body }, response);
  return response;
}

beforeEach(() => {
  state = {
    lockTails: new Map(), vendor: { id: 9, display_name: 'Explicit Vendor' },
    order: { id: 7, so_number: 'SO-0007', order_date: '2026-10-01', expected_shipment_date: '2026-10-20',
      estimate_id: 3, estimate_number: 'EST-0003', customer_id: 5, customer_name: 'Example Customer',
      sub_total: 125, total: 125, notes: 'Order note', terms_and_conditions: 'Terms', status: 'Confirmed', approval_status: 'Approved' },
    items: [{ id: 1, source_type: 'Item', item_id: 12, part_id: null, item_name: 'Widget', description: 'Blue', qty: 5, rate: 25, amount: 125 }],
    purchaseOrder: null, purchaseOrderItems: [], challan: null, challanItems: [], invoice: null, invoiceItems: [],
  };
});

test('unapproved Sales Orders are rejected by all three backend conversion routes before inserts', async () => {
  state.order.approval_status = 'Pending';
  const attempts = [
    invoke(handler(invoices, '/from-sales-order/:salesOrderId'), { salesOrderId: '7' }),
    invoke(handler(purchaseOrders, '/from-sales-order/:salesOrderId'), { salesOrderId: '7' }, { vendorId: '9' }),
    invoke(handler(challans, '/from-sales-order/:salesOrderId'), { salesOrderId: '7' }),
  ];
  const results = await Promise.all(attempts);
  for (const result of results) {
    assert.equal(result.statusCode, 409);
    assert.match(result.body.message, /Sales Order must be approved before/);
  }
  assert.equal(state.invoice, null);
  assert.equal(state.purchaseOrder, null);
  assert.equal(state.challan, null);
});

test('approved Sales Order converts to an Invoice once and repeated requests return the existing Invoice', async () => {
  const convert = handler(invoices, '/from-sales-order/:salesOrderId');
  const results = await Promise.all([
    invoke(convert, { salesOrderId: '7' }),
    invoke(convert, { salesOrderId: '7' }),
  ]);
  assert.deepEqual(results.map((result) => result.statusCode).sort(), [200, 201]);
  assert.equal(state.invoice.sales_order_id, 7);
  assert.equal(state.invoice.sales_order_number, 'SO-0007');
  assert.equal(state.invoice.invoice_number, 'INV-0001');
  assert.equal(state.invoiceItems.length, 1);
});

test('approved Sales Order converts to one Purchase Order with the selected vendor, including concurrent duplicate requests', async () => {
  const convert = handler(purchaseOrders, '/from-sales-order/:salesOrderId');
  const results = await Promise.all([
    invoke(convert, { salesOrderId: '7' }, { vendorId: '9' }),
    invoke(convert, { salesOrderId: '7' }, { vendorId: '9' }),
  ]);
  assert.deepEqual(results.map((result) => result.statusCode).sort(), [200, 201]);
  assert.equal(state.purchaseOrder.vendor_id, 9);
  assert.equal(state.purchaseOrder.vendor_name, 'Explicit Vendor');
  assert.equal(state.purchaseOrder.sales_order_id, 7);
  assert.equal(state.purchaseOrder.sales_order_number, 'SO-0007');
  assert.equal(state.purchaseOrder.po_number, 'PO-0001');
  assert.equal(state.purchaseOrderItems.length, 1);
});

test('Purchase Order conversion rejects a missing or unknown vendor', async () => {
  const convert = handler(purchaseOrders, '/from-sales-order/:salesOrderId');
  const missing = await invoke(convert, { salesOrderId: '7' }, {});
  assert.equal(missing.statusCode, 400);
  state.vendor = null;
  const unknown = await invoke(convert, { salesOrderId: '7' }, { vendorId: '9' });
  assert.equal(unknown.statusCode, 404);
  assert.equal(state.purchaseOrder, null);
});

test('approved Sales Order converts to one traceable Delivery Challan and concurrent requests reuse it', async () => {
  const convert = handler(challans, '/from-sales-order/:salesOrderId');
  const results = await Promise.all([
    invoke(convert, { salesOrderId: '7' }),
    invoke(convert, { salesOrderId: '7' }),
  ]);
  assert.deepEqual(results.map((result) => result.statusCode).sort(), [200, 201]);
  assert.equal(state.challan.sales_order_id, 7);
  assert.equal(state.challan.sales_order_number, 'SO-0007');
  assert.equal(state.challan.customer_id, 5);
  assert.equal(state.challan.customer_name, 'Example Customer');
  assert.equal(state.challan.challan_number, 'DC-0001');
  assert.equal(state.challanItems.length, 1);
});

test('workflow schema uses nullable unique Sales Order links without destructive statements', () => {
  const sql = fs.readFileSync(path.join(__dirname, '../database/sales_document_workflow.sql'), 'utf8');
  assert.match(sql, /uq_purchase_orders_sales_order_id/);
  assert.match(sql, /uq_delivery_challans_sales_order_id/);
  assert.doesNotMatch(sql, /\bDROP\s+(TABLE|COLUMN|INDEX)\b/i);
});
