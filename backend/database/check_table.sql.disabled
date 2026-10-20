-- Replace this value with the table name you want to check.
SET @table_name = 'sample_table';

-- Returns one row when the table exists in the selected database.
SELECT
  TABLE_SCHEMA,
  TABLE_NAME,
  TABLE_TYPE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = @table_name;

-- Optional: list all tables in the selected database.
SHOW TABLES;
