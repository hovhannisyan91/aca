
CREATE TABLE analytics._stg_world_countries (
    country_name TEXT NOT NULL,
    country_code TEXT NOT NULL,
    geom geometry(MULTIPOLYGON, 4326) NOT NULL
);