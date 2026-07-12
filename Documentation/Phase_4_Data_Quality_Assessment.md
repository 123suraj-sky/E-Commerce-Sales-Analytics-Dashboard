# Phase 4 Data Quality Assessment

Phase 4 profiles the staged MySQL data after the Phase 3 CSV import.

Assessment script:
`SQL/phase_4_data_quality_assessment.sql`

Assessment run date:
July 12, 2026

## Scope

The assessment checks:

- Row count consistency after import.
- Blank and missing values.
- Full-row duplicates.
- Duplicate primary key candidates.
- Foreign key and relationship coverage.
- Type conversion readiness.
- Domain and range validity.
- Date format validity.
- Basic date chronology issues.

## Summary

The staging import is structurally usable for the next phase, but cleaning rules are needed before loading the final analytical tables.

Key issues to handle in Phase 5:

- Duplicate `review_id` values in order reviews.
- Blank optional order lifecycle dates.
- Blank review comments and titles.
- Missing product category and product attribute fields.
- Missing product category translations for two categories.
- Customer and seller zip prefixes missing from geolocation.
- Repeated geolocation rows.
- A small number of order delivery chronology anomalies.

## Passed Checks

### Row Counts

All staging table row counts match Phase 1 and Phase 3 expected counts.

| Staging table | Expected rows | Actual rows | Status |
|---|---:|---:|---|
| `stg_customers` | 99,441 | 99,441 | PASS |
| `stg_orders` | 99,441 | 99,441 | PASS |
| `stg_order_items` | 112,650 | 112,650 | PASS |
| `stg_order_payments` | 103,886 | 103,886 | PASS |
| `stg_order_reviews` | 99,224 | 99,224 | PASS |
| `stg_products` | 32,951 | 32,951 | PASS |
| `stg_sellers` | 3,095 | 3,095 | PASS |
| `stg_geolocation` | 1,000,163 | 1,000,163 | PASS |
| `stg_product_category_translation` | 71 | 71 | PASS |

### Type, Domain, and Date Format Checks

- Numeric fields are convertible to expected numeric types.
- Geolocation latitude and longitude values are within valid coordinate ranges.
- Order statuses contain only expected values.
- Review scores are within the 1 to 5 range.
- Price, freight, and payment values are not negative.
- All populated date/time fields match the expected datetime format.

### Core Relationship Checks

No orphan records were found for the core transactional relationships:

- Orders to customers.
- Order items to orders.
- Order items to products.
- Order items to sellers.
- Order payments to orders.
- Order reviews to orders.

## Findings Requiring Cleaning Decisions

### Blank Values

| Field | Blank rows | Notes |
|---|---:|---|
| `stg_orders.order_approved_at` | 160 | Expected for some non-approved or problematic orders. |
| `stg_orders.order_delivered_carrier_date` | 1,783 | Expected for orders not shipped to carrier. |
| `stg_orders.order_delivered_customer_date` | 2,965 | Expected for canceled, unavailable, or not-yet-delivered orders. |
| `stg_order_reviews.review_comment_title` | 87,658 | Optional review text field. |
| `stg_order_reviews.review_comment_message` | 58,256 | Optional review text field. |
| `stg_products.product_category_name` | 610 | Needs category handling rule. |
| `stg_products.product_name_lenght` | 610 | Same product rows as missing category metadata. |
| `stg_products.product_description_lenght` | 610 | Same product rows as missing category metadata. |
| `stg_products.product_photos_qty` | 610 | Same product rows as missing category metadata. |
| `stg_products.product_weight_g` | 2 | Needs cleaning decision before product dimension load. |
| `stg_products.product_length_cm` | 2 | Needs cleaning decision before product dimension load. |
| `stg_products.product_height_cm` | 2 | Needs cleaning decision before product dimension load. |
| `stg_products.product_width_cm` | 2 | Needs cleaning decision before product dimension load. |

### Duplicate Keys

`stg_order_reviews.review_id` is not unique:

| Key candidate | Duplicate keys | Extra duplicate rows |
|---|---:|---:|
| `stg_order_reviews.review_id` | 789 | 814 |

Cleaning should not use `review_id` alone as the final primary key. The schema already uses a surrogate `review_key` for the analytical review table.

### Full-Row Duplicates

No full-row duplicates were found in the main transactional staging tables.

`stg_geolocation` has repeated raw observations:

| Table | Duplicate full-row groups | Extra duplicate rows |
|---|---:|---:|
| `stg_geolocation` | 131,544 | 279,667 |

This supports aggregating geolocation to one row per zip-code prefix before joining to customers or sellers.

### Missing Relationship Coverage

| Relationship check | Missing rows |
|---|---:|
| `products.product_category_name` missing in translation | 13 |
| `customers.customer_zip_code_prefix` missing in geolocation | 278 |
| `sellers.seller_zip_code_prefix` missing in geolocation | 7 |

Missing product category translation values:

| Product category | Product rows |
|---|---:|
| `pc_gamer` | 3 |
| `portateis_cozinha_e_preparadores_de_alimentos` | 10 |

Missing geolocation unique prefixes:

| Field | Missing unique prefixes |
|---|---:|
| `customers.customer_zip_code_prefix` | 157 |
| `sellers.seller_zip_code_prefix` | 7 |

### Date Chronology Issues

| Issue | Rows |
|---|---:|
| Carrier delivery date before purchase timestamp | 166 |
| Customer delivery date before carrier delivery date | 23 |

No issues were found for:

- Approval before purchase.
- Customer delivery before purchase.
- Estimated delivery before purchase.
- Review answer before review creation.

## Phase 5 Cleaning Recommendations

- Convert blank strings to `NULL` for optional dates, review comments, and nullable product attributes.
- Keep `review_id` as a source identifier, but use `review_key` or a deduplication rule for the final review table.
- Add translations for `pc_gamer` and `portateis_cozinha_e_preparadores_de_alimentos`, or map them to an `unknown`/`untranslated` category bucket.
- Build `geolocation_zip_prefixes` by aggregating `stg_geolocation` to one row per zip prefix.
- Do not enforce customer/seller geolocation foreign keys unless missing zip prefixes are handled.
- Investigate or flag delivery chronology anomalies instead of silently correcting them.
