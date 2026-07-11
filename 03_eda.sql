-- ============================================================
--                  03_EDA.SQL
-- ============================================================

-- ============================================================
-- BUSINESS OVERVIEW
-- ============================================================

-- Total Revenue
SELECT
    SUM(payment_value) AS total_revenue
FROM payments;

-- Total Orders
SELECT
    COUNT(order_id) AS total_orders
FROM orders;

-- Total Customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;

-- Total Sellers
SELECT
    COUNT(seller_id) AS total_sellers
FROM sellers;

-- Total Products
SELECT
    COUNT(product_id) AS total_products
FROM products;

-- ============================================================
-- TIME ANALYSIS
-- ============================================================

-- Orders by Year
SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    COUNT(*) AS total_orders
FROM orders
GROUP BY year
ORDER BY year;

-- Orders by Month (Seasonality)
SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

-- Orders by Year & Month (Trend)
SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY year, month
ORDER BY year, month;

-- Revenue by Year & Month
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    SUM(p.payment_value) AS total_revenue
FROM orders o
INNER JOIN payments p
ON o.order_id = p.order_id
GROUP BY year, month
ORDER BY year, month;

-- Orders by Weekday
SELECT
    EXTRACT(DOW FROM order_purchase_timestamp) AS weekday,
    COUNT(*) AS total_orders
FROM orders
GROUP BY weekday
ORDER BY weekday;

-- Orders by Hour
SELECT
    EXTRACT(HOUR FROM order_purchase_timestamp) AS hour,
    COUNT(*) AS total_orders
FROM orders
GROUP BY hour
ORDER BY hour;

-- ============================================================
-- KEY BUSINESS METRICS
-- ============================================================

-- Average Order Value (AOV)
SELECT
    SUM(payment_value) / COUNT(DISTINCT order_id) AS average_order_value
FROM payments;

-- Average Delivery Time
SELECT
    AVG(order_delivered_customer_date - order_purchase_timestamp)
    AS average_delivery_time
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;