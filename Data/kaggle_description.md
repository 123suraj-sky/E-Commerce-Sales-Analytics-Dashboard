## `olist_customers_dataset.csv`

### Customers Dataset

This dataset has information about the customer and its location. Use it to identify unique customers in the orders dataset and to find the orders delivery location.

At our system each order is assigned to a unique customer_id. This means that the same customer will get different ids for different orders. The purpose of having a customer_unique_id on the dataset is to allow you to identify customers that made repurchases at the store. Otherwise you would find that each order had a different customer associated with.

Please refer to the data schema:

```mermaid
graph TD
    %% Node Definitions with Cylindrical Shape (Databases)
    payments[(olist_order_payments_dataset)]
    products[(olist_products_dataset)]
    reviews[(olist_order_reviews_dataset)]
    orders[(olist_orders_dataset)]
    items[(olist_order_items_dataset)]
    sellers[(olist_sellers_dataset)]
    customer[(olist_order_customer_dataset)]
    geolocation[(olist_geolocation_dataset)]

    %% Connections & Relationships
    orders <-->|order_id| payments
    orders <-->|order_id| reviews
    orders <-->|order_id| items
    
    items <-->|product_id| products
    items <-->|seller_id| sellers

    orders <-->|customer_id| customer

    sellers <-->|zip_code_prefix| geolocation
    customer <-->|zip_code_prefix| geolocation

    %% Theme Customization (Matching Image Colors)
    style payments fill:#7a8a99,stroke:#fff,stroke-width:2px,color:#333
    style products fill:#ffc107,stroke:#fff,stroke-width:2px,color:#333
    style reviews fill:#ba2bd3,stroke:#fff,stroke-width:2px,color:#fff
    style orders fill:#db3a50,stroke:#fff,stroke-width:2px,color:#fff
    style items fill:#f28e2b,stroke:#fff,stroke-width:2px,color:#fff
    style sellers fill:#00a88f,stroke:#fff,stroke-width:2px,color:#fff
    style customer fill:#00a88f,stroke:#fff,stroke-width:2px,color:#fff
    style geolocation fill:#2185d0,stroke:#fff,stroke-width:2px,color:#fff

    %% Global Configuration
    linkStyle default stroke:#7a8a99,stroke-width:2px;
```

> This Schema is same for all the csv files.


---

## `olist_customers_dataset.csv`

### Geolocation Dataset

This dataset has information Brazilian zip codes and its lat/lng coordinates. Use it to plot maps and find distances between sellers and customers.

---

## `olist_order_items_dataset.csv`

### Order Items Dataset

This dataset includes data about the items purchased within each order.

Example:
The order_id = `00143d0f86d6fbd9f9b38ab440ac16f5` has 3 items (same product). Each item has the freight calculated accordingly to its measures and weight. To get the total freight value for each order you just have to sum.

**The total order_item value is**: $21.33 \times 3 = 63.99$

**The total freight value is**: $15.10 \times 3 = 45.30$

**The total order value (product + freight) is**: $45.30 + 63.99 = 109.29$

---

## `olist_order_payments_dataset.csv`

### Payments Dataset

This dataset includes data about the orders payment options.

---

## `olist_order_reviews_dataset.csv`

### Order Reviews Dataset

This dataset includes data about the reviews made by the customers.

After a customer purchases the product from Olist Store a seller gets notified to fulfill that order. Once the customer receives the product, or the estimated delivery date is due, the customer gets a satisfaction survey by email where he can give a note for the purchase experience and write down some comments.

---

## `olist_orders_dataset.csv`

### Order Dataset

This is the core dataset. From each order you might find all other information.

---

## `olist_products_dataset.csv`

### Products Dataset

This dataset includes data about the products sold by Olist.

---

## `olist_sellers_dataset.csv`

### Sellers Dataset

This dataset includes data about the sellers that fulfilled orders made at Olist. Use it to find the seller location and to identify which seller fulfilled each product.

---

## `product_category_name_translation.csv`

### Category Name Translation

Translates the product_category_name to english.
