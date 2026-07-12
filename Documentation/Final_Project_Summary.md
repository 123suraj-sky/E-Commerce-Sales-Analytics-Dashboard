# Final Project Summary

Project:
E-Commerce Sales Analytics Dashboard

Dataset:
Olist Brazilian E-Commerce Public Dataset

## Objective

Build a realistic data analyst portfolio project that starts from raw e-commerce CSV files and ends with a documented analytics layer ready for Power BI dashboarding.

## Completed Workflow

| Phase | Result |
|---|---|
| Dataset understanding | Documented table grain, column meanings, keys, and relationships |
| Database design | Created MySQL staging and analytical schemas |
| Data import | Loaded raw CSV files into staging tables |
| Data quality assessment | Profiled missing values, duplicates, relationship coverage, domains, date logic, and numeric validity |
| Data cleaning | Loaded clean analytical tables with typed fields and documented cleaning decisions |
| Exploratory analysis | Established dataset size, date range, revenue, customer, category, review, and delivery context |
| Business analysis | Wrote and executed 50 SQL business-analysis queries |
| Power BI preparation | Created 9 verified MySQL reporting views and a dashboard build guide |
| Business insights | Documented KPI results, interpretation, and recommendations |
| Repository polish | Updated README, progress tracking, folder notes, and final summary |

## Database Design

The project uses two layers:

- Staging tables that mirror the raw CSV files and preserve raw values.
- Clean analytical tables with typed columns, constraints, keys, and analysis-ready relationships.

Important modeling decisions:

- `order_reviews` uses `review_key` as a surrogate primary key because raw `review_id` is duplicated.
- Geolocation records are aggregated into `geolocation_zip_prefixes` because raw zip prefixes repeat.
- Product category translations are cleaned and extended for missing category mappings.
- Known date chronology anomalies are preserved for transparent analysis rather than silently overwritten.

## Main SQL Deliverables

| File | Purpose |
|---|---|
| `SQL/01_database_schema.sql` | Database schema, staging tables, analytical tables, constraints, and indexes |
| `SQL/03_data_cleaning.sql` | Cleaning and analytical-table load logic |
| `SQL/04_business_queries.sql` | 50 business-analysis queries |
| `SQL/05_views.sql` | Power BI reporting views |
| `SQL/phase_4_data_quality_assessment.sql` | Staging quality checks |
| `SQL/phase_5_verify_cleaning.sql` | Clean table verification |
| `SQL/phase_6_exploratory_analysis.sql` | Exploratory analysis |

## Power BI Reporting Layer

The following MySQL views were created and verified for Power BI:

| View | Purpose |
|---|---|
| `vw_powerbi_order_items_enriched` | Main item-level fact view |
| `vw_powerbi_dashboard_kpis` | Executive KPI cards |
| `vw_powerbi_monthly_kpis` | Monthly trend visuals |
| `vw_powerbi_category_performance` | Product/category analysis |
| `vw_powerbi_customer_markets` | Customer geography |
| `vw_powerbi_seller_performance` | Seller performance |
| `vw_powerbi_delivery_performance` | Delivery and fulfillment geography |
| `vw_powerbi_payment_methods` | Payment behavior |
| `vw_powerbi_seller_category_risk` | Seller/category risk monitoring |

Verification summary:

| Check | Result |
|---|---:|
| Reporting views created | 9 |
| Enriched item fact rows | 112,650 |
| Monthly KPI rows | 24 |
| Category performance rows | 74 |
| Gross item value | 15,843,553.24 |
| Repeat customer percentage | 3.12 |
| Average review score | 4.09 |

## Key Findings

- Gross item value is 15,843,553.24.
- Freight is 14.21% of gross item value.
- November 2017 is the highest revenue month.
- Repeat customers represent only 3.12% of unique customers.
- SP, RJ, and MG are the top customer states by gross item value.
- Health and beauty, watches and gifts, and bed/bath/table lead category revenue.
- Credit card payments account for 78.34% of payment value.
- Cross-state fulfillment is slower and more expensive than same-state fulfillment.
- The top seller decile contributes 66.76% of gross item value.
- Office furniture is a high-priority satisfaction-risk category.

## Pending Manual Work

The only major remaining project artifact is the Power BI report file:

- Build `PowerBI/Dashboard.pbix` in Power BI Desktop.
- Import the verified `vw_powerbi_*` views from MySQL.
- Create the recommended DAX measures from `Documentation/Phase_8_PowerBI_Dashboard.md`.
- Export dashboard screenshots into `Images/`.
- Add the screenshots to the README preview section.

## Portfolio Talking Points

- I designed a complete MySQL analytics workflow using staging and clean analytical layers.
- I documented data quality issues before cleaning instead of hiding them.
- I preserved source-data anomalies where rewriting would reduce transparency.
- I wrote 50 business-analysis SQL queries across revenue, customers, products, payments, delivery, geography, sellers, and reviews.
- I converted the SQL analysis into a Power BI-ready semantic layer with verified reporting views.
- I translated query results into business recommendations, not just charts.
