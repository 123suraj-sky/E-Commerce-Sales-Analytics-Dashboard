# Phase 3 Import Notes

Phase 3 imports the raw CSV files into staging tables and verifies row counts.

## Scripts

| Step | Script |
|---|---|
| Create database and tables | `SQL/01_database_schema.sql` |
| Import raw CSV files into staging tables | `SQL/phase_3_import_staging_data.sql` |
| Verify staging row counts | `SQL/phase_3_verify_staging_import.sql` |

## Recommended Run Order

From the project root:

```bash
mysql --local-infile=1 -u root -p < SQL/01_database_schema.sql
mysql --local-infile=1 -u root -p < SQL/phase_3_import_staging_data.sql
mysql --local-infile=1 -u root -p < SQL/phase_3_verify_staging_import.sql
```

Use your own MySQL username if it is not `root`.

## Expected Row Counts

| Staging table | Expected rows |
|---|---:|
| `stg_customers` | 99,441 |
| `stg_orders` | 99,441 |
| `stg_order_items` | 112,650 |
| `stg_order_payments` | 103,886 |
| `stg_order_reviews` | 99,224 |
| `stg_products` | 32,951 |
| `stg_sellers` | 3,095 |
| `stg_geolocation` | 1,000,163 |
| `stg_product_category_translation` | 71 |

## Import Notes

- The Phase 3 import loads only staging tables.
- Clean analytical tables are intentionally left empty until data cleaning rules are defined.
- `LOAD DATA LOCAL INFILE` may require MySQL server/client setting `local_infile` to be enabled.
- The import script truncates staging tables first so it can be rerun safely for a fresh staging load.
- The import script uses `ESCAPED BY ''` so literal backslashes inside review comments are not treated as escape characters.
- Row-count verification should match the Phase 1 validation output before moving to data quality assessment.

## Verification Result

Phase 3 verification passed after import.

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

Required-value checks returned zero blank required values for all staging tables.
