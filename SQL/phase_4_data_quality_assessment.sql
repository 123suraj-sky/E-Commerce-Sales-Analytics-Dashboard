-- E-Commerce Sales Analytics Dashboard
-- Phase 4: Data quality assessment on staging tables
--
-- Run after Phase 3 import and verification.

USE ecommerce_sales;

-- -----------------------------------------------------
-- 1. Row count sanity check
-- -----------------------------------------------------

SELECT
    'row_count_check' AS check_group,
    table_name,
    expected_rows,
    actual_rows,
    CASE WHEN expected_rows = actual_rows THEN 'PASS' ELSE 'FAIL' END AS status
FROM (
    SELECT 'stg_customers' AS table_name, 99441 AS expected_rows, COUNT(*) AS actual_rows FROM stg_customers
    UNION ALL SELECT 'stg_orders', 99441, COUNT(*) FROM stg_orders
    UNION ALL SELECT 'stg_order_items', 112650, COUNT(*) FROM stg_order_items
    UNION ALL SELECT 'stg_order_payments', 103886, COUNT(*) FROM stg_order_payments
    UNION ALL SELECT 'stg_order_reviews', 99224, COUNT(*) FROM stg_order_reviews
    UNION ALL SELECT 'stg_products', 32951, COUNT(*) FROM stg_products
    UNION ALL SELECT 'stg_sellers', 3095, COUNT(*) FROM stg_sellers
    UNION ALL SELECT 'stg_geolocation', 1000163, COUNT(*) FROM stg_geolocation
    UNION ALL SELECT 'stg_product_category_translation', 71, COUNT(*) FROM stg_product_category_translation
) AS row_counts
ORDER BY table_name;

-- -----------------------------------------------------
-- 2. Blank and missing value profile
-- -----------------------------------------------------

SELECT 'blank_value_check' AS check_group, 'stg_orders.order_approved_at' AS field_name, COUNT(*) AS blank_rows FROM stg_orders WHERE order_approved_at = ''
UNION ALL SELECT 'blank_value_check', 'stg_orders.order_delivered_carrier_date', COUNT(*) FROM stg_orders WHERE order_delivered_carrier_date = ''
UNION ALL SELECT 'blank_value_check', 'stg_orders.order_delivered_customer_date', COUNT(*) FROM stg_orders WHERE order_delivered_customer_date = ''
UNION ALL SELECT 'blank_value_check', 'stg_order_reviews.review_comment_title', COUNT(*) FROM stg_order_reviews WHERE review_comment_title = ''
UNION ALL SELECT 'blank_value_check', 'stg_order_reviews.review_comment_message', COUNT(*) FROM stg_order_reviews WHERE review_comment_message = ''
UNION ALL SELECT 'blank_value_check', 'stg_products.product_category_name', COUNT(*) FROM stg_products WHERE product_category_name = ''
UNION ALL SELECT 'blank_value_check', 'stg_products.product_name_lenght', COUNT(*) FROM stg_products WHERE product_name_lenght = ''
UNION ALL SELECT 'blank_value_check', 'stg_products.product_description_lenght', COUNT(*) FROM stg_products WHERE product_description_lenght = ''
UNION ALL SELECT 'blank_value_check', 'stg_products.product_photos_qty', COUNT(*) FROM stg_products WHERE product_photos_qty = ''
UNION ALL SELECT 'blank_value_check', 'stg_products.product_weight_g', COUNT(*) FROM stg_products WHERE product_weight_g = ''
UNION ALL SELECT 'blank_value_check', 'stg_products.product_length_cm', COUNT(*) FROM stg_products WHERE product_length_cm = ''
UNION ALL SELECT 'blank_value_check', 'stg_products.product_height_cm', COUNT(*) FROM stg_products WHERE product_height_cm = ''
UNION ALL SELECT 'blank_value_check', 'stg_products.product_width_cm', COUNT(*) FROM stg_products WHERE product_width_cm = ''
ORDER BY field_name;

-- -----------------------------------------------------
-- 3. Full-row duplicate profile
-- -----------------------------------------------------

SELECT 'full_row_duplicate_check' AS check_group, 'stg_customers' AS table_name, COUNT(*) AS duplicate_full_row_groups, COALESCE(SUM(row_count - 1), 0) AS extra_duplicate_rows
FROM (
    SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, COUNT(*) AS row_count
    FROM stg_customers
    GROUP BY customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'full_row_duplicate_check', 'stg_orders', COUNT(*), COALESCE(SUM(row_count - 1), 0)
FROM (
    SELECT order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date, COUNT(*) AS row_count
    FROM stg_orders
    GROUP BY order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'full_row_duplicate_check', 'stg_order_items', COUNT(*), COALESCE(SUM(row_count - 1), 0)
FROM (
    SELECT order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value, COUNT(*) AS row_count
    FROM stg_order_items
    GROUP BY order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'full_row_duplicate_check', 'stg_order_payments', COUNT(*), COALESCE(SUM(row_count - 1), 0)
FROM (
    SELECT order_id, payment_sequential, payment_type, payment_installments, payment_value, COUNT(*) AS row_count
    FROM stg_order_payments
    GROUP BY order_id, payment_sequential, payment_type, payment_installments, payment_value
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'full_row_duplicate_check', 'stg_order_reviews', COUNT(*), COALESCE(SUM(row_count - 1), 0)
FROM (
    SELECT review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp, COUNT(*) AS row_count
    FROM stg_order_reviews
    GROUP BY review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'full_row_duplicate_check', 'stg_products', COUNT(*), COALESCE(SUM(row_count - 1), 0)
FROM (
    SELECT product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm, COUNT(*) AS row_count
    FROM stg_products
    GROUP BY product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'full_row_duplicate_check', 'stg_sellers', COUNT(*), COALESCE(SUM(row_count - 1), 0)
FROM (
    SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state, COUNT(*) AS row_count
    FROM stg_sellers
    GROUP BY seller_id, seller_zip_code_prefix, seller_city, seller_state
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'full_row_duplicate_check', 'stg_geolocation', COUNT(*), COALESCE(SUM(row_count - 1), 0)
FROM (
    SELECT geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state, COUNT(*) AS row_count
    FROM stg_geolocation
    GROUP BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT 'full_row_duplicate_check', 'stg_product_category_translation', COUNT(*), COALESCE(SUM(row_count - 1), 0)
FROM (
    SELECT product_category_name, product_category_name_english, COUNT(*) AS row_count
    FROM stg_product_category_translation
    GROUP BY product_category_name, product_category_name_english
    HAVING COUNT(*) > 1
) AS d;

-- -----------------------------------------------------
-- 4. Duplicate key candidate profile
-- -----------------------------------------------------

SELECT
    'duplicate_key_check' AS check_group,
    key_candidate,
    COUNT(*) AS duplicate_keys,
    COALESCE(SUM(row_count - 1), 0) AS extra_duplicate_rows
FROM (
    SELECT 'stg_customers.customer_id' AS key_candidate, customer_id AS key_value, COUNT(*) AS row_count
    FROM stg_customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'stg_orders.order_id', order_id, COUNT(*)
    FROM stg_orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'stg_order_items.(order_id, order_item_id)', CONCAT(order_id, '|', order_item_id), COUNT(*)
    FROM stg_order_items
    GROUP BY order_id, order_item_id
    HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'stg_order_payments.(order_id, payment_sequential)', CONCAT(order_id, '|', payment_sequential), COUNT(*)
    FROM stg_order_payments
    GROUP BY order_id, payment_sequential
    HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'stg_order_reviews.review_id', review_id, COUNT(*)
    FROM stg_order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'stg_products.product_id', product_id, COUNT(*)
    FROM stg_products
    GROUP BY product_id
    HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'stg_sellers.seller_id', seller_id, COUNT(*)
    FROM stg_sellers
    GROUP BY seller_id
    HAVING COUNT(*) > 1
    UNION ALL
    SELECT 'stg_product_category_translation.product_category_name', product_category_name, COUNT(*)
    FROM stg_product_category_translation
    GROUP BY product_category_name
    HAVING COUNT(*) > 1
) AS duplicate_keys
GROUP BY key_candidate
ORDER BY key_candidate;

-- -----------------------------------------------------
-- 5. Foreign key and relationship coverage
-- -----------------------------------------------------

SELECT 'relationship_check' AS check_group, 'orders.customer_id missing in customers' AS relationship_name, COUNT(*) AS missing_rows
FROM stg_orders o
LEFT JOIN stg_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_items.order_id missing in orders', COUNT(*)
FROM stg_order_items oi
LEFT JOIN stg_orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_items.product_id missing in products', COUNT(*)
FROM stg_order_items oi
LEFT JOIN stg_products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_items.seller_id missing in sellers', COUNT(*)
FROM stg_order_items oi
LEFT JOIN stg_sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_payments.order_id missing in orders', COUNT(*)
FROM stg_order_payments op
LEFT JOIN stg_orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'relationship_check', 'order_reviews.order_id missing in orders', COUNT(*)
FROM stg_order_reviews r
LEFT JOIN stg_orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'relationship_check', 'products.product_category_name missing in translation', COUNT(*)
FROM stg_products p
LEFT JOIN stg_product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name <> ''
  AND t.product_category_name IS NULL
UNION ALL
SELECT 'relationship_check', 'customers.customer_zip_code_prefix missing in geolocation', COUNT(*)
FROM stg_customers c
LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM stg_geolocation
) g ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE c.customer_zip_code_prefix <> ''
  AND g.geolocation_zip_code_prefix IS NULL
UNION ALL
SELECT 'relationship_check', 'sellers.seller_zip_code_prefix missing in geolocation', COUNT(*)
FROM stg_sellers s
LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM stg_geolocation
) g ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE s.seller_zip_code_prefix <> ''
  AND g.geolocation_zip_code_prefix IS NULL;

SELECT
    'missing_category_values' AS check_group,
    p.product_category_name,
    COUNT(*) AS product_rows
FROM stg_products p
LEFT JOIN stg_product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name <> ''
  AND t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY p.product_category_name;

SELECT 'missing_geolocation_unique_prefixes' AS check_group, 'customers.customer_zip_code_prefix' AS field_name, COUNT(DISTINCT c.customer_zip_code_prefix) AS missing_unique_prefixes
FROM stg_customers c
LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM stg_geolocation
) g ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE c.customer_zip_code_prefix <> ''
  AND g.geolocation_zip_code_prefix IS NULL
UNION ALL
SELECT 'missing_geolocation_unique_prefixes', 'sellers.seller_zip_code_prefix', COUNT(DISTINCT s.seller_zip_code_prefix)
FROM stg_sellers s
LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM stg_geolocation
) g ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE s.seller_zip_code_prefix <> ''
  AND g.geolocation_zip_code_prefix IS NULL;

-- -----------------------------------------------------
-- 6. Type conversion checks
-- -----------------------------------------------------

SELECT 'type_check' AS check_group, 'stg_order_items.order_item_id invalid integer' AS field_name, COUNT(*) AS invalid_rows
FROM stg_order_items
WHERE order_item_id <> '' AND NOT REGEXP_LIKE(order_item_id, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_order_items.price invalid decimal', COUNT(*)
FROM stg_order_items
WHERE price <> '' AND NOT REGEXP_LIKE(price, '^[0-9]+(\\.[0-9]+)?$')
UNION ALL SELECT 'type_check', 'stg_order_items.freight_value invalid decimal', COUNT(*)
FROM stg_order_items
WHERE freight_value <> '' AND NOT REGEXP_LIKE(freight_value, '^[0-9]+(\\.[0-9]+)?$')
UNION ALL SELECT 'type_check', 'stg_order_payments.payment_sequential invalid integer', COUNT(*)
FROM stg_order_payments
WHERE payment_sequential <> '' AND NOT REGEXP_LIKE(payment_sequential, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_order_payments.payment_installments invalid integer', COUNT(*)
FROM stg_order_payments
WHERE payment_installments <> '' AND NOT REGEXP_LIKE(payment_installments, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_order_payments.payment_value invalid decimal', COUNT(*)
FROM stg_order_payments
WHERE payment_value <> '' AND NOT REGEXP_LIKE(payment_value, '^[0-9]+(\\.[0-9]+)?$')
UNION ALL SELECT 'type_check', 'stg_order_reviews.review_score invalid integer', COUNT(*)
FROM stg_order_reviews
WHERE review_score <> '' AND NOT REGEXP_LIKE(review_score, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_products.product_name_lenght invalid integer', COUNT(*)
FROM stg_products
WHERE product_name_lenght <> '' AND NOT REGEXP_LIKE(product_name_lenght, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_products.product_description_lenght invalid integer', COUNT(*)
FROM stg_products
WHERE product_description_lenght <> '' AND NOT REGEXP_LIKE(product_description_lenght, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_products.product_photos_qty invalid integer', COUNT(*)
FROM stg_products
WHERE product_photos_qty <> '' AND NOT REGEXP_LIKE(product_photos_qty, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_products.product_weight_g invalid integer', COUNT(*)
FROM stg_products
WHERE product_weight_g <> '' AND NOT REGEXP_LIKE(product_weight_g, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_products.product_length_cm invalid integer', COUNT(*)
FROM stg_products
WHERE product_length_cm <> '' AND NOT REGEXP_LIKE(product_length_cm, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_products.product_height_cm invalid integer', COUNT(*)
FROM stg_products
WHERE product_height_cm <> '' AND NOT REGEXP_LIKE(product_height_cm, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_products.product_width_cm invalid integer', COUNT(*)
FROM stg_products
WHERE product_width_cm <> '' AND NOT REGEXP_LIKE(product_width_cm, '^[0-9]+$')
UNION ALL SELECT 'type_check', 'stg_geolocation.geolocation_lat invalid decimal', COUNT(*)
FROM stg_geolocation
WHERE geolocation_lat <> '' AND NOT REGEXP_LIKE(geolocation_lat, '^-?[0-9]+(\\.[0-9]+)?$')
UNION ALL SELECT 'type_check', 'stg_geolocation.geolocation_lng invalid decimal', COUNT(*)
FROM stg_geolocation
WHERE geolocation_lng <> '' AND NOT REGEXP_LIKE(geolocation_lng, '^-?[0-9]+(\\.[0-9]+)?$')
ORDER BY field_name;

-- -----------------------------------------------------
-- 7. Domain and range checks
-- -----------------------------------------------------

SELECT 'domain_check' AS check_group, 'orders.order_status unexpected value' AS field_name, COUNT(*) AS invalid_rows
FROM stg_orders
WHERE order_status NOT IN ('approved', 'canceled', 'created', 'delivered', 'invoiced', 'processing', 'shipped', 'unavailable')
UNION ALL SELECT 'domain_check', 'order_reviews.review_score outside 1-5', COUNT(*)
FROM stg_order_reviews
WHERE CAST(review_score AS UNSIGNED) NOT BETWEEN 1 AND 5
UNION ALL SELECT 'domain_check', 'order_items.price negative', COUNT(*)
FROM stg_order_items
WHERE CAST(price AS DECIMAL(10,2)) < 0
UNION ALL SELECT 'domain_check', 'order_items.freight_value negative', COUNT(*)
FROM stg_order_items
WHERE CAST(freight_value AS DECIMAL(10,2)) < 0
UNION ALL SELECT 'domain_check', 'order_payments.payment_value negative', COUNT(*)
FROM stg_order_payments
WHERE CAST(payment_value AS DECIMAL(10,2)) < 0
UNION ALL SELECT 'domain_check', 'geolocation.latitude outside valid range', COUNT(*)
FROM stg_geolocation
WHERE CAST(geolocation_lat AS DECIMAL(10,8)) NOT BETWEEN -90 AND 90
UNION ALL SELECT 'domain_check', 'geolocation.longitude outside valid range', COUNT(*)
FROM stg_geolocation
WHERE CAST(geolocation_lng AS DECIMAL(11,8)) NOT BETWEEN -180 AND 180
ORDER BY field_name;

SELECT
    'order_status_distribution' AS check_group,
    order_status,
    COUNT(*) AS order_rows
FROM stg_orders
GROUP BY order_status
ORDER BY order_rows DESC;

-- -----------------------------------------------------
-- 8. Date format and chronology checks
-- -----------------------------------------------------

SELECT 'date_format_check' AS check_group, 'orders.order_purchase_timestamp invalid' AS field_name, COUNT(*) AS invalid_rows
FROM stg_orders
WHERE order_purchase_timestamp <> ''
  AND STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s') IS NULL
UNION ALL SELECT 'date_format_check', 'orders.order_approved_at invalid', COUNT(*)
FROM stg_orders
WHERE order_approved_at <> ''
  AND STR_TO_DATE(order_approved_at, '%Y-%m-%d %H:%i:%s') IS NULL
UNION ALL SELECT 'date_format_check', 'orders.order_delivered_carrier_date invalid', COUNT(*)
FROM stg_orders
WHERE order_delivered_carrier_date <> ''
  AND STR_TO_DATE(order_delivered_carrier_date, '%Y-%m-%d %H:%i:%s') IS NULL
UNION ALL SELECT 'date_format_check', 'orders.order_delivered_customer_date invalid', COUNT(*)
FROM stg_orders
WHERE order_delivered_customer_date <> ''
  AND STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s') IS NULL
UNION ALL SELECT 'date_format_check', 'orders.order_estimated_delivery_date invalid', COUNT(*)
FROM stg_orders
WHERE order_estimated_delivery_date <> ''
  AND STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s') IS NULL
UNION ALL SELECT 'date_format_check', 'order_items.shipping_limit_date invalid', COUNT(*)
FROM stg_order_items
WHERE shipping_limit_date <> ''
  AND STR_TO_DATE(shipping_limit_date, '%Y-%m-%d %H:%i:%s') IS NULL
UNION ALL SELECT 'date_format_check', 'order_reviews.review_creation_date invalid', COUNT(*)
FROM stg_order_reviews
WHERE review_creation_date <> ''
  AND STR_TO_DATE(review_creation_date, '%Y-%m-%d %H:%i:%s') IS NULL
UNION ALL SELECT 'date_format_check', 'order_reviews.review_answer_timestamp invalid', COUNT(*)
FROM stg_order_reviews
WHERE review_answer_timestamp <> ''
  AND STR_TO_DATE(review_answer_timestamp, '%Y-%m-%d %H:%i:%s') IS NULL
ORDER BY field_name;

SELECT 'date_chronology_check' AS check_group, 'orders.approved_before_purchase' AS issue_name, COUNT(*) AS issue_rows
FROM stg_orders
WHERE order_approved_at <> ''
  AND STR_TO_DATE(order_approved_at, '%Y-%m-%d %H:%i:%s') < STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
UNION ALL SELECT 'date_chronology_check', 'orders.carrier_before_purchase', COUNT(*)
FROM stg_orders
WHERE order_delivered_carrier_date <> ''
  AND STR_TO_DATE(order_delivered_carrier_date, '%Y-%m-%d %H:%i:%s') < STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
UNION ALL SELECT 'date_chronology_check', 'orders.customer_before_purchase', COUNT(*)
FROM stg_orders
WHERE order_delivered_customer_date <> ''
  AND STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s') < STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
UNION ALL SELECT 'date_chronology_check', 'orders.customer_before_carrier', COUNT(*)
FROM stg_orders
WHERE order_delivered_customer_date <> ''
  AND order_delivered_carrier_date <> ''
  AND STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s') < STR_TO_DATE(order_delivered_carrier_date, '%Y-%m-%d %H:%i:%s')
UNION ALL SELECT 'date_chronology_check', 'orders.estimated_before_purchase', COUNT(*)
FROM stg_orders
WHERE STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s') < STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
UNION ALL SELECT 'date_chronology_check', 'reviews.answer_before_creation', COUNT(*)
FROM stg_order_reviews
WHERE review_answer_timestamp <> ''
  AND STR_TO_DATE(review_answer_timestamp, '%Y-%m-%d %H:%i:%s') < STR_TO_DATE(review_creation_date, '%Y-%m-%d %H:%i:%s')
ORDER BY issue_name;
