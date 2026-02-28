-- EXTRACT and/or DATE_TRUNC 
SELECT 
  -- DATE_TRUNC('month', order_date_date) AS month,
  EXTRACT(MONTH FROM order_date_date) as M,
  EXTRACT(YEAR FROM order_date_date) as Y,
  SUM(total_sales) AS total_revenue
FROM sales_analysis
GROUP BY
	 EXTRACT(MONTH FROM order_date_date),
  	 EXTRACT(YEAR FROM order_date_date)
ORDER BY
	 EXTRACT(MONTH FROM order_date_date),
  	 EXTRACT(YEAR FROM order_date_date)
;