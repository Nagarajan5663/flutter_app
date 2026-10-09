SET @author_column_exists = (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'vendor_comments'
    AND COLUMN_NAME = 'author_name'
);

SET @author_column_migration = IF(
  @author_column_exists = 0,
  'ALTER TABLE vendor_comments ADD COLUMN author_name VARCHAR(255) NOT NULL DEFAULT ''User'' AFTER vendor_id',
  'SELECT 1'
);

PREPARE author_column_statement FROM @author_column_migration;
EXECUTE author_column_statement;
DEALLOCATE PREPARE author_column_statement;
