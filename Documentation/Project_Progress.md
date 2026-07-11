# Project Progress

This file tracks what has been completed so far in the E-Commerce Sales Analytics Dashboard project.

## Current Status

Current phase: Phase 2 - Database Design

Last completed phase: Phase 1 - Understand the Dataset

## Phase Progress

| Phase | Status | Notes |
|---|---|---|
| Phase 1 - Understand the Dataset | Complete | Dataset description, data dictionary, keys, relationships, and validation checks are complete. |
| Phase 2 - Database Design | Not started | SQL schema files exist, but the database schema has not been written yet. |
| Phase 3 - Create/Import Data | Not started | No import scripts or loaded database evidence yet. |
| Phase 4 - Data Quality Assessment | Not started | Phase 1 validation exists, but database-level quality checks are not started. |
| Phase 5 - Data Cleaning | Not started | Cleaning SQL file exists but is empty. |
| Phase 6 - Exploratory Data Analysis | Not started | No EDA queries or outputs yet. |
| Phase 7 - Business Analysis | Not started | Business queries file exists but is empty. |
| Phase 8 - Power BI Dashboard | Not started | Power BI folder exists, but dashboard work is not documented yet. |
| Phase 9 - Business Insights | Not started | Business insights document exists but is empty. |
| Phase 10 - Documentation | Not started | Final documentation is not complete yet. |
| Phase 11 - GitHub Polishing | Not started | Repository polish/readiness work is pending. |

## Completed Work

### Phase 1 - Understand the Dataset

- Reviewed the Olist Brazilian E-Commerce Public Dataset description.
- Created dataset notes in `Data/kaggle_description.md`.
- Created the data dictionary in `Documentation/Data_Dictionary.md`.
- Documented all raw CSV tables, row counts, table grain, and column meanings.
- Identified primary key candidates for the main tables.
- Identified foreign key relationships between customers, orders, order items, payments, reviews, products, sellers, and category translations.
- Documented relationship notes for geolocation, including why it should not be treated as a strict dimension table at raw grain.
- Added Phase 1 validation script in `Validation/phase_1_data_validation.py`.
- Added Phase 1 validation summary in `Validation/phase_1_validation_summary.md`.
- Verified row counts, duplicate key checks, foreign key coverage, and product category translation gaps.

## Known Findings From Phase 1

- `order_reviews.review_id` is not unique in the raw data.
- There are 789 duplicated review ids and 814 extra duplicate review rows.
- Main foreign key coverage is clean for the core relationships.
- Two product categories are missing from the translation table:
  - `pc_gamer`
  - `portateis_cozinha_e_preparadores_de_alimentos`
- Geolocation has repeated zip-code prefix observations and should be cleaned or aggregated before direct joins.

## Evidence Files

| Evidence | File |
|---|---|
| Dataset description notes | `Data/kaggle_description.md` |
| Data dictionary and relationships | `Documentation/Data_Dictionary.md` |
| Reproducible validation script | `Validation/phase_1_data_validation.py` |
| Validation result summary | `Validation/phase_1_validation_summary.md` |

## Next Task

Start Phase 2 by designing the MySQL schema in `SQL/01_database_schema.sql`.
