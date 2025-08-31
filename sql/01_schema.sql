-- 01_schema.sql

-- Safety: drop if you are iterating (comment these in production)
-- DROP TABLE IF EXISTS sales CASCADE;
-- DROP TABLE IF EXISTS orders CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS customers CASCADE;
-- DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE IF NOT EXISTS employees (
  employee_id   SERIAL PRIMARY KEY,
  first_name    TEXT,
  last_name     TEXT,
  email         TEXT,
  salary        NUMERIC
);

CREATE TABLE IF NOT EXISTS customers (
  customer_id   INTEGER PRIMARY KEY,
  customer_name TEXT,
  address       TEXT,
  city          TEXT,
  zip_code      TEXT
);

CREATE TABLE IF NOT EXISTS products (
  product_id    INTEGER PRIMARY KEY,
  product_name  TEXT,
  price         NUMERIC,
  description   TEXT,
  category      TEXT
);

-- orders: include year/quarter/month as stored columns (loaded from CSV)
CREATE TABLE IF NOT EXISTS orders (
  order_id    INTEGER PRIMARY KEY,
  order_date  TIMESTAMP,
  year        INT,
  quarter     INT,
  month       TEXT
);

CREATE TABLE IF NOT EXISTS sales (
  transaction_id INTEGER PRIMARY KEY,
  order_id       INTEGER REFERENCES orders(order_id)     ON DELETE RESTRICT,
  product_id     INTEGER REFERENCES products(product_id) ON DELETE RESTRICT,
  customer_id    INTEGER REFERENCES customers(customer_id) ON DELETE RESTRICT,
  employee_id    INTEGER REFERENCES employees(employee_id) ON DELETE SET NULL,
  total_sales    NUMERIC,
  quantity       INTEGER,
  discount       NUMERIC
);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_sales_order_id   ON sales(order_id);
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date      ON orders(order_date);