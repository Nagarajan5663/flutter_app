const express = require('express');
const db = require('../config/db');

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