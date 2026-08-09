# Power BI Dashboard Build Guide

This guide turns the Phase 8 reporting scope into an implementable Power BI build plan.

## Goal

Build a six-page Power BI report for the `ecommerce_sales` MySQL database using the reporting views defined in `../SQL/05_views.sql`.

## Data Sources

Use these views as the semantic layer for the report:

- `vw_powerbi_order_items_enriched`
- `vw_powerbi_dashboard_kpis`
- `vw_powerbi_monthly_kpis`
- `vw_powerbi_category_performance`
- `vw_powerbi_customer_markets`
- `vw_powerbi_seller_performance`
- `vw_powerbi_delivery_performance`
- `vw_powerbi_payment_methods`
- `vw_powerbi_seller_category_risk`

## Recommended Model

1. Import the MySQL reporting views.
2. Use `vw_powerbi_order_items_enriched` as the primary fact table.
3. Use the aggregated views directly for page visuals where they reduce DAX complexity.
4. Hide technical columns not needed by report consumers.
5. Prefer import mode for this portfolio project.

## Core Measures

Create these measures in Power BI if you use `vw_powerbi_order_items_enriched` as the main fact table:

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

Format all percentage measures as percentages.

## Report Pages

### 1. Executive Summary

Purpose: give a fast business health overview.

Layout:

- Top row: KPI cards for gross item value, total orders, average order value, freight share, and average review score.
- Middle row: monthly revenue line chart and orders/AOV combo chart.
- Bottom row: top categories by revenue and top customer states by revenue.

Use:

- `vw_powerbi_dashboard_kpis`
- `vw_powerbi_monthly_kpis`
- `vw_powerbi_category_performance`
- `vw_powerbi_customer_markets`

### 2. Sales and Revenue

Purpose: explain revenue movement over time.

Layout:

- Monthly gross item value line chart.
- Monthly orders column chart.
- Month-over-month growth line chart.
- Revenue by order status stacked bar chart.
- Year/month matrix with gross item value and average order value.

Use:

- `vw_powerbi_monthly_kpis`
- `vw_powerbi_order_items_enriched`

### 3. Product and Category

Purpose: identify growth, concentration, and satisfaction risk.

Layout:

- Category by gross item value bar chart.
- Category by items sold bar chart.
- Scatter plot of gross item value versus average review score, sized by orders.
- Category performance table with revenue rank and satisfaction risk rank.
- Drill-through table for product-level inspection.

Use:

- `vw_powerbi_category_performance`
- `vw_powerbi_order_items_enriched`

### 4. Customer and Geography

Purpose: show where demand comes from and how markets differ.

Layout:

- Filled map or shape map of customer state by gross item value.
- Top customer cities by gross item value.
- Customer state matrix with orders, unique customers, and average order value.
- Customer state by freight share bar chart.
- Repeat customer percentage KPI.

Use:

- `vw_powerbi_customer_markets`
- `vw_powerbi_dashboard_kpis`

### 5. Delivery and Operations

Purpose: explain delivery speed, late delivery, and fulfillment distance.

Layout:

- KPI cards for average delivery days, on-time percentage, and late delivery percentage.
- Same-state versus cross-state average delivery days bar chart.
- Customer state by late delivery percentage bar chart.
- Fulfillment matrix with freight and delivery days.
- Freight versus delivery days scatter plot.

Use:

- `vw_powerbi_delivery_performance`
- `vw_powerbi_monthly_kpis`
- `vw_powerbi_order_items_enriched`

### 6. Payments and Sellers

Purpose: show payment behavior and seller risk.

Layout:

- Payment value share donut chart.
- Average payment value by payment type bar chart.
- Top sellers by gross item value bar chart.
- Seller gross item value versus average review score scatter plot.
- Seller/category risk table with revenue, review score, and late delivery percentage.

Use:

- `vw_powerbi_payment_methods`
- `vw_powerbi_seller_performance`
- `vw_powerbi_seller_category_risk`

## Slicers

Add these slicers globally where possible:

- Purchase year
- Purchase month
- Order status
- Customer state
- Seller state
- Product category
- Fulfillment scope
- Payment type

## Visual Rules

- Revenue: green
- Orders and customers: blue
- Delivery risk: red
- Reviews and satisfaction: amber
- Keep KPI cards at the top, trends in the middle, and detail tables at the bottom.
- Use conditional formatting for low review scores, high late-delivery percentages, and high freight share.

## Build Order

1. Connect Power BI Desktop to MySQL.
2. Import all `vw_powerbi_*` views.
3. Build the core measures.
4. Create the six report pages in the order above.
5. Apply the theme file in this folder.
6. Export screenshots to `../Images/`.

## Completion Check

The dashboard is ready when the report includes the six pages above, uses the reporting views instead of raw tables, and the screenshots are saved in `../Images/`.