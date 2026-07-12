-- E-Commerce Sales Analytics Dashboard
-- Phase 5: Verify cleaned analytical tables

USE ecommerce_sales;

-- -----------------------------------------------------
-- 1. Clean table row counts
-- -----------------------------------------------------

SELECT
    'clean_row_count_check' AS check_group,
    table_name,
    expected_rows,
    actual_rows,
    CASE WHEN expected_rows = actual_rows THEN 'PASS' ELSE 'FAIL' END AS status
FROM (
    SELECT 'customers' AS table_name, 99441 AS expected_rows, COUNT(*) AS actual_rows FROM customers
    UNION ALL SELECT 'sellers', 3095, COUNT(*) FROM sellers
    UNION ALL SELECT 'product_category_translation', 73, COUNT(*) FROM product_category_translation
    UNION ALL SELECT 'products', 32951, COUNT(*) FROM products
    UNION ALL SELECT 'orders', 99441, COUNT(*) FROM orders
    UNION ALL SELECT 'order_items', 112650, COUNT(*) FROM order_items
    UNION ALL SELECT 'order_payments', 103886, COUNT(*) FROM order_payments
    UNION ALL SELECT 'order_reviews', 99224, COUNT(*) FROM order_reviews
    UNION ALL SELECT
        'geolocation_zip_prefixes',
        (SELECT COUNT(DISTINCT geolocation_zip_code_prefix) FROM stg_geolocation WHERE geolocation_zip_code_prefix <> ''),
        COUNT(*)
    FROM geolocation_zip_prefixes
) AS counts
ORDER BY table_name;

-- -----------------------------------------------------
-- 2. Key and relationship checks
-- -----------------------------------------------------

SELECT 'relationship_check' AS check_group, 'orders.customer_id missing in customers' AS check_name, COUNT(*) AS issue_rows
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_items.order_id missing in orders', COUNT(*)
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_items.product_id missing in products', COUNT(*)
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_items.seller_id missing in sellers', COUNT(*)
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_payments.order_id missing in orders', COUNT(*)
FROM order_payments op
LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_reviews.order_id missing in orders', COUNT(*)
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'relationship_check', 'products.product_category_name missing in translation', COUNT(*)
FROM products p
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- -----------------------------------------------------
-- 3. Cleaning outcome checks
-- -----------------------------------------------------

SELECT 'cleaning_outcome_check' AS check_group, 'missing category translations after cleaning' AS check_name, COUNT(*) AS issue_rows
FROM products p
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
UNION ALL
SELECT 'cleaning_outcome_check', 'products with NULL category', COUNT(*)
FROM products
WHERE product_category_name IS NULL
UNION ALL
SELECT 'cleaning_outcome_check', 'products with NULL weight/dimensions', COUNT(*)
FROM products
WHERE product_weight_g IS NULL
   OR product_length_cm IS NULL
   OR product_height_cm IS NULL
   OR product_width_cm IS NULL
UNION ALL
SELECT 'cleaning_outcome_check', 'reviews with duplicate review_id retained', COALESCE(SUM(review_count - 1), 0)
FROM (
    SELECT review_id, COUNT(*) AS review_count
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
) AS duplicate_reviews
UNION ALL
SELECT 'cleaning_outcome_check', 'orders with NULL approved date', COUNT(*)
FROM orders
WHERE order_approved_at IS NULL
UNION ALL
SELECT 'cleaning_outcome_check', 'orders with NULL carrier date', COUNT(*)
FROM orders
WHERE order_delivered_carrier_date IS NULL
UNION ALL
SELECT 'cleaning_outcome_check', 'orders with NULL customer delivery date', COUNT(*)
FROM orders
WHERE order_delivered_customer_date IS NULL
UNION ALL
SELECT 'cleaning_outcome_check', 'reviews with NULL comment title', COUNT(*)
FROM order_reviews
WHERE review_comment_title IS NULL
UNION ALL
SELECT 'cleaning_outcome_check', 'reviews with NULL comment message', COUNT(*)
FROM order_reviews
WHERE review_comment_message IS NULL
UNION ALL
SELECT 'cleaning_outcome_check', 'geolocation zip prefixes with duplicate rows', COUNT(*)
FROM (
    SELECT geolocation_zip_code_prefix
    FROM geolocation_zip_prefixes
    GROUP BY geolocation_zip_code_prefix
    HAVING COUNT(*) > 1
) AS duplicate_geo_prefixes;

-- -----------------------------------------------------
-- 4. Preserved anomaly checks for later analysis
-- -----------------------------------------------------

SELECT 'preserved_anomaly_check' AS check_group, 'orders.carrier_before_purchase' AS check_name, COUNT(*) AS issue_rows
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_delivered_carrier_date < order_purchase_timestamp
UNION ALL
SELECT 'preserved_anomaly_check', 'orders.customer_before_carrier', COUNT(*)
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date < order_delivered_carrier_date;
