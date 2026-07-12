# E-Commerce Sales Analytics Dashboard

An end-to-end analytics project using the Olist Brazilian E-Commerce Public Dataset. The project covers data understanding, MySQL database design, staging import, quality assessment, cleaning, exploratory analysis, business analysis, Power BI reporting views, and portfolio-ready documentation.

## Project Status

Most of the SQL and documentation workflow is complete. The Power BI reporting layer is ready, and the remaining manual step is to build `PowerBI/Dashboard.pbix` in Power BI Desktop using the verified MySQL views.

| Area | Status |
|---|---|
| Data understanding and dictionary | Complete |
| MySQL schema design | Complete |
| CSV import to staging tables | Complete |
| Data quality assessment | Complete |
| Data cleaning and analytical tables | Complete |
| Exploratory data analysis | Complete |
| Business analysis SQL | Complete |
| Power BI reporting views | Complete |
| Power BI dashboard `.pbix` | Pending manual build |
| Business insights documentation | Complete from SQL analysis |
| Repository polish | Complete except final dashboard screenshots |

## Business Questions

This project answers questions such as:

- How much revenue does the marketplace generate?
- Which months, states, categories, products, and sellers drive performance?
- How concentrated is revenue across sellers and categories?
- How important are repeat customers?
- Which payment methods dominate transaction value?
- How does delivery performance affect customer satisfaction?
- Which seller/category combinations need account-management attention?

## Dataset

Dataset: [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/)

The dataset contains customers, orders, order items, payments, reviews, products, sellers, product category translations, and geolocation records for a Brazilian e-commerce marketplace.

## Tech Stack

- MySQL
- SQL
- Python/Pandas for early validation
- Power BI
- Git and GitHub

## Key Results

| KPI | Value |
|---|---:|
| Gross item value | 15,843,553.24 |
| Product revenue | 13,591,643.70 |
| Freight revenue | 2,251,909.54 |
| Freight share | 14.21% |
| Orders with items | 98,666 |
| Items sold | 112,650 |
| Average order value | 160.58 |
| Unique customers | 96,096 |
| Repeat customer rate | 3.12% |
| Average review score | 4.09 |

## Main Insights

- Revenue is concentrated in delivered orders, which generated 15,419,773.75 in gross item value.
- November 2017 was the strongest month, with 1,179,143.77 in gross item value across 7,451 orders.
- Repeat customers are only 3.12% of unique customers, but they have higher average customer value than one-time customers.
- SP, RJ, and MG are the largest customer markets by gross item value.
- Health and beauty, watches and gifts, and bed/bath/table are the top revenue categories.
- Credit card payments dominate, contributing 78.34% of payment value.
- Cross-state fulfillment is slower and more expensive than same-state fulfillment.
- The top seller decile contributes 66.76% of gross item value.
- Office furniture is a satisfaction-risk category with a 3.49 average review score and 26.08% low-score reviews.

## Repository Structure

```text
E-Commerce Sales Analytics Dashboard/
|-- Data/
|   |-- Raw/
|   `-- kaggle_description.md
|-- Documentation/
|   |-- Business_Insights.md
|   |-- Data_Dictionary.md
|   |-- Final_Project_Summary.md
|   |-- Project_Progress.md
|   |-- Phase_3_Import_Notes.md
|   |-- Phase_4_Data_Quality_Assessment.md
|   |-- Phase_5_Data_Cleaning.md
|   |-- Phase_6_Exploratory_Data_Analysis.md
|   |-- Phase_7_Business_Analysis.md
|   `-- Phase_8_PowerBI_Dashboard.md
|-- Images/
|-- PowerBI/
|   `-- README.md
|-- SQL/
|   |-- 01_database_schema.sql
|   |-- 02_constraints_indexes.sql
|   |-- 03_data_cleaning.sql
|   |-- 04_business_queries.sql
|   |-- 05_views.sql
|   |-- 06_stored_procedures.sql
|   |-- 07_triggers.sql
|   |-- phase_3_import_staging_data.sql
|   |-- phase_3_verify_staging_import.sql
|   |-- phase_4_data_quality_assessment.sql
|   |-- phase_5_verify_cleaning.sql
|   `-- phase_6_exploratory_analysis.sql
|-- Validation/
|   |-- phase_1_data_validation.py
|   `-- phase_1_validation_summary.md
`-- README.md
```

## Workflow

1. Understand the dataset and document table grain, keys, and relationships.
2. Design a MySQL database with staging and clean analytical tables.
3. Import raw CSV files into staging tables.
4. Run data quality checks against staging data.
5. Clean and load analytical tables.
6. Run exploratory data analysis.
7. Write and execute 50 business-analysis SQL queries.
8. Create Power BI reporting views and dashboard build guidance.
9. Document insights, recommendations, and final project summary.
10. Polish the repository for portfolio use.

## SQL Assets

| File | Purpose |
|---|---|
| `SQL/01_database_schema.sql` | Database, staging tables, analytical tables, constraints, and indexes |
| `SQL/03_data_cleaning.sql` | Clean table load logic |
| `SQL/04_business_queries.sql` | 50 business-analysis queries |
| `SQL/05_views.sql` | 9 Power BI reporting views |
| `SQL/phase_4_data_quality_assessment.sql` | Staging data quality checks |
| `SQL/phase_5_verify_cleaning.sql` | Clean table verification |
| `SQL/phase_6_exploratory_analysis.sql` | Baseline exploratory analysis |

## Power BI Plan

The dashboard should use the `vw_powerbi_*` views from `SQL/05_views.sql`.

Recommended report pages:

- Executive Summary
- Sales and Revenue
- Product and Category
- Customer and Geography
- Delivery and Operations
- Payments and Sellers

Detailed build instructions are available in `Documentation/Phase_8_PowerBI_Dashboard.md`.

## How To Run

Create schema:

```powershell
mysql --local-infile=1 -u root -p < SQL/01_database_schema.sql
```

Import staging data:

```powershell
mysql --local-infile=1 -u root -p < SQL/phase_3_import_staging_data.sql
```

Clean analytical tables:

```powershell
mysql -u root -p ecommerce_sales < SQL/03_data_cleaning.sql
```

Run business analysis:

```powershell
mysql -u root -p ecommerce_sales < SQL/04_business_queries.sql
```

Create Power BI reporting views:

```powershell
mysql -u root -p ecommerce_sales < SQL/05_views.sql
```

## Documentation

- `Documentation/Data_Dictionary.md`
- `Documentation/Business_Insights.md`
- `Documentation/Final_Project_Summary.md`
- `Documentation/Project_Progress.md`
- `Documentation/Phase_8_PowerBI_Dashboard.md`

## Known Pending Items

- Build `PowerBI/Dashboard.pbix` manually in Power BI Desktop.
- Export final dashboard screenshots to `Images/`.
- Add the final dashboard preview to this README after screenshots are available.

## Author

Suraj Kumar Yadav
