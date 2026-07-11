# Data Dictionary

Dataset: Olist Brazilian E-Commerce Public Dataset

This document describes the raw CSV tables used in the E-Commerce Sales Analytics Dashboard project. Row counts are based on the files currently stored in `Data/Raw`.

## Table Inventory

| Source file | Business table | Rows | Grain |
|---|---:|---:|---|
| `olist_customers_dataset.csv` | Customers | 99,441 | One row per order-specific customer id |
| `olist_orders_dataset.csv` | Orders | 99,441 | One row per order |
| `olist_order_items_dataset.csv` | Order Items | 112,650 | One row per item within an order |
| `olist_order_payments_dataset.csv` | Order Payments | 103,886 | One row per payment attempt/sequence for an order |
| `olist_order_reviews_dataset.csv` | Order Reviews | 99,224 | One row per review record |
| `olist_products_dataset.csv` | Products | 32,951 | One row per product |
| `olist_sellers_dataset.csv` | Sellers | 3,095 | One row per seller |
| `olist_geolocation_dataset.csv` | Geolocation | 1,000,163 | One row per zip-code geolocation observation |
| `product_category_name_translation.csv` | Product Category Translation | 71 | One row per product category translation |

## Customers

Source file: `Data/Raw/olist_customers_dataset.csv`

Description:
Contains customer identifiers and customer location details. In this dataset, `customer_id` is order-specific, while `customer_unique_id` identifies the same real customer across multiple orders.

Primary key:
`customer_id`

Foreign keys:
None in the raw table. `customer_zip_code_prefix` can be used to match geolocation records, but the geolocation table has multiple rows per zip prefix, so this should not be enforced as a strict foreign key without preprocessing.

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `customer_id` | `CHAR(32)` | Unique order-level customer identifier. Used by `orders.customer_id`. |
| `customer_unique_id` | `CHAR(32)` | Stable customer identifier used to detect repeat customers. |
| `customer_zip_code_prefix` | `VARCHAR(5)` | Customer zip code prefix. Keep as text to preserve leading zeroes. |
| `customer_city` | `VARCHAR(100)` | Customer city. |
| `customer_state` | `CHAR(2)` | Brazilian state abbreviation. |

## Orders

Source file: `Data/Raw/olist_orders_dataset.csv`

Description:
Core order table. Contains order status and key order lifecycle timestamps.

Primary key:
`order_id`

Foreign keys:
`customer_id` references `customers.customer_id`

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `order_id` | `CHAR(32)` | Unique order identifier. |
| `customer_id` | `CHAR(32)` | Order-specific customer identifier. |
| `order_status` | `VARCHAR(20)` | Current/final order status, such as delivered, shipped, canceled, unavailable, invoiced, processing, created, or approved. |
| `order_purchase_timestamp` | `DATETIME` | Timestamp when the customer placed the order. |
| `order_approved_at` | `DATETIME` | Timestamp when payment/order approval occurred. May be blank for some orders. |
| `order_delivered_carrier_date` | `DATETIME` | Timestamp when the order was handed to the carrier. May be blank. |
| `order_delivered_customer_date` | `DATETIME` | Timestamp when the order was delivered to the customer. May be blank for undelivered/canceled orders. |
| `order_estimated_delivery_date` | `DATETIME` | Estimated delivery date promised to the customer. |

## Order Items

Source file: `Data/Raw/olist_order_items_dataset.csv`

Description:
Contains item-level details for products purchased within each order. An order can contain multiple items, and `order_item_id` identifies the item sequence within an order.

Primary key:
Composite key: (`order_id`, `order_item_id`)

Foreign keys:
`order_id` references `orders.order_id`
`product_id` references `products.product_id`
`seller_id` references `sellers.seller_id`

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `order_id` | `CHAR(32)` | Order identifier. |
| `order_item_id` | `INT` | Item sequence number inside the order. |
| `product_id` | `CHAR(32)` | Product purchased. |
| `seller_id` | `CHAR(32)` | Seller that fulfilled the item. |
| `shipping_limit_date` | `DATETIME` | Seller shipping deadline for the item. |
| `price` | `DECIMAL(10,2)` | Item product price, excluding freight. |
| `freight_value` | `DECIMAL(10,2)` | Freight/shipping value charged for the item. |

## Order Payments

Source file: `Data/Raw/olist_order_payments_dataset.csv`

Description:
Contains payment information for orders. An order can have multiple payment rows if payment was split or retried.

Primary key:
Composite key: (`order_id`, `payment_sequential`)

Foreign keys:
`order_id` references `orders.order_id`

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `order_id` | `CHAR(32)` | Order identifier. |
| `payment_sequential` | `INT` | Payment sequence number within the order. |
| `payment_type` | `VARCHAR(30)` | Payment method, such as credit_card, boleto, voucher, debit_card, or not_defined. |
| `payment_installments` | `INT` | Number of installments selected for the payment. |
| `payment_value` | `DECIMAL(10,2)` | Payment amount. |

## Order Reviews

Source file: `Data/Raw/olist_order_reviews_dataset.csv`

Description:
Contains customer review scores and optional written feedback after purchase.

Primary key:
The raw `review_id` is the review identifier, but it is not unique in the current CSV. Use a staging table first and decide whether the cleaned table should use a surrogate key, a composite key, or deduplicated review records.

Foreign keys:
`order_id` references `orders.order_id`

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `review_id` | `CHAR(32)` | Review identifier. |
| `order_id` | `CHAR(32)` | Reviewed order identifier. |
| `review_score` | `INT` | Customer rating from 1 to 5. |
| `review_comment_title` | `TEXT` | Optional review title. Often blank. |
| `review_comment_message` | `TEXT` | Optional review text. Often blank. |
| `review_creation_date` | `DATETIME` | Date when the review request/review was created. |
| `review_answer_timestamp` | `DATETIME` | Timestamp when the review answer was submitted. |

## Products

Source file: `Data/Raw/olist_products_dataset.csv`

Description:
Contains product category and physical product attributes.

Primary key:
`product_id`

Foreign keys:
`product_category_name` references `product_category_translation.product_category_name` after handling untranslated categories.

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `product_id` | `CHAR(32)` | Unique product identifier. |
| `product_category_name` | `VARCHAR(100)` | Product category name in Portuguese. May be blank for some products. |
| `product_name_lenght` | `INT` | Length of product name. The original column name contains the misspelling `lenght`. |
| `product_description_lenght` | `INT` | Length of product description. The original column name contains the misspelling `lenght`. |
| `product_photos_qty` | `INT` | Number of product photos. |
| `product_weight_g` | `INT` | Product weight in grams. |
| `product_length_cm` | `INT` | Product length in centimeters. |
| `product_height_cm` | `INT` | Product height in centimeters. |
| `product_width_cm` | `INT` | Product width in centimeters. |

## Sellers

Source file: `Data/Raw/olist_sellers_dataset.csv`

Description:
Contains seller identifiers and seller location details.

Primary key:
`seller_id`

Foreign keys:
None in the raw table. `seller_zip_code_prefix` can be used to match geolocation records after geolocation preprocessing.

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `seller_id` | `CHAR(32)` | Unique seller identifier. |
| `seller_zip_code_prefix` | `VARCHAR(5)` | Seller zip code prefix. Keep as text to preserve leading zeroes. |
| `seller_city` | `VARCHAR(100)` | Seller city. |
| `seller_state` | `CHAR(2)` | Brazilian state abbreviation. |

## Geolocation

Source file: `Data/Raw/olist_geolocation_dataset.csv`

Description:
Contains latitude and longitude observations for Brazilian zip code prefixes. This table can contain multiple records for the same zip code prefix, city, and state, so it should usually be cleaned or aggregated before joining to customers or sellers.

Primary key:
No reliable single-column primary key in the raw table. Use a staging table first. A cleaned table can use an aggregate grain such as one row per `geolocation_zip_code_prefix`.

Foreign keys:
None.

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `geolocation_zip_code_prefix` | `VARCHAR(5)` | Zip code prefix. Keep as text to preserve leading zeroes. |
| `geolocation_lat` | `DECIMAL(10,8)` | Latitude coordinate. |
| `geolocation_lng` | `DECIMAL(11,8)` | Longitude coordinate. |
| `geolocation_city` | `VARCHAR(100)` | City associated with the zip code prefix. |
| `geolocation_state` | `CHAR(2)` | Brazilian state abbreviation. |

## Product Category Translation

Source file: `Data/Raw/product_category_name_translation.csv`

Description:
Maps Portuguese product category names to English category names for reporting and dashboard readability.

Primary key:
`product_category_name`

Foreign keys:
None.

Columns:

| Column | Suggested SQL type | Description |
|---|---|---|
| `product_category_name` | `VARCHAR(100)` | Product category name in Portuguese. |
| `product_category_name_english` | `VARCHAR(100)` | Product category name in English. |

## Main Relationships

| Parent table | Child table | Relationship | Join key |
|---|---|---|---|
| Customers | Orders | One customer id to one order in this dataset | `customers.customer_id = orders.customer_id` |
| Orders | Order Items | One order to many order items | `orders.order_id = order_items.order_id` |
| Orders | Order Payments | One order to many payments | `orders.order_id = order_payments.order_id` |
| Orders | Order Reviews | One order to zero or more reviews | `orders.order_id = order_reviews.order_id` |
| Products | Order Items | One product to many order items | `products.product_id = order_items.product_id` |
| Sellers | Order Items | One seller to many order items | `sellers.seller_id = order_items.seller_id` |
| Product Category Translation | Products | One category translation to many products | `product_category_translation.product_category_name = products.product_category_name` |
| Geolocation | Customers | Many raw geolocation rows can match a customer zip prefix | `geolocation.geolocation_zip_code_prefix = customers.customer_zip_code_prefix` |
| Geolocation | Sellers | Many raw geolocation rows can match a seller zip prefix | `geolocation.geolocation_zip_code_prefix = sellers.seller_zip_code_prefix` |

## Notes For Database Design

- Load the CSV files into staging tables first, especially for nullable date fields and the geolocation table.
- Keep zip code prefixes as text, not integers, because some prefixes have leading zeroes.
- Treat `geolocation` carefully: it is not a dimension table at raw grain because zip prefixes repeat.
- Keep the original misspelled product columns during raw import for traceability, then optionally expose cleaned aliases in views.
- Revenue analysis should usually use `order_items.price + order_items.freight_value` for item-level gross order value, while payment analysis should use `order_payments.payment_value`.

## Phase 1 Validation Findings

- Primary keys validated with no duplicates: customers, orders, order items composite key, order payments composite key, products, sellers, and product category translation.
- `olist_order_reviews_dataset.csv` has duplicate `review_id` values: 789 duplicated review ids and 814 extra duplicate rows. Do not enforce `review_id` as a primary key until the cleaning rule is defined.
- Foreign key coverage is complete for orders to customers, order items to orders/products/sellers, payments to orders, and reviews to orders.
- Two product categories are missing from the translation table: `pc_gamer` and `portateis_cozinha_e_preparadores_de_alimentos`.
