# ER Diagram

This document describes the main analytical-table relationships used in the E-Commerce Sales Analytics Dashboard project.

```mermaid
erDiagram
    CUSTOMERS ||--|| ORDERS : places
    ORDERS ||--o{ ORDER_ITEMS : contains
    ORDERS ||--o{ ORDER_PAYMENTS : paid_by
    ORDERS ||--o{ ORDER_REVIEWS : reviewed_by
    PRODUCTS ||--o{ ORDER_ITEMS : sold_as
    SELLERS ||--o{ ORDER_ITEMS : fulfills
    PRODUCT_CATEGORY_TRANSLATION ||--o{ PRODUCTS : translates
    GEOLOCATION_ZIP_PREFIXES ||--o{ CUSTOMERS : approximates_customer_zip
    GEOLOCATION_ZIP_PREFIXES ||--o{ SELLERS : approximates_seller_zip

    CUSTOMERS {
        char customer_id PK
        char customer_unique_id
        varchar customer_zip_code_prefix
        varchar customer_city
        char customer_state
    }

    ORDERS {
        char order_id PK
        char customer_id FK
        varchar order_status
        datetime order_purchase_timestamp
        datetime order_approved_at
        datetime order_delivered_carrier_date
        datetime order_delivered_customer_date
        datetime order_estimated_delivery_date
    }

    ORDER_ITEMS {
        char order_id PK, FK
        int order_item_id PK
        char product_id FK
        char seller_id FK
        datetime shipping_limit_date
        decimal price
        decimal freight_value
    }

    ORDER_PAYMENTS {
        char order_id PK, FK
        int payment_sequential PK
        varchar payment_type
        int payment_installments
        decimal payment_value
    }

    ORDER_REVIEWS {
        bigint review_key PK
        char review_id
        char order_id FK
        int review_score
        text review_comment_title
        text review_comment_message
        datetime review_creation_date
        datetime review_answer_timestamp
    }

    PRODUCTS {
        char product_id PK
        varchar product_category_name FK
        int product_name_lenght
        int product_description_lenght
        int product_photos_qty
        int product_weight_g
        int product_length_cm
        int product_height_cm
        int product_width_cm
    }

    SELLERS {
        char seller_id PK
        varchar seller_zip_code_prefix
        varchar seller_city
        char seller_state
    }

    PRODUCT_CATEGORY_TRANSLATION {
        varchar product_category_name PK
        varchar product_category_name_english
    }

    GEOLOCATION_ZIP_PREFIXES {
        varchar geolocation_zip_code_prefix PK
        varchar geolocation_city
        char geolocation_state
        decimal avg_geolocation_lat
        decimal avg_geolocation_lng
        int observation_count
    }
```

## Notes

- `order_reviews.review_id` is preserved as a source identifier, but `review_key` is the analytical primary key because raw review IDs are duplicated.
- `geolocation_zip_prefixes` is an aggregated lookup table, not a strict raw-grain dimension.
- Zip code prefix relationships are analytical lookup relationships and are not enforced as foreign keys in the schema.
