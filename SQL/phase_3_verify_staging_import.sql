-- E-Commerce Sales Analytics Dashboard
-- Phase 3: Verify staging import row counts

USE ecommerce_sales;

SELECT
    'stg_customers' AS table_name,
    99441 AS expected_rows,
    COUNT(*) AS actual_rows,
    CASE WHEN COUNT(*) = 99441 THEN 'PASS' ELSE 'FAIL' END AS status
FROM stg_customers
UNION ALL
SELECT
    'stg_orders',
    99441,
    COUNT(*),
    CASE WHEN COUNT(*) = 99441 THEN 'PASS' ELSE 'FAIL' END
FROM stg_orders
UNION ALL
SELECT
    'stg_order_items',
    112650,
    COUNT(*),
    CASE WHEN COUNT(*) = 112650 THEN 'PASS' ELSE 'FAIL' END
FROM stg_order_items
UNION ALL
SELECT
    'stg_order_payments',
    103886,
    COUNT(*),
    CASE WHEN COUNT(*) = 103886 THEN 'PASS' ELSE 'FAIL' END
FROM stg_order_payments
UNION ALL
SELECT
    'stg_order_reviews',
    99224,
    COUNT(*),
    CASE WHEN COUNT(*) = 99224 THEN 'PASS' ELSE 'FAIL' END
FROM stg_order_reviews
UNION ALL
SELECT
    'stg_products',
    32951,
    COUNT(*),
    CASE WHEN COUNT(*) = 32951 THEN 'PASS' ELSE 'FAIL' END
FROM stg_products
UNION ALL
SELECT
    'stg_sellers',
    3095,
    COUNT(*),
    CASE WHEN COUNT(*) = 3095 THEN 'PASS' ELSE 'FAIL' END
FROM stg_sellers
UNION ALL
SELECT
    'stg_geolocation',
    1000163,
    COUNT(*),
    CASE WHEN COUNT(*) = 1000163 THEN 'PASS' ELSE 'FAIL' END
FROM stg_geolocation
UNION ALL
SELECT
    'stg_product_category_translation',
    71,
    COUNT(*),
    CASE WHEN COUNT(*) = 71 THEN 'PASS' ELSE 'FAIL' END
FROM stg_product_category_translation;

SELECT
    table_name,
    rows_with_blank_required_values
FROM (
    SELECT
        'stg_customers' AS table_name,
        SUM(customer_id = '' OR customer_unique_id = '') AS rows_with_blank_required_values
    FROM stg_customers
    UNION ALL
    SELECT
        'stg_orders',
        SUM(order_id = '' OR customer_id = '' OR order_status = '' OR order_purchase_timestamp = '' OR order_estimated_delivery_date = '')
    FROM stg_orders
    UNION ALL
    SELECT
        'stg_order_items',
        SUM(order_id = '' OR order_item_id = '' OR product_id = '' OR seller_id = '' OR shipping_limit_date = '' OR price = '' OR freight_value = '')
    FROM stg_order_items
    UNION ALL
    SELECT
        'stg_order_payments',
        SUM(order_id = '' OR payment_sequential = '' OR payment_type = '' OR payment_installments = '' OR payment_value = '')
    FROM stg_order_payments
    UNION ALL
    SELECT
        'stg_order_reviews',
        SUM(review_id = '' OR order_id = '' OR review_score = '' OR review_creation_date = '')
    FROM stg_order_reviews
    UNION ALL
    SELECT
        'stg_products',
        SUM(product_id = '')
    FROM stg_products
    UNION ALL
    SELECT
        'stg_sellers',
        SUM(seller_id = '')
    FROM stg_sellers
    UNION ALL
    SELECT
        'stg_geolocation',
        SUM(geolocation_zip_code_prefix = '' OR geolocation_lat = '' OR geolocation_lng = '')
    FROM stg_geolocation
    UNION ALL
    SELECT
        'stg_product_category_translation',
        SUM(product_category_name = '' OR product_category_name_english = '')
    FROM stg_product_category_translation
) AS required_value_checks
ORDER BY table_name;
