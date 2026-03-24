CREATE TEMP TABLE tmp_sales AS
SELECT *
FROM (
    VALUES
        
        (1,  'A', DATE '2024-01-01', 100, 2, 'Yerevan', 'online'),
        (2,  'A', DATE '2024-01-02', 120, 1, 'Yerevan', 'store'),
        (3,  'A', DATE '2024-01-03', 90,  3, 'Gyumri',  'online'),
        (4,  'A', DATE '2024-01-04', 130, 2, 'Gyumri',  'store'),

        
        (5,  'B', DATE '2024-01-01', 180, 4, 'Yerevan', 'store'),
        (6,  'B', DATE '2024-01-02', 200, 2, 'Vanadzor','online'),
        (7,  'B', DATE '2024-01-03', 220, 5, 'Vanadzor','online'),
        (8,  'B', DATE '2024-01-04', 200, 3, 'Yerevan', 'store'),

        
        (9,  'C', DATE '2024-01-01', 150, 2, 'Gyumri',  'online'),
        (10, 'C', DATE '2024-01-02', 150, 1, 'Gyumri',  'online'),
        (11, 'C', DATE '2024-01-03', 170, 3, 'Yerevan', 'online'),

        
        (12, 'D', DATE '2024-01-01', 90,  1, 'Vanadzor','store'),
        (13, 'D', DATE '2024-01-02', 110, 2, 'Vanadzor','store'),

        
        (14, 'E', DATE '2024-01-01', 140, 2, 'Yerevan', 'store'),
        (15, 'E', DATE '2024-01-02', 160, 3, 'Gyumri',  'online'),
        (16, 'E', DATE '2024-01-03', 155, 2, 'Yerevan', 'store')
) AS t(
    sale_id,
    customer_id,
    sale_date,
    amount,
    quantity,
    city,
    channel
);

SELECT 
	*,
	quantity*amount as revenue,
	percent_rank() OVER (PARTITION BY customer_id ORDER BY quantity*amount DESC) as percent_rank_rev
FROM atmp_sales



