-- 03_seed_from_csv.sql
-- COPY must read files inside the container; we mounted ./data to /docker-entrypoint-initdb.d/data

\echo 'Loading employees...'
COPY employees(employee_id,first_name,last_name,email,salary)
FROM '/docker-entrypoint-initdb.d/data/employees.csv'
WITH (FORMAT csv, HEADER true);

\echo 'Loading customers...'
COPY customers(customer_id,customer_name,address,city,zip_code)
FROM '/docker-entrypoint-initdb.d/data/customers.csv'
WITH (FORMAT csv, HEADER true);

\echo 'Loading products...'
COPY products(product_id,product_name,price,description,category)
FROM '/docker-entrypoint-initdb.d/data/products.csv'
WITH (FORMAT csv, HEADER true);

\echo 'Loading orders...'
\echo 'Loading orders...'
COPY orders(order_id,order_date,year,quarter,month)
FROM '/docker-entrypoint-initdb.d/data/orders.csv'
WITH (FORMAT csv, HEADER true);

\echo 'Loading sales...'
COPY sales(transaction_id,order_id,product_id,customer_id,employee_id,total_sales,quantity,discount)
FROM '/docker-entrypoint-initdb.d/data/sales.csv'
WITH (FORMAT csv, HEADER true);