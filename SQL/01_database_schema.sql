-- E-Commerce Sales Analytics Dashboard
-- Phase 2: MySQL database schema
--
-- Design notes:
-- 1. Raw CSV files should be loaded into staging tables first.
-- 2. Clean analytical tables enforce primary keys, foreign keys, and basic constraints.
-- 3. order_reviews uses a surrogate key because raw review_id is not unique.
-- 4. geolocation is modeled as both raw staging data and an aggregated zip-prefix table.

CREATE DATABASE IF NOT EXISTS ecommerce_sales
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ecommerce_sales;

-- -----------------------------------------------------
-- Staging tables
-- -----------------------------------------------------
-- These tables mirror the CSV files closely and keep columns nullable
-- so raw import problems can be inspected before cleaning.

CREATE TABLE IF NOT EXISTS stg_customers (
    customer_id VARCHAR(32),
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS stg_orders (
    order_id VARCHAR(32),
    customer_id VARCHAR(32),
    order_status VARCHAR(20),
    order_purchase_timestamp VARCHAR(30),
    order_approved_at VARCHAR(30),
    order_delivered_carrier_date VARCHAR(30),
    order_delivered_customer_date VARCHAR(30),
    order_estimated_delivery_date VARCHAR(30)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS stg_order_items (
    order_id VARCHAR(32),
    order_item_id VARCHAR(10),
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date VARCHAR(30),
    price VARCHAR(20),
    freight_value VARCHAR(20)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS stg_order_payments (
    order_id VARCHAR(32),
    payment_sequential VARCHAR(10),
    payment_type VARCHAR(30),
    payment_installments VARCHAR(10),
    payment_value VARCHAR(20)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS stg_order_reviews (
    review_id VARCHAR(32),
    order_id VARCHAR(32),
    review_score VARCHAR(10),
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date VARCHAR(30),
    review_answer_timestamp VARCHAR(30)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS stg_products (
    product_id VARCHAR(32),
    product_category_name VARCHAR(100),
    product_name_lenght VARCHAR(10),
    product_description_lenght VARCHAR(10),
    product_photos_qty VARCHAR(10),
    product_weight_g VARCHAR(10),
    product_length_cm VARCHAR(10),
    product_height_cm VARCHAR(10),
    product_width_cm VARCHAR(10)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS stg_sellers (
    seller_id VARCHAR(32),
    seller_zip_code_prefix VARCHAR(5),
    seller_city VARCHAR(100),
    seller_state VARCHAR(2)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS stg_geolocation (
    geolocation_zip_code_prefix VARCHAR(5),
    geolocation_lat VARCHAR(30),
    geolocation_lng VARCHAR(30),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(2)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS stg_product_category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Clean analytical tables
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS product_category_translation (
    product_category_name VARCHAR(100) NOT NULL,
    product_category_name_english VARCHAR(100) NOT NULL,
    CONSTRAINT pk_product_category_translation
        PRIMARY KEY (product_category_name)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS customers (
    customer_id CHAR(32) NOT NULL,
    customer_unique_id CHAR(32) NOT NULL,
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state CHAR(2),
    CONSTRAINT pk_customers
        PRIMARY KEY (customer_id),
    CONSTRAINT chk_customers_state_length
        CHECK (customer_state IS NULL OR CHAR_LENGTH(customer_state) = 2)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS sellers (
    seller_id CHAR(32) NOT NULL,
    seller_zip_code_prefix VARCHAR(5),
    seller_city VARCHAR(100),
    seller_state CHAR(2),
    CONSTRAINT pk_sellers
        PRIMARY KEY (seller_id),
    CONSTRAINT chk_sellers_state_length
        CHECK (seller_state IS NULL OR CHAR_LENGTH(seller_state) = 2)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS products (
    product_id CHAR(32) NOT NULL,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    CONSTRAINT pk_products
        PRIMARY KEY (product_id),
    CONSTRAINT fk_products_category_translation
        FOREIGN KEY (product_category_name)
        REFERENCES product_category_translation (product_category_name),
    CONSTRAINT chk_products_name_length
        CHECK (product_name_lenght IS NULL OR product_name_lenght >= 0),
    CONSTRAINT chk_products_description_length
        CHECK (product_description_lenght IS NULL OR product_description_lenght >= 0),
    CONSTRAINT chk_products_photos_qty
        CHECK (product_photos_qty IS NULL OR product_photos_qty >= 0),
    CONSTRAINT chk_products_weight
        CHECK (product_weight_g IS NULL OR product_weight_g >= 0),
    CONSTRAINT chk_products_dimensions
        CHECK (
            (product_length_cm IS NULL OR product_length_cm >= 0)
            AND (product_height_cm IS NULL OR product_height_cm >= 0)
            AND (product_width_cm IS NULL OR product_width_cm >= 0)
        )
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS orders (
    order_id CHAR(32) NOT NULL,
    customer_id CHAR(32) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME NOT NULL,
    CONSTRAINT pk_orders
        PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    CONSTRAINT chk_orders_status
        CHECK (
            order_status IN (
                'approved',
                'canceled',
                'created',
                'delivered',
                'invoiced',
                'processing',
                'shipped',
                'unavailable'
            )
        )
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
    order_id CHAR(32) NOT NULL,
    order_item_id INT NOT NULL,
    product_id CHAR(32) NOT NULL,
    seller_id CHAR(32) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_order_items_orders
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT fk_order_items_products
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),
    CONSTRAINT fk_order_items_sellers
        FOREIGN KEY (seller_id)
        REFERENCES sellers (seller_id),
    CONSTRAINT chk_order_items_sequence
        CHECK (order_item_id > 0),
    CONSTRAINT chk_order_items_price
        CHECK (price >= 0),
    CONSTRAINT chk_order_items_freight
        CHECK (freight_value >= 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS order_payments (
    order_id CHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_order_payments
        PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_order_payments_orders
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT chk_order_payments_sequence
        CHECK (payment_sequential > 0),
    CONSTRAINT chk_order_payments_type
        CHECK (
            payment_type IN (
                'boleto',
                'credit_card',
                'debit_card',
                'not_defined',
                'voucher'
            )
        ),
    CONSTRAINT chk_order_payments_installments
        CHECK (payment_installments >= 0),
    CONSTRAINT chk_order_payments_value
        CHECK (payment_value >= 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS order_reviews (
    review_key BIGINT NOT NULL AUTO_INCREMENT,
    review_id CHAR(32) NOT NULL,
    order_id CHAR(32) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME NOT NULL,
    review_answer_timestamp DATETIME,
    CONSTRAINT pk_order_reviews
        PRIMARY KEY (review_key),
    CONSTRAINT fk_order_reviews_orders
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT chk_order_reviews_score
        CHECK (review_score BETWEEN 1 AND 5)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS geolocation_zip_prefixes (
    geolocation_zip_code_prefix VARCHAR(5) NOT NULL,
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2),
    avg_geolocation_lat DECIMAL(10, 8),
    avg_geolocation_lng DECIMAL(11, 8),
    observation_count INT NOT NULL,
    CONSTRAINT pk_geolocation_zip_prefixes
        PRIMARY KEY (geolocation_zip_code_prefix),
    CONSTRAINT chk_geolocation_state_length
        CHECK (geolocation_state IS NULL OR CHAR_LENGTH(geolocation_state) = 2),
    CONSTRAINT chk_geolocation_observation_count
        CHECK (observation_count > 0)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Helpful indexes for joins and analysis
-- -----------------------------------------------------

CREATE INDEX idx_customers_unique_id
    ON customers (customer_unique_id);

CREATE INDEX idx_customers_location
    ON customers (customer_state, customer_city);

CREATE INDEX idx_sellers_location
    ON sellers (seller_state, seller_city);

CREATE INDEX idx_products_category
    ON products (product_category_name);

CREATE INDEX idx_orders_customer
    ON orders (customer_id);

CREATE INDEX idx_orders_status_purchase_date
    ON orders (order_status, order_purchase_timestamp);

CREATE INDEX idx_order_items_product
    ON order_items (product_id);

CREATE INDEX idx_order_items_seller
    ON order_items (seller_id);

CREATE INDEX idx_order_payments_type
    ON order_payments (payment_type);

CREATE INDEX idx_order_reviews_order
    ON order_reviews (order_id);

CREATE INDEX idx_order_reviews_review_id
    ON order_reviews (review_id);

CREATE INDEX idx_order_reviews_score
    ON order_reviews (review_score);
