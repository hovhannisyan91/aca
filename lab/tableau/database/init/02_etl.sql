-- Load the CSV from the same initdb tree mounted into the container.

\echo 'Loading Salary Vs Coffee...'
\copy employee_coffee(employee_id, coffee_cups, salary_kusd) FROM '/etl-data/employee_coffee.csv' WITH (FORMAT csv, HEADER true);
