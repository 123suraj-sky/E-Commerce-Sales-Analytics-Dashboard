# Project Progress

This file tracks what has been completed so far in the E-Commerce Sales Analytics Dashboard project.

## Current Status

Current phase: Phase 7 - Business Analysis

Last completed phase: Phase 6 - Exploratory Data Analysis

## Phase Progress

| Phase | Status | Notes |
|---|---|---|
| Phase 1 - Understand the Dataset | Complete | Dataset description, data dictionary, keys, relationships, and validation checks are complete. |
| Phase 2 - Database Design | Complete | MySQL database schema has been created in `SQL/01_database_schema.sql`. |
| Phase 3 - Create/Import Data | Complete | Raw CSV files were imported into staging tables and row-count verification passed. |
| Phase 4 - Data Quality Assessment | Complete | Database-level staging quality checks were run and documented. |
| Phase 5 - Data Cleaning | Complete | Staging data was cleaned and loaded into analytical tables. |
| Phase 6 - Exploratory Data Analysis | Complete | Baseline EDA queries were run against the clean analytical tables and documented. |
| Phase 7 - Business Analysis | Not started | Business queries file exists but is empty. |
| Phase 8 - Power BI Dashboard | Not started | Power BI folder exists, but dashboard work is not documented yet. |
| Phase 9 - Business Insights | Not started | Business insights document exists but is empty. |
| Phase 10 - Documentation | Not started | Final documentation is not complete yet. |
| Phase 11 - GitHub Polishing | Not started | Repository polish/readiness work is pending. |

## Completed Work

### Phase 2 - Database Design

- Created the MySQL database schema in `SQL/01_database_schema.sql`.
- Added `CREATE DATABASE IF NOT EXISTS ecommerce_sales`.
- Added staging tables for raw CSV imports.
- Added clean analytical tables with primary keys, foreign keys, and basic check constraints.
- Modeled `order_reviews` with a surrogate `review_key` because raw `review_id` is not unique.
- Modeled geolocation with a raw staging table and an aggregated `geolocation_zip_prefixes` table because raw zip prefixes repeat.
- Added indexes for common joins and analysis filters.
- Kept product misspelling columns such as `product_name_lenght` and `product_description_lenght` for raw dataset traceability.

### Phase 3 - Create/Import Data

- Added staging import script in `SQL/phase_3_import_staging_data.sql`.
- Added staging row-count verification script in `SQL/phase_3_verify_staging_import.sql`.
- Added import instructions in `Documentation/Phase_3_Import_Notes.md`.
- Confirmed MySQL client is installed locally.
- Enabled MySQL `local_infile` for CSV loading.
- Imported all raw CSV files into staging tables.
- Fixed CSV loading by disabling backslash escaping with `ESCAPED BY ''`, because one review comment ends with a literal backslash.
- Verified all staging row counts against Phase 1 expected counts.
- Verified required staging key/date/value fields have zero blank values.

### Phase 4 - Data Quality Assessment

- Added data quality assessment script in `SQL/phase_4_data_quality_assessment.sql`.
- Ran staging quality checks in MySQL.
- Verified row counts still match expected values.
- Profiled blank values, duplicate keys, full-row duplicates, relationship coverage, type conversion readiness, domain validity, date formats, and date chronology.
- Documented findings in `Documentation/Phase_4_Data_Quality_Assessment.md`.
- Confirmed core transactional relationships have zero orphan rows.
- Confirmed numeric fields, date formats, order statuses, review scores, prices, freight values, payment values, and geolocation coordinate ranges are valid.
- Identified cleaning work for duplicate review ids, missing product metadata, untranslated product categories, missing geolocation zip prefixes, repeated geolocation observations, and delivery chronology anomalies.

### Phase 5 - Data Cleaning

- Added cleaning script in `SQL/03_data_cleaning.sql`.
- Added cleaning verification script in `SQL/phase_5_verify_cleaning.sql`.
- Loaded clean analytical tables from staging tables.
- Converted blank strings to `NULL` where appropriate.
- Converted staging text fields into analytical data types.
- Added translations for `pc_gamer` and `portateis_cozinha_e_preparadores_de_alimentos`.
- Aggregated raw geolocation observations into `geolocation_zip_prefixes`.
- Preserved duplicate review source ids while using `review_key` as the analytical primary key.
- Preserved date chronology anomalies for later analysis instead of silently rewriting them.
- Verified clean row counts and core relationships.
- Documented cleaning decisions in `Documentation/Phase_5_Data_Cleaning.md`.

### Phase 6 - Exploratory Data Analysis

- Added EDA script in `SQL/phase_6_exploratory_analysis.sql`.
- Ran baseline exploratory queries against clean analytical tables.
- Profiled dataset size, date coverage, order statuses, order size, revenue, payment methods, customer repeat behavior, geography, categories, reviews, and delivery context.
- Fixed product category translation cleanup by removing carriage-return characters from English category names during Phase 5 cleaning.
- Reran Phase 5 verification after the category text fix.
- Documented EDA findings in `Documentation/Phase_6_Exploratory_Data_Analysis.md`.

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
| MySQL database schema | `SQL/01_database_schema.sql` |
| Phase 3 import instructions | `Documentation/Phase_3_Import_Notes.md` |
| Staging import script | `SQL/phase_3_import_staging_data.sql` |
| Staging verification script | `SQL/phase_3_verify_staging_import.sql` |
| Phase 4 data quality script | `SQL/phase_4_data_quality_assessment.sql` |
| Phase 4 data quality findings | `Documentation/Phase_4_Data_Quality_Assessment.md` |
| Phase 5 cleaning script | `SQL/03_data_cleaning.sql` |
| Phase 5 cleaning verification | `SQL/phase_5_verify_cleaning.sql` |
| Phase 5 cleaning documentation | `Documentation/Phase_5_Data_Cleaning.md` |
| Phase 6 EDA script | `SQL/phase_6_exploratory_analysis.sql` |
| Phase 6 EDA findings | `Documentation/Phase_6_Exploratory_Data_Analysis.md` |

## Next Task

Start Phase 7 by writing structured business analysis queries in `SQL/04_business_queries.sql`.
