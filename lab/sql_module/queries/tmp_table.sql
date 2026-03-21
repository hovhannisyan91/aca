CREATE TEMP TABLE tmp_sales AS
SELECT *
FROM (
    VALUES
        
        (1,  'A', DATE '2024-01-01', 100, 'online'),
        (2,  'A', DATE '2024-01-02', 120, 'store'),
        (3,  'A', DATE '2024-01-03', 90,  'online'),
        (4,  'A', DATE '2024-01-04', 130, 'store'),

        
        (5,  'B', DATE '2024-01-01', 180, 'store'),
        (6,  'B', DATE '2024-01-02', 200, 'online'),
        (7,  'B', DATE '2024-01-03', 220, 'online'),
        (8,  'B', DATE '2024-01-04', 200, 'store'),

        
        (9,  'C', DATE '2024-01-01', 150, 'online'),
        (10, 'C', DATE '2024-01-02', 150, 'online'),
        (11, 'C', DATE '2024-01-03', 170, 'online'),

        
        (12, 'D', DATE '2024-01-01', 90,  'store'),
        (13, 'D', DATE '2024-01-02', 110, 'store'),

        
        (14, 'E', DATE '2024-01-01', 140, 'store'),
        (15, 'E', DATE '2024-01-02', 160, 'online'),
        (16, 'E', DATE '2024-01-03', 155, 'store')
) AS t(
    sale_id,
    customer_id,
    sale_date,
    amount,
    channel
);



WITH T AS (

	SELECT
	    sale_id,
	    customer_id,
	    sale_date,
	    amount,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY amount DESC) as rn_sd,
		RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) as rnk_sd,
		DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) as dense_sd
		
	FROM tmp_sales
)

SELECT 

	* 
FROM T 
WHERE rnk_sd <= 2