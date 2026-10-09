CREATE TABLE IF NOT EXISTS customer_comments (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id INT(10) UNSIGNED NOT NULL,
  comment TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_customer_comments_customer_created (customer_id, created_at),
  CONSTRAINT fk_customer_comments_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;
