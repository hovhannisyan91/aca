-- =========================================
-- User-Defined Functions for ETL Schema
-- employees, customers, products, orders, sales
-- =========================================

-- =========================================
-- UDF 1/5 — Scalar: discounted price (NULL-safe)
-- =========================================
CREATE OR REPLACE FUNCTION calc_discounted_price(
    p_price    NUMERIC,
    p_discount NUMERIC   -- e.g., 0.15 = 15%
)
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
  SELECT GREATEST(
           0,
           COALESCE(p_price, 0)
           * (1 - LEAST(GREATEST(COALESCE(p_discount, 0), 0), 0.999999))
         );
$$;

-- Example:
-- SELECT product_id, product_name, calc_discounted_price(price, 0.15) AS discounted_price
-- FROM products;


-- =========================================
-- UDF 2/5 — TVF: recent orders for a customer (with totals)
-- =========================================
CREATE OR REPLACE FUNCTION recent_orders(
    p_customer_id INT,
    p_limit       INT
)
RETURNS TABLE (
    order_id   INT,
    order_date TIMESTAMP,
    year       INT,
    quarter    INT,
    month      TEXT,
    total      NUMERIC
)
LANGUAGE sql
STABLE
AS $$
  SELECT
      o.order_id,
      o.order_date,
      o.year,
      o.quarter,
      o.month,
      SUM(s.total_sales) AS total
  FROM orders o
  JOIN sales  s ON s.order_id = o.order_id
  WHERE s.customer_id = p_customer_id
    AND o.order_date IS NOT NULL
  GROUP BY o.order_id, o.order_date, o.year, o.quarter, o.month
  ORDER BY o.order_date DESC
  LIMIT GREATEST(p_limit, 0)
$$;

-- Example:
-- SELECT * FROM recent_orders(10001, 5);


-- =========================================
-- UDF 3/5 — Aggregate: product_of_quantities (NUMERIC)
-- =========================================

-- Step A: state transition
CREATE OR REPLACE FUNCTION multiply_state(state NUMERIC, val NUMERIC)
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
  SELECT COALESCE(state, 1) * COALESCE(val, 1);
$$;

-- Step B: aggregate
DROP AGGREGATE IF EXISTS product_of_quantities(NUMERIC);
CREATE AGGREGATE product_of_quantities(NUMERIC) (
  SFUNC    = multiply_state,
  STYPE    = NUMERIC,
  INITCOND = '1'
);

-- Example:
-- SELECT product_id, product_of_quantities(quantity) AS qty_product
-- FROM sales
-- GROUP BY product_id;


-- =========================================
-- UDF 4/5 — Scalar: order_total(order_id)
-- =========================================
CREATE OR REPLACE FUNCTION order_total(p_order_id INT)
RETURNS NUMERIC
LANGUAGE sql
STABLE
PARALLEL SAFE
AS $$
  SELECT COALESCE(SUM(s.total_sales), 0)
  FROM sales s
  WHERE s.order_id = p_order_id
$$;

-- Example:
-- SELECT o.order_id, o.order_date, order_total(o.order_id) AS total
-- FROM orders o
-- ORDER BY o.order_date DESC
-- LIMIT 10;


-- =========================================
-- UDF 5/5 — TVF: top_products_by_revenue(n)
-- =========================================
CREATE OR REPLACE FUNCTION top_products_by_revenue(p_limit INT)
RETURNS TABLE (
  product_id   INT,
  product_name TEXT,
  revenue      NUMERIC,
  qty          BIGINT
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(s.total_sales), 0) AS revenue,
    COALESCE(SUM(s.quantity), 0)    AS qty
  FROM products p
  LEFT JOIN sales s ON s.product_id = p.product_id
  GROUP BY p.product_id, p.product_name
  ORDER BY revenue DESC, qty DESC, p.product_id
  LIMIT GREATEST(p_limit, 0)
$$;

-- Example:
-- SELECT * FROM top_products_by_revenue(10);

-- Upsert (insert or update) a product
CREATE OR REPLACE PROCEDURE upsert_product(
    p_id    INT,
    p_name  TEXT,
    p_price NUMERIC,
    p_desc  TEXT,
    p_cat   TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_inserted BOOLEAN;
BEGIN
  -- Validate id
  IF p_id IS NULL THEN
    RAISE EXCEPTION 'product_id (p_id) cannot be NULL';
  END IF;

  -- INSERT ... ON CONFLICT with partial update (NULL keeps existing)
  INSERT INTO products (product_id, product_name, price, description, category)
  VALUES (p_id, p_name, p_price, p_desc, p_cat)
  ON CONFLICT (product_id) DO UPDATE
    SET product_name = COALESCE(EXCLUDED.product_name, products.product_name),
        price        = COALESCE(EXCLUDED.price,        products.price),
        description  = COALESCE(EXCLUDED.description,  products.description),
        category     = COALESCE(EXCLUDED.category,     products.category)
  RETURNING (xmax = 0) INTO v_inserted;  -- true = inserted, false = updated

  IF v_inserted THEN
    RAISE NOTICE 'Inserted product %', p_id;
  ELSE
    RAISE NOTICE 'Updated product %', p_id;
  END IF;
END;
$$;

-- Examples:
-- CALL upsert_product(2001, 'USB-C Cable', 9.99, '1m braided', 'Accessories'); -- insert
-- CALL upsert_product(2001, NULL, 8.99, NULL, NULL);                           -- partial update (price only)