

CREATE TEMP TABLE tmp_order_products AS (
	SELECT
		o.order_id,
		o.customer_id,
		oi.quantity,
		p.price,
		oi.quantity*p.price AS order_revenue,
		p.product_name,
		p.category
	FROM analytics.orders o
	INNER JOIN analytics.order_items oi ON (o.order_id = oi.order_id)
	LEFT JOIN  analytics.products p ON (oi.product_id = p.product_id)
)
;

-- What is the average order revenue per customer, and which customers are above the overall average?

WITH avg_customer AS (
	SELECT 
		customer_id,
		AVG(order_revenue) as avg_revenue
	FROM tmp_order_products 
	GROUP BY customer_id
)

SELECT 
	
FROM avg_customer
WHERE avg_revenue > (
	SELECT AVG(order_revenue) FROM tmp_order_products
)


