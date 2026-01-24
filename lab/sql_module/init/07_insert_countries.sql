

-- Load core dimension tables from CSV files
\echo 'Loading core dimension tables from CSVs'
COPY analytics.countries
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/countries.csv'
CSV HEADER;

COPY analytics.regions
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/regions.csv'
CSV HEADER;

COPY analytics.cities
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/cities.csv'
CSV HEADER;

COPY analytics.customers
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/customers.csv'
CSV HEADER;

COPY analytics.products
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/products.csv'
CSV HEADER;

COPY analytics.orders
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/orders.csv'
CSV HEADER;


COPY analytics.order_items
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/order_items.csv'
CSV HEADER;

-- Load staging boundary/point data with WKT geometries
\echo 'Loading staging WKT boundary/point CSVs'
COPY analytics._stg_country_boundaries
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/country_boundaries.csv'
CSV HEADER;



COPY analytics._stg_region_boundaries
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/region_boundaries.csv'
CSV HEADER;



COPY analytics._stg_city_boundaries
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/city_boundaries.csv'
CSV HEADER;




COPY analytics._stg_points
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/customer_locations.csv'
CSV HEADER;



-- Convert WKT to geometry and populate final spatial tables
\echo 'Inserting spatial geometries from staging tables'
INSERT INTO analytics.country_boundaries (country_id, geom)
SELECT
  country_id,
  ST_GeomFromText(wkt, 4326)
FROM analytics._stg_country_boundaries;


INSERT INTO analytics.region_boundaries (region_id, geom)
SELECT
  region_id,
  ST_GeomFromText(wkt, 4326)
FROM analytics._stg_region_boundaries;


INSERT INTO analytics.city_boundaries (city_id, geom)
SELECT
  city_id,
  ST_GeomFromText(wkt, 4326)
FROM analytics._stg_city_boundaries;

INSERT INTO analytics.customer_locations (customer_id, geom)
SELECT
  point_id,
  ST_GeomFromText(wkt, 4326)
FROM analytics._stg_points;
