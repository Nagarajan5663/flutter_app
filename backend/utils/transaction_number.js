const db = require('../config/db');

// ============================================================
// SAFE SQL IDENTIFIER
//
// Table/column names cannot use MySQL ? placeholders.
// This check prevents unsafe identifiers.
// ============================================================

function validateIdentifier(value, name) {
  if (
    typeof value !== 'string' ||
    !/^[A-Za-z0-9_]+$/.test(value)
  ) {
    throw new Error(
      `Invalid ${name}: ${value}`
    );
  }

  return value;
}

// ============================================================
// GET NEXT TRANSACTION NUMBER
//
// Example:
//
// await getNextTransactionNumber({
//   module: 'Sales Order',
//   table: 'sales_orders',
//   numberColumn: 'so_number',
// });
//
// DB:
//
// module          = Sales Order
// prefix          = SO-
// starting_number = 1
//
// Result:
//
// {
//   transactionNumber: 'SO-0001',
//   prefix: 'SO-',
//   startingNumber: 1,
//   nextNumber: 1
// }
// ============================================================

async function getNextTransactionNumber({
  module,
  table,
  numberColumn,
  padding = 4,
  connection = null,
}) {
  const queryable = connection || db;
  if (
    !module ||
    module.trim() === ''
  ) {
    throw new Error(
      'Transaction module is required'
    );
  }

  const safeTable =
    validateIdentifier(
      table,
      'table name'
    );

  const safeNumberColumn =
    validateIdentifier(
      numberColumn,
      'number column'
    );

  const finalPadding =
    Number.isInteger(padding) &&
    padding > 0
      ? padding
      : 4;

  // ==========================================================
  // 1. READ PREFIX + STARTING NUMBER FROM SETTINGS
  // ==========================================================

  const [seriesRows] =
    await queryable.query(
      `
      SELECT
        prefix,
        starting_number

      FROM transaction_number_series

      WHERE module = ?

      LIMIT 1 ${connection ? 'FOR UPDATE' : ''}
      `,
      [
        module.trim(),
      ]
    );

  if (
    seriesRows.length === 0
  ) {
    const error =
      new Error(
        `${module} number series is not configured`
      );

    error.statusCode = 404;

    throw error;
  }

  // ==========================================================
  // 2. PREFIX IS FULLY DYNAMIC
  // ==========================================================

  const prefix =
    seriesRows[0].prefix ??
    '';

  // ==========================================================
  // 3. STARTING NUMBER IS DYNAMIC
  // ==========================================================

  const startingNumber =
    Number(
      seriesRows[0]
        .starting_number ?? 1
    );

  const validStartingNumber =
    Number.isFinite(
      startingNumber
    ) &&
    startingNumber > 0
      ? startingNumber
      : 1;

  // ==========================================================
  // 4. FIND HIGHEST NUMBER USING CURRENT PREFIX
  //
  // Example:
  //
  // SO-0001
  // SO-0002
  // SO-0003
  //
  // max_number = 3
  // ==========================================================

  const sql = `
    SELECT
      MAX(
        CAST(
          SUBSTRING(
            \`${safeNumberColumn}\`,
            CHAR_LENGTH(?) + 1
          ) AS UNSIGNED
        )
      ) AS max_number

    FROM \`${safeTable}\`

    WHERE \`${safeNumberColumn}\`
      LIKE ?
  `;

  const [numberRows] =
    await queryable.query(
      sql,
      [
        prefix,
        `${prefix}%`,
      ]
    );

  const maxNumber =
    Number(
      numberRows[0]
        ?.max_number ?? 0
    );

  // ==========================================================
  // 5. NEXT NUMBER
  //
  // No matching existing number:
  // → use starting_number
  //
  // Existing number:
  // → max + 1
  // ==========================================================

  const nextNumber =
    maxNumber > 0
      ? maxNumber + 1
      : validStartingNumber;

  // ==========================================================
  // 6. FORMAT
  //
  // 1  → 0001
  // 15 → 0015
  // ==========================================================

  const paddedNumber =
    String(
      nextNumber
    ).padStart(
      finalPadding,
      '0'
    );

  // ==========================================================
  // 7. FINAL NUMBER
  // ==========================================================

  const transactionNumber =
    `${prefix}${paddedNumber}`;

  return {
    transactionNumber,

    prefix,

    startingNumber:
      validStartingNumber,

    nextNumber,

    padding:
      finalPadding,
  };
}

// ============================================================
// EXPORT
// ============================================================

module.exports = {
  getNextTransactionNumber,
};
