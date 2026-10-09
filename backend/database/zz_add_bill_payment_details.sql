SET @add_paid_by = IF(
  (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'bill_payments'
      AND column_name = 'paid_by'
  ) = 0,
  'ALTER TABLE bill_payments ADD COLUMN paid_by VARCHAR(255) NULL',
  'SELECT 1'
);
PREPARE bill_payment_migration FROM @add_paid_by;
EXECUTE bill_payment_migration;
DEALLOCATE PREPARE bill_payment_migration;

SET @add_payment_notes = IF(
  (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'bill_payments'
      AND column_name = 'notes'
  ) = 0,
  'ALTER TABLE bill_payments ADD COLUMN notes TEXT NULL',
  'SELECT 1'
);
PREPARE bill_payment_migration FROM @add_payment_notes;
EXECUTE bill_payment_migration;
DEALLOCATE PREPARE bill_payment_migration;
