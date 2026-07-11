-- ============================================================
--                    04_SALES_ANALYSIS.SQL
-- ============================================================

-- ============================================================
-- 1. Revenue by Product Category
-- ============================================================

SELECT
    pct.product_category_name_english,
    SUM(oi.price) AS total_revenue
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY total_revenue DESC;


-- ============================================================
-- 2. Top 10 Product Categories by Revenue
-- ============================================================

SELECT
    pct.product_category_name_english,
    SUM(oi.price) AS total_revenue
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 3. Bottom 10 Product Categories by Revenue
-- ============================================================

SELECT
    pct.product_category_name_english,
    SUM(oi.price) AS total_revenue
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY total_revenue ASC
LIMIT 10;


-- ============================================================
-- 4. Revenue by State
-- ============================================================

SELECT
    c.customer_state,
    SUM(p.payment_value) AS total_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ============================================================
-- 5. Top 10 Sellers by Revenue
-- ============================================================

SELECT
    s.seller_id,
    SUM(oi.price) AS total_revenue
FROM sellers s
INNER JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 6. Top 10 Highest Value Orders
-- ============================================================

SELECT
    order_id,
    SUM(payment_value) AS revenue
FROM payments
GROUP BY order_id
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 7. Total Freight Cost
-- ============================================================

SELECT
    SUM(freight_value) AS total_freight_cost
FROM order_items;


-- ============================================================
-- 8. Average Freight Per Order
-- ============================================================

SELECT
    SUM(freight_value) /
    COUNT(DISTINCT order_id) AS avg_freight_per_order
FROM order_items;


-- ============================================================
-- 9. Freight as Percentage of Total Order Value
-- ============================================================

SELECT
    (SUM(freight_value) /
    SUM(price + freight_value)) * 100 AS freight_percentage
FROM order_items;


-- ============================================================
-- 10. Monthly Revenue Trend (LAG)
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
        SUM(oi.price) AS monthly_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY year, month
),

previous_month AS (
    SELECT
        *,
        LAG(monthly_revenue) OVER (
            ORDER BY year, month
        ) AS prev_monthly_revenue
    FROM monthly_revenue
)

SELECT
    *,
    monthly_revenue - prev_monthly_revenue AS monthly_growth
FROM previous_month
ORDER BY year, month;


-- ============================================================
-- 11. Running Revenue
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
        SUM(oi.price) AS monthly_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY year, month
)

SELECT
    *,
    SUM(monthly_revenue) OVER (
        ORDER BY year, month
    ) AS running_revenue
FROM monthly_revenue
ORDER BY year, month;


-- ============================================================
-- 12. Pareto Analysis (80/20 Rule)
-- ============================================================

WITH category AS (
    SELECT
        pct.product_category_name_english,
        SUM(oi.price) AS revenue
    FROM products p
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN product_category_translation pct
        ON p.product_category_name = pct.product_category_name
    GROUP BY pct.product_category_name_english
),

categorical AS (
    SELECT
        *,
        (SUM(revenue) OVER (ORDER BY revenue DESC) /
         SUM(revenue) OVER ()) * 100 AS cumulative_percentage
    FROM category
)

SELECT *
FROM categorical
WHERE cumulative_percentage <= 80
ORDER BY revenue DESC;