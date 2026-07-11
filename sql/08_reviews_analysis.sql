-- ============================================================
--                  08_REVIEWS_ANALYSIS.SQL
-- ============================================================

-- ============================================================
-- 1. Average Review Score
-- ============================================================

SELECT
    AVG(review_score) AS avg_review_score
FROM reviews;


-- ============================================================
-- 2. Review Score Distribution
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM reviews
GROUP BY review_score
ORDER BY review_score DESC;


-- ============================================================
-- 3. Average Review Score by State
-- ============================================================

SELECT
    c.customer_state,
    AVG(r.review_score) AS avg_review_score
FROM reviews r
INNER JOIN orders o
    ON r.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_review_score DESC;


-- ============================================================
-- 4. Seller-wise Average Review Score
-- ============================================================

SELECT
    s.seller_id,
    AVG(r.review_score) AS avg_review_score
FROM reviews r
INNER JOIN orders o
    ON r.order_id = o.order_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_id
ORDER BY avg_review_score DESC;


-- ============================================================
-- 5. Delivery Time vs Review Score
-- ============================================================

SELECT
    r.review_score,
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp)
        AS avg_delivery_time
FROM reviews r
INNER JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score DESC;


-- ============================================================
-- 6. Product Category vs Review Score
-- ============================================================

SELECT
    p.product_category_name,
    AVG(r.review_score) AS avg_review_score
FROM reviews r
INNER JOIN orders o
    ON r.order_id = o.order_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;
