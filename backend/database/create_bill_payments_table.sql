CREATE TABLE IF NOT EXISTS bill_payments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  bill_id VARCHAR(64) NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  payment_date DATE NOT NULL,
  payment_mode VARCHAR(60) NOT NULL,
  reference_number VARCHAR(255) NULL,
  paid_by VARCHAR(255) NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_bill_payments_bill_id (bill_id)
) ENGINE=InnoDB;
