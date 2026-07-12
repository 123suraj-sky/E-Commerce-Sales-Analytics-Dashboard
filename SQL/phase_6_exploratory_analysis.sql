-- E-Commerce Sales Analytics Dashboard
-- Phase 6: Exploratory Data Analysis on clean analytical tables
--
-- Goal: establish baseline dataset context before deeper business analysis.

USE ecommerce_sales;

-- -----------------------------------------------------
-- 1. Dataset overview
-- -----------------------------------------------------

SELECT
    'dataset_overview' AS section,
    'customers' AS metric,
    COUNT(*) AS value
FROM customers
UNION ALL SELECT 'dataset_overview', 'unique_customers', COUNT(DISTINCT customer_unique_id) FROM customers
UNION ALL SELECT 'dataset_overview', 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'dataset_overview', 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'dataset_overview', 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'dataset_overview', 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'dataset_overview', 'products', COUNT(*) FROM products
UNION ALL SELECT 'dataset_overview', 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'dataset_overview', 'product_categories_translated', COUNT(*) FROM product_category_translation
UNION ALL SELECT 'dataset_overview', 'geolocation_zip_prefixes', COUNT(*) FROM geolocation_zip_prefixes;

-- -----------------------------------------------------
-- 2. Date coverage
-- -----------------------------------------------------

SELECT
    'date_coverage' AS section,
    MIN(order_purchase_timestamp) AS first_purchase,
    MAX(order_purchase_timestamp) AS last_purchase,
    COUNT(DISTINCT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS active_purchase_months
FROM orders;

SELECT
    'orders_by_year' AS section,
    YEAR(order_purchase_timestamp) AS purchase_year,
    COUNT(*) AS total_orders
FROM orders
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY purchase_year;

-- -----------------------------------------------------
-- 3. Order status and order size
-- -----------------------------------------------------

SELECT
    'order_status_distribution' AS section,
    order_status,
    COUNT(*) AS orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

SELECT
    'order_item_distribution' AS section,
    item_count_per_order,
    COUNT(*) AS orders
FROM (
    SELECT
        order_id,
        COUNT(*) AS item_count_per_order
    FROM order_items
    GROUP BY order_id
) AS order_item_counts
GROUP BY item_count_per_order
ORDER BY item_count_per_order;

-- -----------------------------------------------------
-- 4. Revenue and payment context
-- -----------------------------------------------------

SELECT
    'revenue_overview' AS section,
    ROUND(SUM(price), 2) AS product_revenue,
    ROUND(SUM(freight_value), 2) AS freight_revenue,
    ROUND(SUM(price + freight_value), 2) AS gross_item_value,
    ROUND(AVG(price), 2) AS avg_item_price,
    ROUND(AVG(freight_value), 2) AS avg_item_freight
FROM order_items;

SELECT
    'order_value_overview' AS section,
    COUNT(*) AS orders_with_items,
    ROUND(SUM(order_value), 2) AS gross_item_value,
    ROUND(AVG(order_value), 2) AS avg_order_value,
    ROUND(MIN(order_value), 2) AS min_order_value,
    ROUND(MAX(order_value), 2) AS max_order_value
FROM (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
) AS order_values;

SELECT
    'payment_overview' AS section,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value,
    ROUND(AVG(payment_installments), 2) AS avg_installments
FROM order_payments;

SELECT
    'payment_type_distribution' AS section,
    payment_type,
    COUNT(*) AS payment_rows,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_payment_rows
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;

-- -----------------------------------------------------
-- 5. Customer, seller, and geography context
-- -----------------------------------------------------

SELECT
    'customer_repeat_profile' AS section,
    order_count_per_unique_customer,
    COUNT(*) AS unique_customers
FROM (
    SELECT
        customer_unique_id,
        COUNT(*) AS order_count_per_unique_customer
    FROM customers
    GROUP BY customer_unique_id
) AS customer_order_counts
GROUP BY order_count_per_unique_customer
ORDER BY order_count_per_unique_customer;

SELECT
    'top_customer_states_by_orders' AS section,
    customer_state,
    COUNT(*) AS orders
FROM customers
GROUP BY customer_state
ORDER BY orders DESC
LIMIT 10;

SELECT
    'top_seller_states_by_sellers' AS section,
    seller_state,
    COUNT(*) AS sellers
FROM sellers
GROUP BY seller_state
ORDER BY sellers DESC
LIMIT 10;

-- -----------------------------------------------------
-- 6. Product and category context
-- -----------------------------------------------------

SELECT
    'product_category_overview' AS section,
    COUNT(*) AS products,
    COUNT(product_category_name) AS products_with_category,
    COUNT(*) - COUNT(product_category_name) AS products_without_category,
    COUNT(DISTINCT product_category_name) AS distinct_product_categories
FROM products;

SELECT
    'top_categories_by_items_sold' AS section,
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY COALESCE(t.product_category_name_english, 'unknown')
ORDER BY items_sold DESC
LIMIT 10;

-- -----------------------------------------------------
-- 7. Review context
-- -----------------------------------------------------

SELECT
    'review_overview' AS section,
    COUNT(*) AS reviews,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    SUM(review_comment_title IS NOT NULL) AS reviews_with_title,
    SUM(review_comment_message IS NOT NULL) AS reviews_with_message
FROM order_reviews;

SELECT
    'review_score_distribution' AS section,
    review_score,
    COUNT(*) AS reviews,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- -----------------------------------------------------
-- 8. Delivery context
-- -----------------------------------------------------

SELECT
    'delivery_overview_delivered_orders' AS section,
    COUNT(*) AS delivered_orders_with_customer_date,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 2) AS avg_delivery_days,
    MIN(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS min_delivery_days,
    MAX(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS max_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

SELECT
    'delivery_vs_estimate' AS section,
    SUM(order_delivered_customer_date <= order_estimated_delivery_date) AS delivered_on_or_before_estimate,
    SUM(order_delivered_customer_date > order_estimated_delivery_date) AS delivered_after_estimate,
    ROUND(SUM(order_delivered_customer_date <= order_estimated_delivery_date) * 100.0 / COUNT(*), 2) AS pct_on_or_before_estimate
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
