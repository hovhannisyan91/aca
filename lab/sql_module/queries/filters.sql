SELECT
    co.country_name,
    SUM(p.amount) AS total_revenue,
    COUNT(DISTINCT c.customer_id) AS total_customers
FROM analytics.payment p
JOIN analytics.rental r
ON r.rental_id = p.rental_id
JOIN analytics.customer c   ON c.customer_id = r.customer_id
JOIN analytics.address a    ON a.address_id = c.address_id
JOIN analytics.city ci      ON ci.city_id = a.city_id
JOIN analytics.country co   ON co.country_id = ci.country_id
GROUP BY co.country_name
ORDER BY total_revenue DESC;
