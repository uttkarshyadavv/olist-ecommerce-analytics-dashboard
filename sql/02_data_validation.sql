-- ============================================================
--               02_DATA_VALIDATION.SQL
-- ============================================================

-- ============================================================
-- 1. VERIFY ROW COUNTS
-- ============================================================

SELECT COUNT(*) AS total_customers FROM customers;

SELECT COUNT(*) AS total_orders FROM orders;

SELECT COUNT(*) AS total_order_items FROM order_items;

SELECT COUNT(*) AS total_products FROM products;

SELECT COUNT(*) AS total_payments FROM payments;

SELECT COUNT(*) AS total_reviews FROM reviews;

SELECT COUNT(*) AS total_sellers FROM sellers;

SELECT COUNT(*) AS total_geolocations FROM geolocation;

SELECT COUNT(*) AS total_categories
FROM product_category_translation;

-- ============================================================
-- 2. CHECK DUPLICATE PRIMARY KEYS
-- ============================================================

-- Customers
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Orders
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Products
SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Sellers
SELECT seller_id, COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- ============================================================
-- 3. CHECK NULL VALUES
-- ============================================================

-- Customers
SELECT *
FROM customers
WHERE customer_id IS NULL
   OR customer_unique_id IS NULL;

-- Orders
SELECT *
FROM orders
WHERE customer_id IS NULL
   OR order_purchase_timestamp IS NULL
   OR order_status IS NULL;

-- Products
SELECT *
FROM products
WHERE product_category_name IS NULL;

-- Reviews
SELECT *
FROM reviews
WHERE review_score IS NULL;

-- Order Items
SELECT *
FROM order_items
WHERE price IS NULL
   OR freight_value IS NULL;

-- Payments
SELECT *
FROM payments
WHERE payment_value IS NULL;

-- ============================================================
-- 4. CHECK INVALID VALUES
-- ============================================================

-- Negative Product Price
SELECT *
FROM order_items
WHERE price < 0;

-- Negative Freight Cost
SELECT *
FROM order_items
WHERE freight_value < 0;

-- Negative Payment Value
SELECT *
FROM payments
WHERE payment_value < 0;

-- Invalid Review Score
SELECT *
FROM reviews
WHERE review_score NOT BETWEEN 1 AND 5;

-- ============================================================
-- 5. REFERENTIAL INTEGRITY CHECKS
-- ============================================================

-- Orders without Customers
SELECT o.order_id
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order Items without Orders
SELECT oi.order_id
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Order Items without Products
SELECT oi.product_id
FROM order_items oi
LEFT JOIN products p
ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Order Items without Sellers
SELECT oi.seller_id
FROM order_items oi
LEFT JOIN sellers s
ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- ============================================================
-- OBSERVATIONS
-- ============================================================

-- 1. No duplicate primary keys found.
-- 2. 610 product records have missing product metadata.
-- 3. No negative prices or freight values.
-- 4. Review scores are within the valid range (1–5).
-- 5. Referential integrity is maintained across all major tables.
-- 6. 9 delivered orders have payment_value = 0 despite positive item prices.
--    These records are retained as a known data anomaly and may represent
--    voucher/store-credit payments or inconsistencies in the public dataset.
