
CREATE TABLE analytics.countries (
    country_id   INT PRIMARY KEY,
    country_name TEXT NOT NULL
);

CREATE TABLE analytics.regions (
    region_id   INT PRIMARY KEY,
    region_name TEXT NOT NULL,
    country_id  INT NOT NULL REFERENCES analytics.countries(country_id)
);

CREATE TABLE analytics.cities (
    city_id   INT PRIMARY KEY,
    city_name TEXT NOT NULL,
    region_id INT NOT NULL REFERENCES analytics.regions(region_id)
);

CREATE TABLE analytics.customers (
    customer_id INT PRIMARY KEY,
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    age         INT CHECK (age BETWEEN 16 AND 100),
    email       TEXT UNIQUE,
    city_id     INT REFERENCES analytics.cities(city_id),
    signup_date DATE NOT NULL
);

CREATE TABLE analytics.products (
    product_id   INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category     TEXT NOT NULL,
    price        NUMERIC(10,2) NOT NULL
);

CREATE TABLE analytics.orders (
    order_id    INT PRIMARY KEY,
    customer_id INT REFERENCES analytics.customers(customer_id),
    order_date  DATE NOT NULL,
    status      TEXT NOT NULL
);

CREATE TABLE analytics.order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES analytics.orders(order_id),
    product_id    INT NOT NULL REFERENCES analytics.products(product_id),
    quantity      INT NOT NULL CHECK (quantity > 0)
);

CREATE TABLE analytics.country_boundaries (
    country_id INT PRIMARY KEY REFERENCES analytics.countries(country_id),
    geom       GEOMETRY(MultiPolygon, 4326)
);

CREATE TABLE analytics.region_boundaries (
    region_id INT PRIMARY KEY REFERENCES analytics.regions(region_id),
    geom      GEOMETRY(Polygon, 4326)
);

CREATE TABLE analytics.city_boundaries (
    city_id INT PRIMARY KEY REFERENCES analytics.cities(city_id),
    geom    GEOMETRY(Polygon, 4326)
);

CREATE TABLE analytics.customer_locations (
    customer_id INT PRIMARY KEY REFERENCES analytics.customers(customer_id),
    geom        GEOMETRY(Point, 4326)
);
