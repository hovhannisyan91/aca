CREATE TEMP TABLE tmp_order_products AS
SELECT
	o.order_id,
	-- oi.product_id,
	oi.quantity,
	p.product_name,
	p.category,
	p.price
FROM analytics.orders o
LEFT JOIN analytics.order_items oi ON (o.order_id = oi.order_id)
LEFT JOIN analytics.products p ON (oi.product_id = p.product_id)
