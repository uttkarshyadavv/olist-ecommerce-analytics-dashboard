-- ============================================================
--                 07_LOGISTICS_ANALYSIS.SQL
-- ============================================================

-- ============================================================
-- 1. Average Delivery Time
-- ============================================================

SELECT
    AVG(order_delivered_customer_date - order_purchase_timestamp)
        AS avg_delivery_time
FROM orders
WHERE order_status = 'delivered';


-- ============================================================
-- 2. Average Delivery Delay / Early Delivery
-- ============================================================

SELECT
    AVG(order_estimated_delivery_date - order_delivered_customer_date)
        AS avg_delivery_difference
FROM orders
WHERE order_status = 'delivered';


-- ============================================================
-- 3. Late Delivery Percentage
-- ============================================================

WITH status AS (

    SELECT
        CASE
            WHEN order_status = 'delivered'
                 AND order_delivered_customer_date <= order_estimated_delivery_date
                THEN 'ontime'

            WHEN order_status = 'delivered'
                 AND order_delivered_customer_date > order_estimated_delivery_date
                THEN 'late'

            ELSE 'others'
        END AS delivery_status

    FROM orders
),

numerical AS (

    SELECT
        delivery_status,
        COUNT(*) AS category_count
    FROM status
    GROUP BY delivery_status
)

SELECT
    (SELECT category_count
     FROM numerical
     WHERE delivery_status = 'late') * 100.0
    /
    (SELECT SUM(category_count)
     FROM numerical
     WHERE delivery_status <> 'others')
     AS late_delivery_percentage;


-- ============================================================
-- 4. State-wise Average Delivery Time
-- ============================================================

SELECT
    c.customer_state,
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp)
        AS avg_delivery_time
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delivery_time;


-- ============================================================
-- 5. Top 10 Fastest States
-- ============================================================

SELECT
    c.customer_state,
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp)
        AS avg_delivery_time
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delivery_time ASC
LIMIT 10;


-- ============================================================
-- 6. Top 10 Slowest States
-- ============================================================

SELECT
    c.customer_state,
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp)
        AS avg_delivery_time
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delivery_time DESC
LIMIT 10;


-- ============================================================
-- 7. Seller Delivery Performance
-- ============================================================

SELECT
    s.seller_id,
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp)
        AS avg_delivery_time
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id
ORDER BY avg_delivery_time;


-- ============================================================
-- 8. Freight Cost Analysis
-- ============================================================

SELECT
    s.seller_id,
    AVG(oi.freight_value) AS avg_freight_cost,
    SUM(oi.freight_value) AS total_freight_cost
FROM sellers s
INNER JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
ORDER BY total_freight_cost DESC;


-- ============================================================
-- 9. Logistics Dashboard KPI
-- ============================================================

SELECT
    COUNT(*) AS total_delivered_orders,

    AVG(order_delivered_customer_date - order_purchase_timestamp)
        AS avg_delivery_time,

    AVG(order_estimated_delivery_date - order_delivered_customer_date)
        AS avg_delivery_difference,

    SUM(
        CASE
            WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS ontime_deliveries,

    SUM(
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_deliveries,

    SUM(
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) * 100.0 / COUNT(*) AS late_delivery_percentage

FROM orders
WHERE order_status = 'delivered';
