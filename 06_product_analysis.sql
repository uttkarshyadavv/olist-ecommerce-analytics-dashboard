-- ============================================================
--                  06_PRODUCT_ANALYSIS.SQL
-- ============================================================

-- ============================================================
-- 1. Top 10 Best Selling Products
-- ============================================================

SELECT
    p.product_id,
    p.product_category_name,
    COUNT(*) AS units_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_category_name
ORDER BY units_sold DESC
LIMIT 10;


-- ============================================================
-- 2. Top 10 Highest Revenue Products
-- ============================================================

SELECT
    p.product_id,
    p.product_category_name,
    SUM(oi.price) AS revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_category_name
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 3. Top 10 Most Expensive Products Sold
-- ============================================================

SELECT
    p.product_id,
    p.product_category_name,
    oi.price
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
ORDER BY oi.price DESC
LIMIT 10;


-- ============================================================
-- 4. Top 10 Cheapest Products Sold
-- ============================================================

SELECT
    p.product_id,
    p.product_category_name,
    oi.price
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
ORDER BY oi.price ASC
LIMIT 10;


-- ============================================================
-- 5. Average Selling Price by Category
-- ============================================================

SELECT
    p.product_category_name,
    AVG(oi.price) AS avg_selling_price
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY avg_selling_price DESC;


-- ============================================================
-- 6. Category-wise Product Count
-- ============================================================

SELECT
    product_category_name,
    COUNT(*) AS total_products
FROM products
GROUP BY product_category_name
ORDER BY total_products DESC;


-- ============================================================
-- 7. Product Performance Ranking
-- ============================================================

WITH product_stats AS (

    SELECT
        p.product_id,
        p.product_category_name,
        COUNT(*) AS units_sold,
        SUM(oi.price) AS revenue

    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.product_id,
        p.product_category_name
)

SELECT
    *,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY units_sold DESC) AS sales_rank
FROM product_stats
ORDER BY revenue_rank;