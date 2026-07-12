# Phase 8 Power BI Dashboard

Phase 8 prepares the Power BI dashboard layer for the E-Commerce Sales Analytics Dashboard project.

Power BI reporting views:
`SQL/05_views.sql`

Dashboard design date:
July 12, 2026

Reporting view verification date:
July 12, 2026

## Dashboard Objective

Build an interactive Power BI report that helps business users monitor revenue, order trends, product/category performance, customer geography, delivery performance, payment behavior, and seller risk.

The dashboard should be driven from MySQL reporting views rather than raw transactional tables or long ad hoc analysis queries.

## MySQL Reporting Views

| View | Grain | Power BI use |
|---|---|---|
| `vw_powerbi_order_items_enriched` | One row per order item | Main fact table for drill-through and flexible slicing |
| `vw_powerbi_dashboard_kpis` | One row | Executive KPI cards |
| `vw_powerbi_monthly_kpis` | One row per purchase month | Monthly trends and executive time series |
| `vw_powerbi_category_performance` | One row per category | Product/category page |
| `vw_powerbi_customer_markets` | One row per customer city/state | Customer geography page |
| `vw_powerbi_seller_performance` | One row per seller | Seller performance page |
| `vw_powerbi_delivery_performance` | One row per customer/seller state pair and fulfillment scope | Delivery and geography page |
| `vw_powerbi_payment_methods` | One row per payment method | Payment analysis visuals |
| `vw_powerbi_seller_category_risk` | One row per seller/category pair | Seller risk and account-management view |

## Recommended Report Pages

### 1. Executive Summary

Purpose:
Give a fast business health overview.

Visuals:

| Visual | Fields |
|---|---|
| KPI cards | Gross item value, total orders, average order value, freight share, average review score |
| Line chart | `purchase_month` by `gross_item_value` |
| Combo chart | `purchase_month`, `orders`, `avg_order_value` |
| Bar chart | Top categories by `gross_item_value` |
| Bar chart | Top customer states by `gross_item_value` |
| Table | Category performance with revenue rank and satisfaction risk rank |

Primary views:
`vw_powerbi_dashboard_kpis`, `vw_powerbi_monthly_kpis`, `vw_powerbi_category_performance`, `vw_powerbi_customer_markets`

### 2. Sales and Revenue

Purpose:
Explain revenue movement over time.

Visuals:

| Visual | Fields |
|---|---|
| Line chart | Monthly gross item value |
| Column chart | Monthly orders |
| Line chart | Month-over-month growth percentage |
| Stacked bar | Revenue by order status |
| Matrix | Year, month, gross item value, average order value |

Primary views:
`vw_powerbi_monthly_kpis`, `vw_powerbi_order_items_enriched`

### 3. Product and Category

Purpose:
Identify product/category growth, revenue concentration, and satisfaction risk.

Visuals:

| Visual | Fields |
|---|---|
| Bar chart | Category by gross item value |
| Bar chart | Category by items sold |
| Scatter plot | Gross item value versus average review score, sized by orders |
| Table | Category name, revenue rank, satisfaction risk rank, low-score reviews |
| Drill-through table | Product ID, category, revenue, units sold |

Primary views:
`vw_powerbi_category_performance`, `vw_powerbi_order_items_enriched`

### 4. Customer and Geography

Purpose:
Show where demand comes from and how markets differ by order value and freight burden.

Visuals:

| Visual | Fields |
|---|---|
| Filled map or shape map | Customer state by gross item value |
| Bar chart | Top customer cities by gross item value |
| Matrix | Customer state, orders, unique customers, average order value |
| Bar chart | Customer state by freight share |
| KPI card | Repeat customer percentage |

Primary views:
`vw_powerbi_customer_markets`, `vw_powerbi_dashboard_kpis`

### 5. Delivery and Operations

Purpose:
Explain delivery speed, late delivery, and fulfillment distance.

Visuals:

| Visual | Fields |
|---|---|
| KPI cards | Average delivery days, on-time percentage, late delivery percentage |
| Bar chart | Same-state versus cross-state average delivery days |
| Bar chart | Customer state by late delivery percentage |
| Matrix | Customer state, seller state, fulfillment scope, freight, delivery days |
| Scatter plot | Freight versus delivery days by state pair |

Primary views:
`vw_powerbi_delivery_performance`, `vw_powerbi_monthly_kpis`, `vw_powerbi_order_items_enriched`

### 6. Payments and Sellers

Purpose:
Show payment behavior and identify sellers needing account-management attention.

Visuals:

| Visual | Fields |
|---|---|
| Donut chart | Payment value share by payment type |
| Bar chart | Average payment value by payment type |
| Bar chart | Top sellers by gross item value |
| Scatter plot | Seller gross item value versus average review score |
| Table | Seller/category risk with revenue, review score, and late delivery percentage |

Primary views:
`vw_powerbi_payment_methods`, `vw_powerbi_seller_performance`, `vw_powerbi_seller_category_risk`

## Recommended Slicers

- Purchase year
- Purchase month
- Order status
- Customer state
- Seller state
- Product category
- Fulfillment scope
- Payment type

## Suggested DAX Measures

Create these measures in Power BI if using `vw_powerbi_order_items_enriched` as the main fact table:

```DAX
Gross Item Value = SUM(vw_powerbi_order_items_enriched[gross_item_value])

Product Revenue = SUM(vw_powerbi_order_items_enriched[product_revenue])

Freight Revenue = SUM(vw_powerbi_order_items_enriched[freight_revenue])

Total Orders = DISTINCTCOUNT(vw_powerbi_order_items_enriched[order_id])

Items Sold = COUNTROWS(vw_powerbi_order_items_enriched)

Average Order Value = DIVIDE([Gross Item Value], [Total Orders])

Freight Share % = DIVIDE([Freight Revenue], [Gross Item Value])

Average Review Score = AVERAGE(vw_powerbi_order_items_enriched[avg_review_score])

On-Time Delivery % =
DIVIDE(
    SUM(vw_powerbi_order_items_enriched[is_on_time_delivery]),
    SUM(vw_powerbi_order_items_enriched[is_on_time_delivery])
        + SUM(vw_powerbi_order_items_enriched[is_late_delivery])
)

Late Delivery % =
DIVIDE(
    SUM(vw_powerbi_order_items_enriched[is_late_delivery]),
    SUM(vw_powerbi_order_items_enriched[is_on_time_delivery])
        + SUM(vw_powerbi_order_items_enriched[is_late_delivery])
)
```

Format percentage measures as percentages in Power BI.

## Data Model Guidance

- Import the reporting views from MySQL.
- Use `vw_powerbi_order_items_enriched` as the main fact table.
- Use aggregated views directly for page-specific visuals when they avoid unnecessary DAX complexity.
- Hide technical columns that are not needed by report users.
- Prefer import mode for this portfolio project unless live refresh is specifically required.

## Visual Design Guidance

- Use a restrained analytical layout: KPI cards at the top, trend visuals in the middle, detailed tables at the bottom.
- Keep filters in a left sidebar or top filter strip.
- Use consistent colors for business concepts:
  - Revenue: green
  - Orders/customers: blue
  - Delivery risk: red
  - Reviews/satisfaction: amber
- Use conditional formatting for low review scores, high late-delivery percentages, and high freight share.
- Keep all visuals tied to business questions from Phase 7.

## Phase 8 Completion Criteria

- `SQL/05_views.sql` executes successfully in MySQL. Completed.
- Power BI can connect to the MySQL `ecommerce_sales` database.
- The dashboard uses the reporting views above.
- Each dashboard page has a clear purpose and at least one actionable business question.
- Dashboard screenshots are saved in `Images/` after the report is built.

## Verification Results

The reporting view script was executed successfully against the local MySQL `ecommerce_sales` database.

Evidence file:
`Documentation/Phase_8_PowerBI_Views_Output.txt`

Validated outputs:

| Check | Result |
|---|---:|
| Power BI reporting views created | 9 |
| `vw_powerbi_order_items_enriched` rows | 112,650 |
| `vw_powerbi_monthly_kpis` rows | 24 |
| `vw_powerbi_category_performance` rows | 74 |
| Dashboard KPI gross item value | 15,843,553.24 |
| Dashboard KPI average order value | 160.58 |
| Dashboard KPI repeat customer percentage | 3.12 |
| Dashboard KPI average review score | 4.09 |

No SQL errors were found in the captured verification output.

## Next Step

Open Power BI Desktop, connect to MySQL, import the `vw_powerbi_*` views, create the recommended DAX measures, and build the report pages listed above.
