-- E-Commerce Sales Analytics Dashboard
-- Phase 5: Data cleaning and loading analytical tables
--
-- Run after:
-- 1. SQL/01_database_schema.sql
-- 2. SQL/phase_3_import_staging_data.sql
-- 3. SQL/phase_4_data_quality_assessment.sql

USE ecommerce_sales;

-- -----------------------------------------------------
-- Reset clean analytical tables
-- -----------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE order_reviews;
TRUNCATE TABLE order_payments;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE products;
TRUNCATE TABLE customers;
TRUNCATE TABLE sellers;
TRUNCATE TABLE geolocation_zip_prefixes;
TRUNCATE TABLE product_category_translation;

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------
-- Product category translation
-- -----------------------------------------------------
-- Two categories appear in products but not in the original translation file.
-- They are added here so products can keep a foreign key to the translation table.

INSERT INTO product_category_translation (
    product_category_name,
    product_category_name_english
)
SELECT
    TRIM(product_category_name),
    TRIM(REPLACE(product_category_name_english, CHAR(13), ''))
FROM stg_product_category_translation
WHERE product_category_name <> ''
UNION ALL
SELECT 'pc_gamer', 'pc_gamer'
UNION ALL
SELECT
    'portateis_cozinha_e_preparadores_de_alimentos',
    'portable_kitchen_food_preparers';

-- -----------------------------------------------------
-- Geolocation
-- -----------------------------------------------------
-- Raw geolocation repeats zip prefixes and contains duplicate observations.
-- Aggregate coordinates to one row per zip prefix and keep the most frequent
-- city/state label for that prefix.

INSERT INTO geolocation_zip_prefixes (
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state,
    avg_geolocation_lat,
    avg_geolocation_lng,
    observation_count
)
WITH geo_averages AS (
    SELECT
        geolocation_zip_code_prefix,
        ROUND(AVG(CAST(geolocation_lat AS DECIMAL(12, 8))), 8) AS avg_geolocation_lat,
        ROUND(AVG(CAST(geolocation_lng AS DECIMAL(13, 8))), 8) AS avg_geolocation_lng,
        COUNT(*) AS observation_count
    FROM stg_geolocation
    WHERE geolocation_zip_code_prefix <> ''
    GROUP BY geolocation_zip_code_prefix
),
geo_city_state_counts AS (
    SELECT
        geolocation_zip_code_prefix,
        NULLIF(TRIM(geolocation_city), '') AS geolocation_city,
        NULLIF(TRIM(geolocation_state), '') AS geolocation_state,
        COUNT(*) AS city_state_count
    FROM stg_geolocation
    WHERE geolocation_zip_code_prefix <> ''
    GROUP BY
        geolocation_zip_code_prefix,
        NULLIF(TRIM(geolocation_city), ''),
        NULLIF(TRIM(geolocation_state), '')
),
geo_city_state_ranked AS (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
        ROW_NUMBER() OVER (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY city_state_count DESC, geolocation_state, geolocation_city
        ) AS city_state_rank
    FROM geo_city_state_counts
)
SELECT
    a.geolocation_zip_code_prefix,
    r.geolocation_city,
    r.geolocation_state,
    a.avg_geolocation_lat,
    a.avg_geolocation_lng,
    a.observation_count
FROM geo_averages a
INNER JOIN geo_city_state_ranked r
    ON a.geolocation_zip_code_prefix = r.geolocation_zip_code_prefix
WHERE r.city_state_rank = 1;

-- -----------------------------------------------------
-- Customers and sellers
-- -----------------------------------------------------

INSERT INTO customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    NULLIF(customer_zip_code_prefix, ''),
    NULLIF(TRIM(customer_city), ''),
    NULLIF(TRIM(customer_state), '')
FROM stg_customers;

INSERT INTO sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    NULLIF(seller_zip_code_prefix, ''),
    NULLIF(TRIM(seller_city), ''),
    NULLIF(TRIM(seller_state), '')
FROM stg_sellers;

-- -----------------------------------------------------
-- Products
-- -----------------------------------------------------
-- Blank product metadata is converted to NULL. The original misspelled column
-- names are retained for traceability with the source CSV.

INSERT INTO products (
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    product_id,
    NULLIF(product_category_name, ''),
    CAST(NULLIF(product_name_lenght, '') AS UNSIGNED),
    CAST(NULLIF(product_description_lenght, '') AS UNSIGNED),
    CAST(NULLIF(product_photos_qty, '') AS UNSIGNED),
    CAST(NULLIF(product_weight_g, '') AS UNSIGNED),
    CAST(NULLIF(product_length_cm, '') AS UNSIGNED),
    CAST(NULLIF(product_height_cm, '') AS UNSIGNED),
    CAST(NULLIF(product_width_cm, '') AS UNSIGNED)
FROM stg_products;

-- -----------------------------------------------------
-- Orders
-- -----------------------------------------------------
-- Blank optional lifecycle dates are converted to NULL. Chronology anomalies
-- found in Phase 4 are preserved for later investigation, not rewritten.

INSERT INTO orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
SELECT
    order_id,
    customer_id,
    order_status,
    STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(order_approved_at, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(order_delivered_carrier_date, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(order_delivered_customer_date, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')
FROM stg_orders;

-- -----------------------------------------------------
-- Order items and payments
-- -----------------------------------------------------

INSERT INTO order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT
    order_id,
    CAST(order_item_id AS UNSIGNED),
    product_id,
    seller_id,
    STR_TO_DATE(shipping_limit_date, '%Y-%m-%d %H:%i:%s'),
    CAST(price AS DECIMAL(10, 2)),
    CAST(freight_value AS DECIMAL(10, 2))
FROM stg_order_items;

INSERT INTO order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    order_id,
    CAST(payment_sequential AS UNSIGNED),
    payment_type,
    CAST(payment_installments AS UNSIGNED),
    CAST(payment_value AS DECIMAL(10, 2))
FROM stg_order_payments;

-- -----------------------------------------------------
-- Order reviews
-- -----------------------------------------------------
-- review_id is preserved as a source identifier, but the analytical table uses
-- review_key as its primary key because review_id is duplicated in raw data.

INSERT INTO order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    review_id,
    order_id,
    CAST(review_score AS UNSIGNED),
    NULLIF(TRIM(review_comment_title), ''),
    NULLIF(TRIM(review_comment_message), ''),
    STR_TO_DATE(review_creation_date, '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(review_answer_timestamp, ''), '%Y-%m-%d %H:%i:%s')
FROM stg_order_reviews;
