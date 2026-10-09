const express = require('express');
const db = require('../config/db');

const router = express.Router();

// ============================================================
// HELPER
// ============================================================

function mapVendor(row) {
  return {
    id:
      row.id?.toString() ?? null,

    vendorType:
      row.vendor_type ?? 'Business',

    salutation:
      row.salutation ?? 'Mr.',

    firstName:
      row.first_name ?? '',

    lastName:
      row.last_name ?? '',

    website:
      row.website ?? '',

    gstApplicable:
      row.gst_applicable ?? 'No',

    billingStreet:
      row.billing_street ?? '',

    billingZip:
      row.billing_zip ?? '',

    shippingSameAsBilling:
      Number(
        row.shipping_same_as_billing
      ) === 1,

    shippingStreet:
      row.shipping_street ?? '',

    shippingCity:
      row.shipping_city ?? '',

    shippingState:
      row.shipping_state ?? '',

    shippingZip:
      row.shipping_zip ?? '',

    shippingCountry:
      row.shipping_country ?? '',

    // Display Name
    vendorName:
      row.display_name ?? '',

    companyName:
      row.company_name ?? '',

    email:
      row.email ?? '',

    phone:
      row.phone ?? '',

    // Billing City / State / Country
    city:
      row.billing_city ?? '',

    state:
      row.billing_state ?? '',

    country:
      row.billing_country ?? '',

    status:
      row.status ?? 'Active',
  };
}

// ============================================================
// GET ALL VENDORS
//
// GET /api/vendors
//
// Optional:
// /api/vendors?status=Active
// /api/vendors?city=Chennai
// /api/vendors?state=Tamilnadu
// /api/vendors?country=India
// ============================================================

router.get(
  '/',
  async (req, res) => {
    try {
      const {
        status,
        city,
        state,
        country,
      } = req.query;

      let sql = `
        SELECT
          id,
          vendor_type,
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

          status,
          created_at,
          updated_at

        FROM vendors

        WHERE 1 = 1
      `;

      const values = [];

      // --------------------------------------------------------
      // STATUS FILTER
      // --------------------------------------------------------

      if (
        status &&
        status !== 'All'
      ) {
        sql += `
          AND status = ?
        `;

        values.push(
          status
        );
      }

      // --------------------------------------------------------
      // CITY FILTER
      // --------------------------------------------------------

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

      // --------------------------------------------------------
      // STATE FILTER
      // --------------------------------------------------------

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

      // --------------------------------------------------------
      // COUNTRY FILTER
      // --------------------------------------------------------

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

      const [rows] =
        await db.query(
          sql,
          values
        );

      res.status(200).json({
        success: true,

        data:
          rows.map(
            mapVendor
          ),
      });
    } catch (error) {
      console.error(
        'Get vendors error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to fetch vendors',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// GET SINGLE VENDOR
//
// GET /api/vendors/:id
// ============================================================

router.get(
  '/:id',
  async (req, res) => {
    try {
      const { id } =
        req.params;

      const [rows] =
        await db.query(
          `
          SELECT
            id,
            vendor_type,
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

            status,
            created_at,
            updated_at

          FROM vendors

          WHERE id = ?

          LIMIT 1
          `,
          [id]
        );

      if (
        rows.length === 0
      ) {
        return res
            .status(404)
            .json({
          success: false,

          message:
            'Vendor not found',
        });
      }

      res.status(200).json({
        success: true,

        data:
          mapVendor(
            rows[0]
          ),
      });
    } catch (error) {
      console.error(
        'Get vendor error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to fetch vendor',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// CREATE VENDOR
//
// POST /api/vendors
// ============================================================

router.post(
  '/',
  async (req, res) => {
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

      // --------------------------------------------------------
      // VALIDATE DISPLAY NAME
      // --------------------------------------------------------

      if (
        !vendorName ||
        vendorName
            .trim() === ''
      ) {
        return res
            .status(400)
            .json({
          success: false,

          message:
            'Vendor display name is required',
        });
      }

      const finalShippingSameAsBilling =
        shippingSameAsBilling === true ||
        shippingSameAsBilling === 1 ||
        shippingSameAsBilling === '1';

      const finalBillingStreet =
        billingStreet?.trim() ?? '';

      const finalBillingCity =
        city?.trim() ?? '';

      const finalBillingState =
        state?.trim() ?? '';

      const finalBillingZip =
        billingZip?.trim() ?? '';

      const finalBillingCountry =
        country?.trim() ?? '';

      const finalShippingStreet =
        finalShippingSameAsBilling
          ? finalBillingStreet
          : shippingStreet?.trim() ?? '';

      const finalShippingCity =
        finalShippingSameAsBilling
          ? finalBillingCity
          : shippingCity?.trim() ?? '';

      const finalShippingState =
        finalShippingSameAsBilling
          ? finalBillingState
          : shippingState?.trim() ?? '';

      const finalShippingZip =
        finalShippingSameAsBilling
          ? finalBillingZip
          : shippingZip?.trim() ?? '';

      const finalShippingCountry =
        finalShippingSameAsBilling
          ? finalBillingCountry
          : shippingCountry?.trim() ?? '';

      // --------------------------------------------------------
      // INSERT
      // --------------------------------------------------------

      const [result] =
        await db.query(
          `
          INSERT INTO vendors (
            vendor_type,
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
            ?, ?, ?, ?,
            ?, ?,
            ?, ?, ?,
            ?,
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?, ?,
            ?
          )
          `,
          [
            vendorType ||
              'Business',

            salutation ||
              'Mr.',

            firstName?.trim() ||
              null,

            lastName?.trim() ||
              null,

            vendorName.trim(),

            companyName?.trim() ||
              null,

            email?.trim() ||
              null,

            phone?.trim() ||
              null,

            website?.trim() ||
              null,

            gstApplicable ||
              'No',

            finalBillingStreet ||
              null,

            finalBillingCity ||
              null,

            finalBillingState ||
              null,

            finalBillingZip ||
              null,

            finalBillingCountry ||
              null,

            finalShippingSameAsBilling
              ? 1
              : 0,

            finalShippingStreet ||
              null,

            finalShippingCity ||
              null,

            finalShippingState ||
              null,

            finalShippingZip ||
              null,

            finalShippingCountry ||
              null,

            status ||
              'Active',
          ]
        );

      // --------------------------------------------------------
      // RETURN CREATED VENDOR
      // --------------------------------------------------------

      const [rows] =
        await db.query(
          `
          SELECT *

          FROM vendors

          WHERE id = ?

          LIMIT 1
          `,
          [
            result.insertId
          ]
        );

      res.status(201).json({
        success: true,

        message:
          'Vendor created successfully',

        data:
          mapVendor(
            rows[0]
          ),
      });
    } catch (error) {
      console.error(
        'Create vendor error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to create vendor',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// UPDATE VENDOR
//
// PUT /api/vendors/:id
// ============================================================

router.put(
  '/:id',
  async (req, res) => {
    try {
      const { id } =
        req.params;

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
        vendorName
            .trim() === ''
      ) {
        return res
            .status(400)
            .json({
          success: false,

          message:
            'Vendor display name is required',
        });
      }

      const finalShippingSameAsBilling =
        shippingSameAsBilling === true ||
        shippingSameAsBilling === 1 ||
        shippingSameAsBilling === '1';

      const finalBillingStreet =
        billingStreet?.trim() ?? '';

      const finalBillingCity =
        city?.trim() ?? '';

      const finalBillingState =
        state?.trim() ?? '';

      const finalBillingZip =
        billingZip?.trim() ?? '';

      const finalBillingCountry =
        country?.trim() ?? '';

      const finalShippingStreet =
        finalShippingSameAsBilling
          ? finalBillingStreet
          : shippingStreet?.trim() ?? '';

      const finalShippingCity =
        finalShippingSameAsBilling
          ? finalBillingCity
          : shippingCity?.trim() ?? '';

      const finalShippingState =
        finalShippingSameAsBilling
          ? finalBillingState
          : shippingState?.trim() ?? '';

      const finalShippingZip =
        finalShippingSameAsBilling
          ? finalBillingZip
          : shippingZip?.trim() ?? '';

      const finalShippingCountry =
        finalShippingSameAsBilling
          ? finalBillingCountry
          : shippingCountry?.trim() ?? '';

      // --------------------------------------------------------
      // UPDATE
      // --------------------------------------------------------

      const [result] =
        await db.query(
          `
          UPDATE vendors

          SET
            vendor_type = ?,
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
            vendorType ||
              'Business',

            salutation ||
              'Mr.',

            firstName?.trim() ||
              null,

            lastName?.trim() ||
              null,

            vendorName.trim(),

            companyName?.trim() ||
              null,

            email?.trim() ||
              null,

            phone?.trim() ||
              null,

            website?.trim() ||
              null,

            gstApplicable ||
              'No',

            finalBillingStreet ||
              null,

            finalBillingCity ||
              null,

            finalBillingState ||
              null,

            finalBillingZip ||
              null,

            finalBillingCountry ||
              null,

            finalShippingSameAsBilling
              ? 1
              : 0,

            finalShippingStreet ||
              null,

            finalShippingCity ||
              null,

            finalShippingState ||
              null,

            finalShippingZip ||
              null,

            finalShippingCountry ||
              null,

            status ||
              'Active',

            id,
          ]
        );

      if (
        result.affectedRows === 0
      ) {
        return res
            .status(404)
            .json({
          success: false,

          message:
            'Vendor not found',
        });
      }

      const [rows] =
        await db.query(
          `
          SELECT *

          FROM vendors

          WHERE id = ?

          LIMIT 1
          `,
          [id]
        );

      res.status(200).json({
        success: true,

        message:
          'Vendor updated successfully',

        data:
          mapVendor(
            rows[0]
          ),
      });
    } catch (error) {
      console.error(
        'Update vendor error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to update vendor',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// DELETE VENDOR
//
// DELETE /api/vendors/:id
// ============================================================

router.delete(
  '/:id',
  async (req, res) => {
    try {
      const { id } =
        req.params;

      const [result] =
        await db.query(
          `
          DELETE FROM vendors

          WHERE id = ?
          `,
          [id]
        );

      if (
        result.affectedRows === 0
      ) {
        return res
            .status(404)
            .json({
          success: false,

          message:
            'Vendor not found',
        });
      }

      res.status(200).json({
        success: true,

        message:
          'Vendor deleted successfully',
      });
    } catch (error) {
      console.error(
        'Delete vendor error:',
        error
      );

      res.status(500).json({
        success: false,

        message:
          'Failed to delete vendor',

        error:
          error.message,
      });
    }
  }
);

// ============================================================
// VENDOR COMMENTS
//
// GET  /api/vendors/:id/comments
// POST /api/vendors/:id/comments
// ============================================================

router.get(
  '/:id/comments',
  async (req, res) => {
    try {
      const { id } = req.params;
      const [vendorRows] = await db.query(
        'SELECT id FROM vendors WHERE id = ? LIMIT 1',
        [id]
      );
      if (vendorRows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Vendor not found',
        });
      }

      const [rows] = await db.query(
        `
        SELECT id, vendor_id, author_name, comment_text, created_at
        FROM vendor_comments
        WHERE vendor_id = ?
        ORDER BY created_at DESC, id DESC
        `,
        [id]
      );
      return res.status(200).json({
        success: true,
        data: rows.map((row) => ({
          id: row.id.toString(),
          vendorId: row.vendor_id.toString(),
          authorName: row.author_name,
          comment: row.comment_text,
          createdAt: row.created_at,
        })),
      });
    } catch (error) {
      console.error('Get vendor comments error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to fetch vendor comments',
        error: error.message,
      });
    }
  }
);

router.post(
  '/:id/comments',
  async (req, res) => {
    try {
      const { id } = req.params;
      const comment =
        typeof req.body?.comment === 'string'
          ? req.body.comment.trim()
          : '';
      const authorName =
        typeof req.body?.authorName === 'string'
          ? req.body.authorName.trim()
          : '';

      if (!comment) {
        return res.status(400).json({
          success: false,
          message: 'Comment cannot be empty',
        });
      }
      if (!authorName) {
        return res.status(400).json({
          success: false,
          message: 'Comment author is required',
        });
      }

      const [vendorRows] = await db.query(
        'SELECT id FROM vendors WHERE id = ? LIMIT 1',
        [id]
      );
      if (vendorRows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Vendor not found',
        });
      }

      const [result] = await db.query(
        `
        INSERT INTO vendor_comments (vendor_id, author_name, comment_text)
        VALUES (?, ?, ?)
        `,
        [id, authorName, comment]
      );
      const [rows] = await db.query(
        `
        SELECT id, vendor_id, author_name, comment_text, created_at
        FROM vendor_comments
        WHERE id = ?
        LIMIT 1
        `,
        [result.insertId]
      );
      const row = rows[0];
      return res.status(201).json({
        success: true,
        message: 'Vendor comment saved successfully',
        data: {
          id: row.id.toString(),
          vendorId: row.vendor_id.toString(),
          authorName: row.author_name,
          comment: row.comment_text,
          createdAt: row.created_at,
        },
      });
    } catch (error) {
      console.error('Save vendor comment error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to save vendor comment',
        error: error.message,
      });
    }
  }
);

module.exports = router;