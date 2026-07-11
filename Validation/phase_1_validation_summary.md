# Phase 1 Data Validation Summary

This file records how the Phase 1 validation findings were produced. The checks are implemented in `Validation/phase_1_data_validation.py` so the results can be reproduced from the raw CSV files.

## How To Run

From the project root:

```bash
python Validation/phase_1_data_validation.py
```

If the system `python` command is unavailable, run the script with any Python 3 interpreter.

## Checks Included

- Row counts for every raw CSV file.
- Duplicate checks for primary key candidates.
- Foreign key coverage checks between related tables.
- Product category translation coverage.

## Expected Findings From Current Raw Files

- Primary key candidates with no duplicates:
  - `customers.customer_id`
  - `orders.order_id`
  - `order_items.(order_id, order_item_id)`
  - `order_payments.(order_id, payment_sequential)`
  - `products.product_id`
  - `sellers.seller_id`
  - `category_translation.product_category_name`

- `order_reviews.review_id` is not unique in the raw CSV:
  - Duplicate review ids: 789
  - Extra duplicate rows: 814

- Main relationship coverage is clean:
  - Orders match customers.
  - Order items match orders, products, and sellers.
  - Payments match orders.
  - Reviews match orders.

- Two product categories are missing from the translation table:
  - `pc_gamer`
  - `portateis_cozinha_e_preparadores_de_alimentos`

## Why This Exists

These checks make the data dictionary and schema decisions defensible. Instead of only saying that a key or relationship works, the project includes code that proves it against the raw data.
