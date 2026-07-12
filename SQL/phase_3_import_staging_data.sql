-- E-Commerce Sales Analytics Dashboard
-- Phase 3: Import raw CSV files into staging tables
--
-- Run after SQL/01_database_schema.sql.
--
-- MySQL client example:
-- mysql --local-infile=1 -u root -p < SQL/phase_3_import_staging_data.sql
--
-- Server/client note:
-- LOAD DATA LOCAL INFILE requires local_infile to be enabled for the MySQL client
-- and server. If needed, run this once in MySQL with sufficient privileges:
-- SET GLOBAL local_infile = 1;

USE ecommerce_sales;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE stg_customers;
TRUNCATE TABLE stg_orders;
TRUNCATE TABLE stg_order_items;
TRUNCATE TABLE stg_order_payments;
TRUNCATE TABLE stg_order_reviews;
TRUNCATE TABLE stg_products;
TRUNCATE TABLE stg_sellers;
TRUNCATE TABLE stg_geolocation;
TRUNCATE TABLE stg_product_category_translation;

SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/olist_customers_dataset.csv'
INTO TABLE stg_customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/olist_orders_dataset.csv'
INTO TABLE stg_orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/olist_order_items_dataset.csv'
INTO TABLE stg_order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/olist_order_payments_dataset.csv'
INTO TABLE stg_order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, payment_sequential, payment_type, payment_installments, payment_value);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/olist_order_reviews_dataset.csv'
INTO TABLE stg_order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/olist_products_dataset.csv'
INTO TABLE stg_products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/olist_sellers_dataset.csv'
INTO TABLE stg_sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(seller_id, seller_zip_code_prefix, seller_city, seller_state);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/olist_geolocation_dataset.csv'
INTO TABLE stg_geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Desktop/Projects/E-Commerce Sales Analytics Dashboard/Data/Raw/product_category_name_translation.csv'
INTO TABLE stg_product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_category_name, product_category_name_english);
