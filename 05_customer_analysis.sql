-- ============================================================
--                  05_CUSTOMER_ANALYSIS.SQL
-- ============================================================

-- ============================================================
-- 1. Repeat Customers
-- ============================================================

SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;


-- ============================================================
-- 2. Repeat Purchase Rate
-- ============================================================

WITH repeat_customers AS (
    SELECT
        c.customer_unique_id
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
)

SELECT
    COUNT(*) * 100.0 /
    (SELECT COUNT(DISTINCT customer_unique_id) FROM customers)
    AS repeat_purchase_rate
FROM repeat_customers;


-- ============================================================
-- 3. Average Orders Per Customer
-- ============================================================

SELECT
    COUNT(order_id) * 1.0 /
    COUNT(DISTINCT customer_id) AS avg_orders_per_customer
FROM orders;


-- ============================================================
-- 4. Customer Lifetime Value (Top 10 Customers)
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
)

SELECT
    co.customer_unique_id,
    SUM(p.payment_value) AS lifetime_value
FROM customer_orders co
INNER JOIN payments p
    ON co.order_id = p.order_id
GROUP BY co.customer_unique_id
ORDER BY lifetime_value DESC
LIMIT 10;


-- ============================================================
-- 5. RFM Analysis & Customer Segmentation
-- ============================================================

WITH rfm AS (

    SELECT
        c.customer_unique_id,

        (
            (SELECT MAX(order_purchase_timestamp) FROM orders)
            - MAX(o.order_purchase_timestamp)
        ) AS recency,

        COUNT(o.order_id) AS frequency,

        SUM(p.payment_value) AS monetary

    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN payments p
        ON o.order_id = p.order_id

    GROUP BY c.customer_unique_id
),

rfm_score AS (

    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm
)

SELECT
    *,

    CASE
        WHEN r_score >= 4
         AND f_score >= 4
         AND m_score >= 4
            THEN 'Champion'

        WHEN f_score >= 4
         AND m_score >= 3
            THEN 'Loyal Customer'

        WHEN m_score = 5
            THEN 'Big Spender'

        WHEN r_score >= 4
         AND f_score >= 2
            THEN 'Potential Loyalist'

        WHEN r_score <= 2
         AND f_score >= 3
            THEN 'At Risk'

        WHEN r_score = 1
         AND f_score = 1
            THEN 'Lost Customer'

        ELSE 'Others'
    END AS customer_segment

FROM rfm_score;