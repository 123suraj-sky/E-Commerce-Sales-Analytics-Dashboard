# Phase 5 Data Cleaning

Phase 5 converts staging tables into clean analytical tables.

Cleaning script:
`SQL/03_data_cleaning.sql`

Verification script:
`SQL/phase_5_verify_cleaning.sql`

Cleaning run date:
July 12, 2026

## Cleaning Rules Applied

### General

- Reloaded all clean analytical tables from staging tables.
- Kept staging tables unchanged as the raw import layer.
- Converted blank strings to `NULL` where the clean schema allows missing values.
- Converted text-based staging fields into typed analytical columns.
- Preserved known chronology anomalies instead of silently editing source dates.

### Product Categories

- Loaded the original product category translation table.
- Added the two missing category translations found in Phase 4:

| Source category | Clean English category |
|---|---|
| `pc_gamer` | `pc_gamer` |
| `portateis_cozinha_e_preparadores_de_alimentos` | `portable_kitchen_food_preparers` |

Result:
Products with non-null categories now have valid translation table coverage.

### Products

- Converted blank product category and product metadata fields to `NULL`.
- Converted product length, description length, photo quantity, weight, and dimensions to integer fields.
- Kept original misspelled source column names such as `product_name_lenght` for traceability.

### Orders

- Converted date/time strings to `DATETIME`.
- Converted blank optional lifecycle dates to `NULL`:
  - `order_approved_at`
  - `order_delivered_carrier_date`
  - `order_delivered_customer_date`
- Preserved the Phase 4 delivery chronology anomalies for later analysis.

### Order Reviews

- Converted review score to integer.
- Converted blank review titles and messages to `NULL`.
- Preserved duplicate `review_id` values as source identifiers.
- Used the analytical table's surrogate `review_key` as the primary key.

### Geolocation

- Aggregated raw geolocation observations to one row per zip-code prefix.
- Calculated average latitude and longitude for each zip prefix.
- Selected the most frequent city/state label per zip prefix.
- Removed duplicate geolocation observations through aggregation.

## Verification Results

### Clean Row Counts

| Clean table | Expected rows | Actual rows | Status |
|---|---:|---:|---|
| `customers` | 99,441 | 99,441 | PASS |
| `sellers` | 3,095 | 3,095 | PASS |
| `product_category_translation` | 73 | 73 | PASS |
| `products` | 32,951 | 32,951 | PASS |
| `orders` | 99,441 | 99,441 | PASS |
| `order_items` | 112,650 | 112,650 | PASS |
| `order_payments` | 103,886 | 103,886 | PASS |
| `order_reviews` | 99,224 | 99,224 | PASS |
| `geolocation_zip_prefixes` | 19,015 | 19,015 | PASS |

### Relationship Checks

All core analytical relationships passed:

- Orders to customers: 0 missing rows.
- Order items to orders: 0 missing rows.
- Order items to products: 0 missing rows.
- Order items to sellers: 0 missing rows.
- Order payments to orders: 0 missing rows.
- Order reviews to orders: 0 missing rows.
- Products to category translations: 0 missing rows.

### Cleaning Outcomes

| Check | Rows |
|---|---:|
| Missing category translations after cleaning | 0 |
| Products with `NULL` category | 610 |
| Products with `NULL` weight or dimensions | 2 |
| Extra duplicate review rows retained under duplicate `review_id` values | 814 |
| Orders with `NULL` approved date | 160 |
| Orders with `NULL` carrier date | 1,783 |
| Orders with `NULL` customer delivery date | 2,965 |
| Reviews with `NULL` comment title | 87,658 |
| Reviews with `NULL` comment message | 58,256 |
| Duplicate geolocation zip prefixes after aggregation | 0 |

### Preserved Anomalies

These records are preserved for analysis and should not be treated as accidental cleaning failures:

| Anomaly | Rows |
|---|---:|
| Carrier delivery date before purchase timestamp | 166 |
| Customer delivery date before carrier delivery date | 23 |

## Next Step

Start Phase 6 by running exploratory data analysis on the clean analytical tables.
