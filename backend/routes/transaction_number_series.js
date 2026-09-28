const express = require('express');
const db = require('../config/db');

const router = express.Router();

// ============================================================
// SUPPORTED TRANSACTION MODULES
//
// IMPORTANT:
// These names must exactly match the module names used in
// transaction_number.js.
//
// Example:
//
// getNextTransactionNumber({
//   module: 'Sales Order',
//   ...
// });
//
// ============================================================

const MODULES = [
  'Journal',
  'Credit Note',
  'Customer Payment',

  'Estimate',
  'Sales Order',
  'Invoice',

  'Purchase Order',
  'Bill',

  'Vendor Payment',
  'Retainer Invoice',
  'Vendor Credits',
  'Bill Of Supply',
  'Debit Note',
];

// ============================================================
// HELPERS
// ============================================================

function normalizeStartingNumber(
  value
) {
  const number =
    Number(value);

  if (
    !Number.isInteger(number) ||
    number <= 0
  ) {
    return 1;
  }

  return number;
}

// ============================================================
// PREFIX
//
// Examples:
//
// SO-
// PO-
// EST-
// BILL-
// INV-
// COD-SO-
//
// ============================================================

function normalizePrefix(
  value
) {
  if (
    value == null
  ) {
    return '';
  }

  return value
    .toString()
    .trim();
}

// ============================================================
// PREVIEW
//
// SO- + 1
// → SO-0001
//
// PO- + 25
// → PO-0025
//
// ============================================================

function makePreview(
  prefix,
  startingNumber
) {
  const cleanPrefix =
    normalizePrefix(
      prefix
    );

  const number =
    normalizeStartingNumber(
      startingNumber
    );

  return `${cleanPrefix}${String(
    number
  ).padStart(
    4,
    '0'
  )}`;
}

// ============================================================
// MAP DB ROW
// ============================================================

function mapSeriesRow(
  module,
  row
) {
  // ----------------------------------------------------------
  // Module does not exist in DB
  // ----------------------------------------------------------

  if (!row) {
    return {
      id:
        null,

      module,

      prefix:
        '',

      startingNumber:
        1,

      preview:
        '0001',

      configured:
        false,

      createdAt:
        null,

      updatedAt:
        null,
    };
  }

  const prefix =
    normalizePrefix(
      row.prefix
    );

  const startingNumber =
    normalizeStartingNumber(
      row.starting_number
    );

  return {
    id:
      Number(
        row.id
      ),

    module,

    prefix,

    startingNumber,

    preview:
      makePreview(
        prefix,
        startingNumber
      ),

    configured:
      prefix !== '',

    createdAt:
      row.created_at ??
      null,

    updatedAt:
      row.updated_at ??
      null,
  };
}

// ============================================================
// GET ALL TRANSACTION NUMBER SERIES
//
// GET
// /api/transaction-number-series
//
// Always returns every supported module.
//
// If no DB configuration exists:
//
// {
//   module: "Purchase Order",
//   prefix: "",
//   startingNumber: 1,
//   configured: false
// }
//
// ============================================================

router.get(
  '/',
  async (req, res) => {
    try {
      const [rows] =
        await db.query(
          `
          SELECT
            id,
            module,
            prefix,
            starting_number,
            created_at,
            updated_at

          FROM transaction_number_series

          ORDER BY id ASC
          `
        );

      // --------------------------------------------------------
      // DB rows by module
      // --------------------------------------------------------

      const byModule =
        new Map();

      for (
        const row
        of rows
      ) {
        // If accidental duplicates exist,
        // first row wins.
        if (
          !byModule.has(
            row.module
          )
        ) {
          byModule.set(
            row.module,
            row
          );
        }
      }

      // --------------------------------------------------------
      // Return every supported module
      // --------------------------------------------------------

      const data =
        MODULES.map(
          (module) => {
            return mapSeriesRow(
              module,
              byModule.get(
                module
              )
            );
          }
        );

      return res
        .status(200)
        .json({
          success:
            true,

          data,
        });
    } catch (error) {
      console.error(
        'Get transaction number series error:',
        error
      );

      return res
        .status(500)
        .json({
          success:
            false,

          message:
            'Failed to load transaction number series',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// SAVE ALL TRANSACTION NUMBER SERIES
//
// PUT
// /api/transaction-number-series
//
// BODY:
//
// {
//   "series": [
//     {
//       "module": "Estimate",
//       "prefix": "EST-",
//       "startingNumber": 1
//     },
//     {
//       "module": "Sales Order",
//       "prefix": "SO-",
//       "startingNumber": 1
//     },
//     {
//       "module": "Purchase Order",
//       "prefix": "PO-",
//       "startingNumber": 1
//     },
//     {
//       "module": "Bill",
//       "prefix": "BILL-",
//       "startingNumber": 1
//     }
//   ]
// }
//
// IMPORTANT:
//
// Empty prefix means:
//
// "This module is not configured."
//
// If an existing configured module is cleared,
// its DB configuration will be removed.
//
// ============================================================

router.put(
  '/',
  async (req, res) => {
    let connection;

    try {
      const {
        series,
      } = req.body;

      // --------------------------------------------------------
      // Validate body
      // --------------------------------------------------------

      if (
        !Array.isArray(
          series
        )
      ) {
        return res
          .status(400)
          .json({
            success:
              false,

            message:
              'series must be an array',
          });
      }

      connection =
        await db.getConnection();

      await connection
        .beginTransaction();

      // --------------------------------------------------------
      // Process every submitted module
      // --------------------------------------------------------

      for (
        const entry
        of series
      ) {
        const module =
          entry.module
            ?.toString()
            .trim();

        // ------------------------------------------------------
        // Module validation
        // ------------------------------------------------------

        if (
          !module ||
          !MODULES.includes(
            module
          )
        ) {
          await connection
            .rollback();

          return res
            .status(400)
            .json({
              success:
                false,

              message:
                `Invalid transaction module: ${module}`,
            });
        }

        const prefix =
          normalizePrefix(
            entry.prefix
          );

        const startingNumber =
          normalizeStartingNumber(
            entry.startingNumber
          );

        // ------------------------------------------------------
        // Check current configuration
        // ------------------------------------------------------

        const [existingRows] =
          await connection.query(
            `
            SELECT
              id

            FROM transaction_number_series

            WHERE module = ?

            ORDER BY id ASC

            LIMIT 1
            `,
            [
              module,
            ]
          );

        // ======================================================
        // EMPTY PREFIX
        //
        // Treat as NOT CONFIGURED.
        //
        // If a configuration already exists and user clears
        // prefix from Settings, remove that configuration.
        // ======================================================

        if (
          prefix === ''
        ) {
          if (
            existingRows.length > 0
          ) {
            await connection.query(
              `
              DELETE FROM
                transaction_number_series

              WHERE module = ?
              `,
              [
                module,
              ]
            );
          }

          continue;
        }

        // ======================================================
        // UPDATE EXISTING CONFIGURATION
        // ======================================================

        if (
          existingRows.length > 0
        ) {
          await connection.query(
            `
            UPDATE
              transaction_number_series

            SET
              prefix = ?,
              starting_number = ?

            WHERE module = ?
            `,
            [
              prefix,
              startingNumber,
              module,
            ]
          );

          continue;
        }

        // ======================================================
        // INSERT NEW CONFIGURATION
        // ======================================================

        await connection.query(
          `
          INSERT INTO
            transaction_number_series
          (
            module,
            prefix,
            starting_number
          )
          VALUES (
            ?, ?, ?
          )
          `,
          [
            module,
            prefix,
            startingNumber,
          ]
        );
      }

      // --------------------------------------------------------
      // Commit everything
      // --------------------------------------------------------

      await connection
        .commit();

      return res
        .status(200)
        .json({
          success:
            true,

          message:
            'Transaction number series saved successfully',
        });
    } catch (error) {
      if (connection) {
        try {
          await connection
            .rollback();
        } catch (_) {}
      }

      console.error(
        'Save transaction number series error:',
        error
      );

      return res
        .status(500)
        .json({
          success:
            false,

          message:
            'Failed to save transaction number series',

          error:
            error.message,
        });
    } finally {
      if (connection) {
        connection.release();
      }
    }
  }
);

// ============================================================
// GET ONE MODULE CONFIGURATION
//
// Examples:
//
// GET
// /api/transaction-number-series/Estimate
//
// GET
// /api/transaction-number-series/Sales%20Order
//
// GET
// /api/transaction-number-series/Purchase%20Order
//
// GET
// /api/transaction-number-series/Bill
//
// GET
// /api/transaction-number-series/Invoice
//
// ============================================================

router.get(
  '/:module',
  async (req, res) => {
    try {
      const module =
        decodeURIComponent(
          req.params.module
        ).trim();

      // --------------------------------------------------------
      // Module must be supported
      // --------------------------------------------------------

      if (
        !MODULES.includes(
          module
        )
      ) {
        return res
          .status(404)
          .json({
            success:
              false,

            message:
              `Transaction module not found: ${module}`,
          });
      }

      // --------------------------------------------------------
      // Load configuration
      // --------------------------------------------------------

      const [rows] =
        await db.query(
          `
          SELECT
            id,
            module,
            prefix,
            starting_number,
            created_at,
            updated_at

          FROM transaction_number_series

          WHERE module = ?

          ORDER BY id ASC

          LIMIT 1
          `,
          [
            module,
          ]
        );

      // --------------------------------------------------------
      // Supported but not configured
      // --------------------------------------------------------

      if (
        rows.length === 0
      ) {
        return res
          .status(200)
          .json({
            success:
              true,

            data: {
              id:
                null,

              module,

              prefix:
                '',

              startingNumber:
                1,

              preview:
                '0001',

              configured:
                false,

              createdAt:
                null,

              updatedAt:
                null,
            },
          });
      }

      const row =
        rows[0];

      return res
        .status(200)
        .json({
          success:
            true,

          data:
            mapSeriesRow(
              module,
              row
            ),
        });
    } catch (error) {
      console.error(
        'Get transaction number series module error:',
        error
      );

      return res
        .status(500)
        .json({
          success:
            false,

          message:
            'Failed to fetch transaction number series',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// SAVE / UPDATE ONE MODULE
//
// PUT
// /api/transaction-number-series/:module
//
// Example:
//
// PUT
// /api/transaction-number-series/Purchase%20Order
//
// {
//   "prefix": "PO-",
//   "startingNumber": 1
// }
//
// This endpoint is optional for Flutter,
// but useful for future module-specific settings.
// ============================================================

router.put(
  '/:module',
  async (req, res) => {
    try {
      const module =
        decodeURIComponent(
          req.params.module
        ).trim();

      if (
        !MODULES.includes(
          module
        )
      ) {
        return res
          .status(404)
          .json({
            success:
              false,

            message:
              `Transaction module not found: ${module}`,
          });
      }

      const prefix =
        normalizePrefix(
          req.body.prefix
        );

      const startingNumber =
        normalizeStartingNumber(
          req.body.startingNumber
        );

      // --------------------------------------------------------
      // Prefix cleared
      // --------------------------------------------------------

      if (
        prefix === ''
      ) {
        await db.query(
          `
          DELETE FROM
            transaction_number_series

          WHERE module = ?
          `,
          [
            module,
          ]
        );

        return res
          .status(200)
          .json({
            success:
              true,

            message:
              `${module} number series cleared`,

            data: {
              id:
                null,

              module,

              prefix:
                '',

              startingNumber:
                1,

              preview:
                '0001',

              configured:
                false,
            },
          });
      }

      // --------------------------------------------------------
      // Check existing
      // --------------------------------------------------------

      const [existingRows] =
        await db.query(
          `
          SELECT
            id

          FROM transaction_number_series

          WHERE module = ?

          LIMIT 1
          `,
          [
            module,
          ]
        );

      if (
        existingRows.length > 0
      ) {
        await db.query(
          `
          UPDATE
            transaction_number_series

          SET
            prefix = ?,
            starting_number = ?

          WHERE module = ?
          `,
          [
            prefix,
            startingNumber,
            module,
          ]
        );
      } else {
        await db.query(
          `
          INSERT INTO
            transaction_number_series
          (
            module,
            prefix,
            starting_number
          )
          VALUES (
            ?, ?, ?
          )
          `,
          [
            module,
            prefix,
            startingNumber,
          ]
        );
      }

      // --------------------------------------------------------
      // Return saved row
      // --------------------------------------------------------

      const [savedRows] =
        await db.query(
          `
          SELECT
            id,
            module,
            prefix,
            starting_number,
            created_at,
            updated_at

          FROM transaction_number_series

          WHERE module = ?

          LIMIT 1
          `,
          [
            module,
          ]
        );

      return res
        .status(200)
        .json({
          success:
            true,

          message:
            `${module} number series saved successfully`,

          data:
            mapSeriesRow(
              module,
              savedRows[0]
            ),
        });
    } catch (error) {
      console.error(
        'Save transaction number series module error:',
        error
      );

      return res
        .status(500)
        .json({
          success:
            false,

          message:
            'Failed to save transaction number series',

          error:
            error.message,
        });
    }
  }
);

// ============================================================
// EXPORT
// ============================================================

module.exports = router;