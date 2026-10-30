const express = require('express');
const db = require('../config/db');
const { sendEmail } = require('../utils/email');

const router = express.Router();

// ============================================================
// MYSQL ROW -> FLUTTER CUSTOMER MODEL
// ============================================================

function mapCustomer(row) {
  return {
    id: row.id?.toString() ?? null,

    vendorType: row.customer_type ?? 'Business',
    salutation: row.salutation ?? 'Mr.',
    firstName: row.first_name ?? '',
    lastName: row.last_name ?? '',
    website: row.website ?? '',
    gstApplicable: row.gst_applicable ?? 'No',

    billingStreet: row.billing_street ?? '',
    billingZip: row.billing_zip ?? '',

    shippingSameAsBilling:
      Number(row.shipping_same_as_billing) === 1,

    shippingStreet: row.shipping_street ?? '',
    shippingCity: row.shipping_city ?? '',
    shippingState: row.shipping_state ?? '',
    shippingZip: row.shipping_zip ?? '',
    shippingCountry: row.shipping_country ?? '',

    // Flutter currently uses vendorName
    // to represent Display Name
    vendorName: row.display_name ?? '',

    companyName: row.company_name ?? '',
    email: row.email ?? '',
    phone: row.phone ?? '',

    // Flutter currently uses city/state/country
    // for Billing Address
    city: row.billing_city ?? '',
    state: row.billing_state ?? '',
    country: row.billing_country ?? '',

    status: row.status ?? 'Active',
  };
}

function isValidDate(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }
  const date = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(date.getTime()) && date.toISOString().slice(0, 10) === value;
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

async function buildCustomerStatement(customerId, startDate, endDate) {
  const [customers] = await db.query(
    `
    SELECT id, display_name, email, billing_street, billing_city,
      billing_state, billing_zip, billing_country
    FROM customers
    WHERE id = ?
    LIMIT 1
    `,
    [customerId]
  );
  if (customers.length === 0) {
    const error = new Error('Customer not found');
    error.statusCode = 404;
    throw error;
  }

  const [invoices] = await db.query(
    `
    SELECT DATE_FORMAT(invoice_date, '%Y-%m-%d') AS date,
      invoice_number AS documentNumber,
      total AS charges, 0 AS credits
    FROM invoices
    WHERE customer_id = ? AND invoice_date <= ?
    `,
    [customerId, endDate]
  );

  let payments = [];
  try {
    [payments] = await db.query(
      `
      SELECT DATE_FORMAT(payment.payment_date, '%Y-%m-%d') AS date,
        invoice.invoice_number AS documentNumber,
        0 AS charges, payment.amount_received AS credits
      FROM payment_received AS payment
      INNER JOIN invoices AS invoice ON invoice.id = payment.invoice_id
      WHERE payment.customer_id = ? AND payment.payment_date <= ?
      `,
      [customerId, endDate]
    );
  } catch (error) {
    if (error.code !== 'ER_NO_SUCH_TABLE') throw error;
  }

  const transactions = [
    ...invoices.map((row) => ({
      ...row,
      type: 'Invoice',
      charges: Number(row.charges),
      credits: 0,
    })),
    ...payments.map((row) => ({
      ...row,
      type: 'Payment',
      charges: 0,
      credits: Number(row.credits),
    })),
  ].sort((left, right) =>
    String(left.date).localeCompare(String(right.date)) ||
    left.type.localeCompare(right.type) ||
    String(left.documentNumber).localeCompare(String(right.documentNumber))
  );

  const openingBalance = transactions
    .filter((row) => String(row.date).slice(0, 10) < startDate)
    .reduce((balance, row) => balance + row.charges - row.credits, 0);
  const periodTransactions = transactions.filter((row) => {
    const date = String(row.date).slice(0, 10);
    return date >= startDate && date <= endDate;
  });

  let balance = openingBalance;
  let totalCharges = 0;
  let totalCredits = 0;
  const rows = periodTransactions.map((row) => {
    totalCharges += row.charges;
    totalCredits += row.credits;
    balance += row.charges - row.credits;
    return {
      date: String(row.date).slice(0, 10),
      type: row.type,
      documentNumber: row.documentNumber,
      charges: row.charges,
      credits: row.credits,
      balance,
    };
  });

  return {
    customer: {
      name: customers[0].display_name,
      email: customers[0].email || '',
      address: [
        customers[0].billing_street,
        [customers[0].billing_city, customers[0].billing_state,
          customers[0].billing_zip].filter(Boolean).join(', '),
        customers[0].billing_country,
      ].filter(Boolean),
    },
    startDate,
    endDate,
    openingBalance,
    totalCharges,
    totalCredits,
    closingBalance: balance,
    rows,
  };
}

function statementEmailHtml(statement) {
  const money = (amount) => `INR ${Number(amount).toFixed(2)}`;
  const rows = statement.rows.map((row) => `
    <tr>
      <td>${escapeHtml(row.date)}</td>
      <td>${escapeHtml(row.type)}</td>
      <td>${escapeHtml(row.documentNumber)}</td>
      <td style="text-align:right">${row.charges ? money(row.charges) : '-'}</td>
      <td style="text-align:right">${row.credits ? money(row.credits) : '-'}</td>
      <td style="text-align:right">${money(row.balance)}</td>
    </tr>
  `).join('');
  return `
    <h2>Customer Statement</h2>
    <p><strong>Statement For:</strong> ${escapeHtml(statement.customer.name)}<br>
      ${statement.customer.address.map(escapeHtml).join('<br>')}<br>
      ${escapeHtml(statement.customer.email)}</p>
    <p><strong>Statement Period:</strong> ${escapeHtml(statement.startDate)} to ${escapeHtml(statement.endDate)}</p>
    <table style="border-collapse:collapse;width:100%" border="1" cellpadding="8">
      <thead><tr><th>Date</th><th>Type</th><th>Document #</th><th>Charges (Dr)</th><th>Credits (Cr)</th><th>Balance</th></tr></thead>
      <tbody>
        <tr><td colspan="5"><strong>Opening Balance</strong></td><td>${money(statement.openingBalance)}</td></tr>
        ${rows}
        <tr><td colspan="3"><strong>Period Totals</strong></td><td>${money(statement.totalCharges)}</td><td>${money(statement.totalCredits)}</td><td></td></tr>
        <tr><td colspan="5"><strong>Closing Balance</strong></td><td>${money(statement.closingBalance)}</td></tr>
      </tbody>
    </table>
    <p>This is an automatically generated Customer Statement.</p>
  `;
}

// ============================================================
// GET ALL CUSTOMERS
// GET /api/customers
//
// Optional filters:
// ?status=Active
// ?city=Chennai
// ?state=Tamil Nadu
// ?country=India
// ============================================================

router.get('/', async (req, res) => {
  try {
    const {
      status,
      city,
      state,
      country,
    } = req.query;

    let sql = `
      SELECT *
      FROM customers
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

      values.push(status);
    }

    if (
      city &&
      city.trim() !== ''
    ) {
      sql += `
        AND billing_city LIKE ?
      `;

      values.push(
        `%${city.trim()}%`
      );
    }

    if (
      state &&
      state.trim() !== ''
    ) {
      sql += `
        AND billing_state LIKE ?
      `;

      values.push(
        `%${state.trim()}%`
      );
    }

    if (
      country &&
      country.trim() !== ''
    ) {
      sql += `
        AND billing_country LIKE ?
      `;

      values.push(
        `%${country.trim()}%`
      );
    }

    sql += `
      ORDER BY id DESC
    `;

    const [rows] = await db.query(
      sql,
      values
    );

    res.status(200).json({
      success: true,
      data: rows.map(mapCustomer),
    });
  } catch (error) {
    console.error(
      'Get customers error:',
      error
    );

    res.status(500).json({
      success: false,
      message:
        'Failed to fetch customers',
      error: error.message,
    });
  }
});

// ============================================================
// GET SINGLE CUSTOMER
// GET /api/customers/:id
// ============================================================

router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `
      SELECT *
      FROM customers
      WHERE id = ?
      LIMIT 1
      `,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message:
          'Customer not found',
      });
    }

    res.status(200).json({
      success: true,
      data: mapCustomer(rows[0]),
    });
  } catch (error) {
    console.error(
      'Get customer error:',
      error
    );

    res.status(500).json({
      success: false,
      message:
        'Failed to fetch customer',
      error: error.message,
    });
  }
});

// ============================================================
// CUSTOMER INTERNAL COMMENTS
// ============================================================

router.get('/:id/comments', async (req, res) => {
  try {
    const { id } = req.params;

    const [customerRows] = await db.query(
      'SELECT id FROM customers WHERE id = ? LIMIT 1',
      [id]
    );

    if (customerRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found',
      });
    }

    const [rows] = await db.query(
      `
      SELECT id, comment, created_at
      FROM customer_comments
      WHERE customer_id = ?
      ORDER BY created_at DESC, id DESC
      `,
      [id]
    );

    return res.status(200).json({
      success: true,
      data: rows.map((row) => ({
        id: row.id,
        comment: row.comment,
        createdAt: row.created_at,
      })),
    });
  } catch (error) {
    console.error('Get customer comments error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch customer comments',
      error: error.message,
    });
  }
});

router.post('/:id/comments', async (req, res) => {
  try {
    const { id } = req.params;
    const comment =
      typeof req.body.comment === 'string' ? req.body.comment.trim() : '';

    if (!comment) {
      return res.status(400).json({
        success: false,
        message: 'Comment cannot be empty',
      });
    }

    if (comment.length > 10000) {
      return res.status(400).json({
        success: false,
        message: 'Comment cannot exceed 10000 characters',
      });
    }

    const [customerRows] = await db.query(
      'SELECT id FROM customers WHERE id = ? LIMIT 1',
      [id]
    );

    if (customerRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found',
      });
    }

    const [result] = await db.query(
      `
      INSERT INTO customer_comments (customer_id, comment)
      VALUES (?, ?)
      `,
      [id, comment]
    );

    const [rows] = await db.query(
      `
      SELECT id, comment, created_at
      FROM customer_comments
      WHERE id = ?
      LIMIT 1
      `,
      [result.insertId]
    );

    return res.status(201).json({
      success: true,
      message: 'Customer comment saved successfully',
      data: {
        id: rows[0].id,
        comment: rows[0].comment,
        createdAt: rows[0].created_at,
      },
    });
  } catch (error) {
    console.error('Save customer comment error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to save customer comment',
      error: error.message,
    });
  }
});

router.get('/:id/transactions', async (req, res) => {
  try {
    const { id } = req.params;
    const [customerRows] = await db.query(
      'SELECT id FROM customers WHERE id = ? LIMIT 1',
      [id]
    );

    if (customerRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Customer not found',
      });
    }

    const [estimates] = await db.query(
      `
      SELECT
        DATE_FORMAT(estimate_date, '%Y-%m-%d') AS date,
        estimate_number AS number,
        total AS amount,
        status
      FROM estimates
      WHERE customer_id = ?
      ORDER BY estimate_date DESC, id DESC
      `,
      [id]
    );

    const [salesOrders] = await db.query(
      `
      SELECT
        DATE_FORMAT(so.order_date, '%Y-%m-%d') AS date,
        so.so_number AS number,
        so.total AS amount,
        CASE WHEN invoice.id IS NOT NULL THEN 'Invoiced' ELSE so.status END AS status
      FROM sales_orders AS so
      LEFT JOIN invoices AS invoice ON invoice.sales_order_id = so.id
      WHERE so.customer_id = ?
      ORDER BY so.order_date DESC, so.id DESC
      `,
      [id]
    );

    const [invoices] = await db.query(
      `
      SELECT
        DATE_FORMAT(invoice_date, '%Y-%m-%d') AS date,
        invoice_number AS number,
        total AS amount,
        CASE
          WHEN amount_paid <= 0 THEN 'Unpaid'
          WHEN amount_paid >= total THEN 'Paid'
          ELSE 'Partially Paid'
        END AS status
      FROM invoices
      WHERE customer_id = ?
      ORDER BY invoice_date DESC, id DESC
      `,
      [id]
    );

    let payments = [];
    let paymentsAvailable = true;
    try {
      [payments] = await db.query(
        `
        SELECT
          DATE_FORMAT(payment.payment_date, '%Y-%m-%d') AS date,
          invoice.invoice_number AS invoiceNumber,
          payment.utr_reference AS utrReference,
          payment.amount_received AS amount
        FROM payment_received AS payment
        INNER JOIN invoices AS invoice ON invoice.id = payment.invoice_id
        WHERE payment.customer_id = ?
        ORDER BY payment.payment_date DESC, payment.id DESC
        `,
        [id]
      );
    } catch (error) {
      if (error.code !== 'ER_NO_SUCH_TABLE') {
        throw error;
      }
      paymentsAvailable = false;
      console.warn(
        'Customer payment transactions are unavailable: payment_received table is missing.'
      );
    }

    return res.status(200).json({
      success: true,
      data: { estimates, salesOrders, invoices, payments, paymentsAvailable },
    });
  } catch (error) {
    console.error('Get customer transactions error:', error);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch customer transactions',
      error: error.message,
    });
  }
});

router.get('/:id/statement', async (req, res) => {
  const { startDate, endDate } = req.query;
  if (
    !isValidDate(startDate) ||
    !isValidDate(endDate) ||
    startDate > endDate
  ) {
    return res.status(400).json({
      success: false,
      message: 'A valid start date and end date are required.',
    });
  }

  try {
    const statement = await buildCustomerStatement(
      req.params.id,
      startDate,
      endDate
    );
    return res.status(200).json({ success: true, data: statement });
  } catch (error) {
    console.error('Get customer statement error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Failed to generate customer statement.',
    });
  }
});

router.post('/:id/statement/email', async (req, res) => {
  const { startDate, endDate, recipientEmail, subject } = req.body;
  if (
    !isValidDate(startDate) ||
    !isValidDate(endDate) ||
    startDate > endDate
  ) {
    return res.status(400).json({
      success: false,
      message: 'A valid start date and end date are required.',
    });
  }
  if (
    typeof recipientEmail !== 'string' ||
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(recipientEmail.trim())
  ) {
    return res.status(400).json({
      success: false,
      message: 'A valid recipient email is required.',
    });
  }
  if (typeof subject !== 'string' || !subject.trim() || subject.length > 200) {
    return res.status(400).json({
      success: false,
      message: 'A subject between 1 and 200 characters is required.',
    });
  }

  try {
    const statement = await buildCustomerStatement(
      req.params.id,
      startDate,
      endDate
    );
    await sendEmail(
      recipientEmail.trim(),
      subject.trim(),
      statementEmailHtml(statement)
    );
    return res.status(200).json({
      success: true,
      message: 'Customer statement email sent successfully.',
    });
  } catch (error) {
    console.error('Send customer statement email error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || 'Failed to send customer statement email.',
    });
  }
});

// ============================================================
// CREATE CUSTOMER
// POST /api/customers
// ============================================================

router.post('/', async (req, res) => {
  try {
    const {
      vendorType,
      salutation,
      firstName,
      lastName,
      website,
      gstApplicable,

      billingStreet,
      billingZip,

      shippingSameAsBilling,
      shippingStreet,
      shippingCity,
      shippingState,
      shippingZip,
      shippingCountry,

      vendorName,
      companyName,
      email,
      phone,

      city,
      state,
      country,

      status,
    } = req.body;

    // Display Name is required
    if (
      !vendorName ||
      vendorName.trim() === ''
    ) {
      return res.status(400).json({
        success: false,
        message:
          'Customer display name is required',
      });
    }

    const customerType =
      vendorType || 'Business';

    const customerSalutation =
      salutation || 'Mr.';

    const customerGst =
      gstApplicable || 'No';

    const customerStatus =
      status || 'Active';

    const sameAsBilling =
      shippingSameAsBilling === true ||
      shippingSameAsBilling === 1 ||
      shippingSameAsBilling === '1';

    // If same as billing,
    // automatically use billing values
    const finalShippingStreet =
      sameAsBilling
        ? billingStreet || null
        : shippingStreet || null;

    const finalShippingCity =
      sameAsBilling
        ? city || null
        : shippingCity || null;

    const finalShippingState =
      sameAsBilling
        ? state || null
        : shippingState || null;

    const finalShippingZip =
      sameAsBilling
        ? billingZip || null
        : shippingZip || null;

    const finalShippingCountry =
      sameAsBilling
        ? country || null
        : shippingCountry || null;

    const [result] = await db.query(
      `
      INSERT INTO customers (
        customer_type,
        salutation,
        first_name,
        last_name,
        display_name,
        company_name,
        email,
        phone,
        website,
        gst_applicable,

        billing_street,
        billing_city,
        billing_state,
        billing_zip,
        billing_country,

        shipping_same_as_billing,
        shipping_street,
        shipping_city,
        shipping_state,
        shipping_zip,
        shipping_country,

        status
      )
      VALUES (
        ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
        ?, ?, ?, ?, ?,
        ?, ?, ?, ?, ?, ?,
        ?
      )
      `,
      [
        customerType,
        customerSalutation,
        firstName || null,
        lastName || null,
        vendorName.trim(),
        companyName || null,
        email || null,
        phone || null,
        website || null,
        customerGst,

        billingStreet || null,
        city || null,
        state || null,
        billingZip || null,
        country || null,

        sameAsBilling ? 1 : 0,
        finalShippingStreet,
        finalShippingCity,
        finalShippingState,
        finalShippingZip,
        finalShippingCountry,

        customerStatus,
      ]
    );

    const [rows] = await db.query(
      `
      SELECT *
      FROM customers
      WHERE id = ?
      `,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message:
        'Customer created successfully',
      data: mapCustomer(rows[0]),
    });
  } catch (error) {
    console.error(
      'Create customer error:',
      error
    );

    res.status(500).json({
      success: false,
      message:
        'Failed to create customer',
      error: error.message,
    });
  }
});

// ============================================================
// UPDATE CUSTOMER
// PUT /api/customers/:id
// ============================================================

router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const {
      vendorType,
      salutation,
      firstName,
      lastName,
      website,
      gstApplicable,

      billingStreet,
      billingZip,

      shippingSameAsBilling,
      shippingStreet,
      shippingCity,
      shippingState,
      shippingZip,
      shippingCountry,

      vendorName,
      companyName,
      email,
      phone,

      city,
      state,
      country,

      status,
    } = req.body;

    if (
      !vendorName ||
      vendorName.trim() === ''
    ) {
      return res.status(400).json({
        success: false,
        message:
          'Customer display name is required',
      });
    }

    const sameAsBilling =
      shippingSameAsBilling === true ||
      shippingSameAsBilling === 1 ||
      shippingSameAsBilling === '1';

    const finalShippingStreet =
      sameAsBilling
        ? billingStreet || null
        : shippingStreet || null;

    const finalShippingCity =
      sameAsBilling
        ? city || null
        : shippingCity || null;

    const finalShippingState =
      sameAsBilling
        ? state || null
        : shippingState || null;

    const finalShippingZip =
      sameAsBilling
        ? billingZip || null
        : shippingZip || null;

    const finalShippingCountry =
      sameAsBilling
        ? country || null
        : shippingCountry || null;

    const [result] = await db.query(
      `
      UPDATE customers
      SET
        customer_type = ?,
        salutation = ?,
        first_name = ?,
        last_name = ?,
        display_name = ?,
        company_name = ?,
        email = ?,
        phone = ?,
        website = ?,
        gst_applicable = ?,

        billing_street = ?,
        billing_city = ?,
        billing_state = ?,
        billing_zip = ?,
        billing_country = ?,

        shipping_same_as_billing = ?,
        shipping_street = ?,
        shipping_city = ?,
        shipping_state = ?,
        shipping_zip = ?,
        shipping_country = ?,

        status = ?

      WHERE id = ?
      `,
      [
        vendorType || 'Business',
        salutation || 'Mr.',
        firstName || null,
        lastName || null,
        vendorName.trim(),
        companyName || null,
        email || null,
        phone || null,
        website || null,
        gstApplicable || 'No',

        billingStreet || null,
        city || null,
        state || null,
        billingZip || null,
        country || null,

        sameAsBilling ? 1 : 0,
        finalShippingStreet,
        finalShippingCity,
        finalShippingState,
        finalShippingZip,
        finalShippingCountry,

        status || 'Active',

        id,
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message:
          'Customer not found',
      });
    }

    const [rows] = await db.query(
      `
      SELECT *
      FROM customers
      WHERE id = ?
      `,
      [id]
    );

    res.status(200).json({
      success: true,
      message:
        'Customer updated successfully',
      data: mapCustomer(rows[0]),
    });
  } catch (error) {
    console.error(
      'Update customer error:',
      error
    );

    res.status(500).json({
      success: false,
      message:
        'Failed to update customer',
      error: error.message,
    });
  }
});

// ============================================================
// DELETE CUSTOMER
// DELETE /api/customers/:id
// ============================================================

router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await db.query(
      `
      DELETE FROM customers
      WHERE id = ?
      `,
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message:
          'Customer not found',
      });
    }

    res.status(200).json({
      success: true,
      message:
        'Customer deleted successfully',
    });
  } catch (error) {
    console.error(
      'Delete customer error:',
      error
    );

    res.status(500).json({
      success: false,
      message:
        'Failed to delete customer',
      error: error.message,
    });
  }
});

module.exports = router;