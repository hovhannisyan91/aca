INSERT INTO analytics._stg_world_countries (country_name, country_code, geom)
SELECT
    feature->'properties'->>'name' AS country_name,
    feature->>'id' AS country_code,
    ST_SetSRID(
        ST_Multi(
            ST_CollectionExtract(
                ST_Force2D(
                    ST_MakeValid(
                        ST_GeomFromGeoJSON(feature->>'geometry')
                    )
                ),
            3)
        ),
        4326
    ) AS geom
FROM (
    SELECT jsonb_array_elements(data->'features') AS feature
    FROM (
        SELECT pg_read_file('/docker-entrypoint-initdb.d/data/test/countries.geo.json')::jsonb AS data
    ) f
) sub;