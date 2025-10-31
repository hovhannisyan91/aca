-- =========================================
-- SP: CREATE (Insert) - add_customer
-- =========================================
CREATE OR REPLACE PROCEDURE add_customer(
    p_customer_id   INT,
    p_customer_name TEXT,
    p_address       TEXT,
    p_city          TEXT,
    p_zip           TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO customers(customer_id, customer_name, address, city, zip_code)
    VALUES (p_customer_id, p_customer_name, p_address, p_city, p_zip);
END;
$$;

-- CALL add_customer(10001, 'John Doe', '123 Main St', 'Yerevan', '0010');


-- =========================================
-- SP: READ (Select via OUT params) - get_customer
-- =========================================
CREATE OR REPLACE PROCEDURE get_customer(
    p_customer_id INT,
    OUT o_name    TEXT,
    OUT o_city    TEXT,
    OUT o_zip     TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT customer_name, city, zip_code
      INTO o_name, o_city, o_zip
      FROM customers
     WHERE customer_id = p_customer_id;
END;
$$;

-- CALL get_customer(10001, NULL, NULL, NULL);


-- =========================================
-- SP: UPDATE - update_product_price
-- =========================================
CREATE OR REPLACE PROCEDURE update_product_price(
    p_product_id INT,
    p_new_price  NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE products
       SET price = p_new_price
     WHERE product_id = p_product_id;
END;
$$;

-- CALL update_product_price(2001, 19.99);


-- =========================================
-- SP: UPDATE - update_salary
-- =========================================
CREATE OR REPLACE PROCEDURE update_salary(
    p_employee_id      INT,
    p_percent_increase NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees
       SET salary = salary + (salary * p_percent_increase / 100.0)
     WHERE employee_id = p_employee_id;

    RAISE NOTICE 'Salary updated for Employee ID: %', p_employee_id;
END;
$$;

-- CALL update_salary(5, 10);


-- =========================================
-- SP: DELETE (safe with FK order) - delete_order_safe
--   Note: sales(order_id) -> orders(order_id) has ON DELETE RESTRICT.
--         Delete dependent rows in sales first, then the order.
-- =========================================
CREATE OR REPLACE PROCEDURE delete_order_safe(p_order_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM sales  WHERE order_id = p_order_id;
    DELETE FROM orders WHERE order_id = p_order_id;
END;
$$;

-- CALL delete_order_safe(30001);


-- =========================================
-- SP: APPLY DISCOUNT to a customer's sales lines
--   Updates discount and recalculates total_sales defensively.
-- =========================================
CREATE OR REPLACE PROCEDURE apply_loyalty_discount(
    p_customer_id INT,
    p_discount    NUMERIC  -- e.g., 0.05 = 5%
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE sales s
       SET discount   = COALESCE(discount, 0) + p_discount,
           total_sales = GREATEST(0, total_sales * (1 - p_discount))
     WHERE s.customer_id = p_customer_id;
END;
$$;

-- CALL apply_loyalty_discount(10001, 0.05);


-- =========================================
-- SP: TRANSFER CREDIT between employees (example of error handling)
--   Demonstrates validation & failure handling.
-- =========================================
CREATE OR REPLACE PROCEDURE transfer_credit(
    p_from_emp INT,
    p_to_emp   INT,
    p_amount   NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Amount must be positive';
    END IF;

    UPDATE employees SET salary = salary - p_amount WHERE employee_id = p_from_emp;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sender % not found', p_from_emp;
    END IF;

    UPDATE employees SET salary = salary + p_amount WHERE employee_id = p_to_emp;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Receiver % not found', p_to_emp;
    END IF;
END;
$$;

-- CALL transfer_credit(1, 2, 100);


-- =========================================
-- Simplified Batch Processing: Monthly Sales Summary Refresh
--   Creates a small summary table if missing and (re)loads for a given month.
--   Uses existing tables: sales, orders.
-- =========================================
CREATE TABLE IF NOT EXISTS monthly_sales_summary (
    year    INT,
    month   TEXT,
    product_id  INT,
    total_amount NUMERIC,
    total_qty    INT,
    PRIMARY KEY (year, month, product_id)
);

CREATE OR REPLACE PROCEDURE refresh_monthly_sales_summary(p_year INT, p_month TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Remove existing month to keep the proc idempotent
    DELETE FROM monthly_sales_summary
     WHERE year = p_year AND month = p_month;

    -- Recompute from facts
    INSERT INTO monthly_sales_summary(year, month, product_id, total_amount, total_qty)
    SELECT o.year,
           o.month,
           s.product_id,
           SUM(s.total_sales) AS total_amount,
           SUM(s.quantity)    AS total_qty
      FROM sales  s
      JOIN orders o ON o.order_id = s.order_id
     WHERE o.year  = p_year
       AND o.month = p_month
     GROUP BY o.year, o.month, s.product_id;
END;
$$;

-- CALL refresh_monthly_sales_summary(2025, 'Aug');