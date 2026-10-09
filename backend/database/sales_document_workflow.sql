-- Additive Sales workflow migration. Safe to run repeatedly.
-- The deployed estimates and sales_orders tables were inspected before this file was created.

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='estimates' AND COLUMN_NAME='approval_status'),
  'SELECT 1',
  'ALTER TABLE estimates ADD COLUMN approval_status ENUM(''Pending'',''Approved'') NOT NULL DEFAULT ''Pending'', ADD COLUMN approved_at DATETIME NULL, ADD COLUMN approved_by INT(10) UNSIGNED NULL'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

INSERT INTO transaction_number_series (module,prefix,starting_number)
VALUES ('Invoice','INV-',1)
ON DUPLICATE KEY UPDATE module=VALUES(module);
INSERT INTO transaction_number_series (module,prefix,starting_number)
VALUES ('Delivery Challan','DC-',1)
ON DUPLICATE KEY UPDATE module=VALUES(module);

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sales_orders' AND COLUMN_NAME='approval_status'),
  'SELECT 1',
  'ALTER TABLE sales_orders ADD COLUMN approval_status ENUM(''Pending'',''Approved'') NOT NULL DEFAULT ''Pending'', ADD COLUMN approved_at DATETIME NULL, ADD COLUMN approved_by INT(10) UNSIGNED NULL'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

-- Keep the Sales Order status column compatible while existing values are
-- translated to the current four-option workflow.
SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sales_orders' AND COLUMN_NAME='status'),
  'ALTER TABLE sales_orders MODIFY status ENUM(''Draft'',''Confirmed'',''Fulfilled'',''Cancelled'',''Approved'',''Sent'',''Rejected'') NOT NULL DEFAULT ''Draft''',
  'SELECT 1'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

UPDATE sales_orders
SET status = CASE status
  WHEN 'Confirmed' THEN 'Approved'
  WHEN 'Fulfilled' THEN 'Sent'
  WHEN 'Cancelled' THEN 'Rejected'
  ELSE status
END;

UPDATE sales_orders
SET status = 'Approved'
WHERE approval_status = 'Approved' AND status = 'Draft';

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sales_orders' AND COLUMN_NAME='status'),
  'ALTER TABLE sales_orders MODIFY status ENUM(''Draft'',''Approved'',''Sent'',''Rejected'') NOT NULL DEFAULT ''Draft''',
  'SELECT 1'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sales_orders' AND INDEX_NAME='uq_sales_orders_estimate_id'),
  'SELECT 1',
  'CREATE UNIQUE INDEX uq_sales_orders_estimate_id ON sales_orders (estimate_id)'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

CREATE TABLE IF NOT EXISTS invoices (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  invoice_number VARCHAR(50) NOT NULL,
  sales_order_id INT(10) UNSIGNED NULL,
  sales_order_number VARCHAR(50) NULL,
  estimate_id INT(10) UNSIGNED NULL,
  estimate_number VARCHAR(50) NULL,
  customer_id INT(10) UNSIGNED NOT NULL,
  customer_name VARCHAR(200) NOT NULL,
  invoice_date DATE NOT NULL,
  due_date DATE NULL,
  credit_terms VARCHAR(100) NOT NULL DEFAULT 'Immediate Payment',
  sub_total DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  tax DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  amount_paid DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  notes TEXT NULL,
  terms_and_conditions TEXT NULL,
  approval_status ENUM('Pending','Approved') NOT NULL DEFAULT 'Pending',
  document_status ENUM('Draft','Sent','Void') NOT NULL DEFAULT 'Draft',
  approved_at DATETIME NULL,
  approved_by INT(10) UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY invoice_number (invoice_number),
  UNIQUE KEY uq_invoices_sales_order_id (sales_order_id),
  KEY ix_invoices_customer_id (customer_id),
  KEY ix_invoices_estimate_id (estimate_id),
  CONSTRAINT fk_invoice_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_invoice_sales_order FOREIGN KEY (sales_order_id) REFERENCES sales_orders(id) ON DELETE SET NULL,
  CONSTRAINT fk_invoice_estimate FOREIGN KEY (estimate_id) REFERENCES estimates(id) ON DELETE SET NULL,
  CONSTRAINT fk_invoice_approved_by FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='invoices' AND COLUMN_NAME='document_status'),
  'SELECT 1',
  'ALTER TABLE invoices ADD COLUMN document_status ENUM(''Draft'',''Sent'',''Void'') NOT NULL DEFAULT ''Draft'' AFTER approval_status'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

INSERT INTO transaction_number_series (module, prefix, starting_number)
VALUES ('Payment Received', 'PAY-', 1)
ON DUPLICATE KEY UPDATE module = VALUES(module);

CREATE TABLE IF NOT EXISTS payment_received (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  payment_number VARCHAR(50) NOT NULL,
  customer_id INT(10) UNSIGNED NOT NULL,
  invoice_id INT(10) UNSIGNED NOT NULL,
  payment_date DATE NOT NULL,
  amount_received DECIMAL(14,2) NOT NULL,
  payment_mode VARCHAR(50) NOT NULL,
  utr_reference VARCHAR(200) NULL,
  remarks TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_payment_received_number (payment_number),
  KEY ix_payment_received_customer_date (customer_id, payment_date),
  KEY ix_payment_received_invoice (invoice_id),
  CONSTRAINT fk_payment_received_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
  CONSTRAINT fk_payment_received_invoice
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='invoices' AND COLUMN_NAME='terms_and_conditions'),
  'SELECT 1',
  'ALTER TABLE invoices ADD COLUMN terms_and_conditions TEXT NULL AFTER notes'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

CREATE TABLE IF NOT EXISTS invoice_items (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  invoice_id INT(10) UNSIGNED NOT NULL,
  source_type ENUM('Item','Part') NOT NULL,
  item_id INT(10) UNSIGNED NULL,
  part_id INT(10) UNSIGNED NULL,
  item_name VARCHAR(200) NOT NULL,
  description TEXT NULL,
  qty DECIMAL(12,2) NOT NULL DEFAULT 1.00,
  rate DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_invoice_items_invoice_id (invoice_id),
  CONSTRAINT fk_invoice_item_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
  CONSTRAINT fk_invoice_item_item FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE SET NULL,
  CONSTRAINT fk_invoice_item_part FOREIGN KEY (part_id) REFERENCES parts(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS delivery_challans (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  challan_number VARCHAR(50) NOT NULL,
  invoice_id INT(10) UNSIGNED NULL,
  invoice_number VARCHAR(50) NULL,
  sales_order_id INT(10) UNSIGNED NULL,
  sales_order_number VARCHAR(50) NULL,
  estimate_id INT(10) UNSIGNED NULL,
  estimate_number VARCHAR(50) NULL,
  customer_id INT(10) UNSIGNED NOT NULL,
  customer_name VARCHAR(200) NOT NULL,
  challan_date DATE NOT NULL,
  delivery_date DATE NULL,
  transportation_details TEXT NULL,
  notes TEXT NULL,
  total DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  status ENUM('Draft','Shipped','Delivered','Void') NOT NULL DEFAULT 'Draft',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY challan_number (challan_number),
  UNIQUE KEY uq_delivery_challans_invoice_id (invoice_id),
  UNIQUE KEY uq_delivery_challans_sales_order_id (sales_order_id),
  KEY ix_delivery_challans_customer_id (customer_id),
  CONSTRAINT fk_delivery_challan_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
  CONSTRAINT fk_delivery_challan_sales_order FOREIGN KEY (sales_order_id) REFERENCES sales_orders(id) ON DELETE SET NULL,
  CONSTRAINT fk_delivery_challan_estimate FOREIGN KEY (estimate_id) REFERENCES estimates(id) ON DELETE SET NULL,
  CONSTRAINT fk_delivery_challan_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

ALTER TABLE delivery_challans MODIFY COLUMN status ENUM('Pending','Cancelled','Draft','Shipped','Delivered','Void') NOT NULL DEFAULT 'Draft';
UPDATE delivery_challans SET status='Draft' WHERE status IN ('Pending','Cancelled');
ALTER TABLE delivery_challans MODIFY COLUMN status ENUM('Draft','Shipped','Delivered','Void') NOT NULL DEFAULT 'Draft';

-- Preserve the originating Sales Order on Purchase Orders. Existing rows remain
-- unlinked (NULL); nullable unique indexes permit multiple unrelated documents.
SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='purchase_orders' AND COLUMN_NAME='sales_order_id'),
  'SELECT 1',
  'ALTER TABLE purchase_orders ADD COLUMN sales_order_id INT(10) UNSIGNED NULL'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='purchase_orders' AND COLUMN_NAME='sales_order_number'),
  'SELECT 1',
  'ALTER TABLE purchase_orders ADD COLUMN sales_order_number VARCHAR(50) NULL'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='purchase_orders' AND INDEX_NAME='uq_purchase_orders_sales_order_id'),
  'SELECT 1',
  'CREATE UNIQUE INDEX uq_purchase_orders_sales_order_id ON purchase_orders (sales_order_id)'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='purchase_orders' AND CONSTRAINT_NAME='fk_purchase_order_sales_order'),
  'SELECT 1',
  'ALTER TABLE purchase_orders ADD CONSTRAINT fk_purchase_order_sales_order FOREIGN KEY (sales_order_id) REFERENCES sales_orders(id) ON DELETE SET NULL'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='delivery_challans' AND INDEX_NAME='uq_delivery_challans_sales_order_id'),
  'SELECT 1',
  'CREATE UNIQUE INDEX uq_delivery_challans_sales_order_id ON delivery_challans (sales_order_id)'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

CREATE TABLE IF NOT EXISTS delivery_challan_items (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  delivery_challan_id INT(10) UNSIGNED NOT NULL,
  source_type ENUM('Item','Part') NOT NULL,
  item_id INT(10) UNSIGNED NULL,
  part_id INT(10) UNSIGNED NULL,
  item_name VARCHAR(200) NOT NULL,
  description TEXT NULL,
  qty DECIMAL(12,2) NOT NULL DEFAULT 1.00,
  rate DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_delivery_challan_items_challan_id (delivery_challan_id),
  CONSTRAINT fk_delivery_challan_item_challan FOREIGN KEY (delivery_challan_id) REFERENCES delivery_challans(id) ON DELETE CASCADE,
  CONSTRAINT fk_delivery_challan_item_item FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE SET NULL,
  CONSTRAINT fk_delivery_challan_item_part FOREIGN KEY (part_id) REFERENCES parts(id) ON DELETE SET NULL
) ENGINE=InnoDB;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='estimates' AND CONSTRAINT_NAME='fk_estimate_approved_by'),
  'SELECT 1',
  'ALTER TABLE estimates ADD CONSTRAINT fk_estimate_approved_by FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;

SET @ddl = IF(
  EXISTS (SELECT 1 FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='sales_orders' AND CONSTRAINT_NAME='fk_sales_order_approved_by'),
  'SELECT 1',
  'ALTER TABLE sales_orders ADD CONSTRAINT fk_sales_order_approved_by FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL'
);
PREPARE sales_workflow_stmt FROM @ddl; EXECUTE sales_workflow_stmt; DEALLOCATE PREPARE sales_workflow_stmt;
