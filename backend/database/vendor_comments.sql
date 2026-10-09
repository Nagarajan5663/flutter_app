CREATE TABLE IF NOT EXISTS vendor_comments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  vendor_id VARCHAR(64) NOT NULL,
  author_name VARCHAR(255) NOT NULL,
  comment_text TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_vendor_comments_vendor_created (vendor_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
