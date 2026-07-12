# Business Insights

This document summarizes the business findings from the SQL analysis phase of the E-Commerce Sales Analytics Dashboard project. Insights are based on the clean MySQL analytical tables and the executed Phase 7 business-analysis queries.

Evidence:

- `SQL/04_business_queries.sql`
- `Documentation/Phase_7_Business_Analysis_Output.txt`
- `SQL/05_views.sql`
- `Documentation/Phase_8_PowerBI_Views_Output.txt`

## Executive Summary

The marketplace generated 15,843,553.24 in gross item value from 98,666 orders with items and 112,650 sold items. Product revenue contributes 13,591,643.70, while freight contributes 2,251,909.54, equal to 14.21% of gross item value.

The business is strongly order-acquisition driven: repeat customers represent only 3.12% of unique customers. Revenue is also concentrated geographically and operationally, with SP, RJ, and MG leading customer demand, and the top seller decile contributing 66.76% of gross item value.

Delivery performance and review quality are important risk areas. Cross-state fulfillment is slower and more expensive than same-state fulfillment, and some high-revenue categories and sellers show weak customer satisfaction.

## KPI Snapshot

| Metric | Value |
|---|---:|
| Gross item value | 15,843,553.24 |
| Product revenue | 13,591,643.70 |
| Freight revenue | 2,251,909.54 |
| Freight share | 14.21% |
| Orders with items | 98,666 |
| Items sold | 112,650 |
| Average order value | 160.58 |
| Unique customers | 96,096 |
| Repeat customer percentage | 3.12 |
| Average review score | 4.09 |

## Revenue Insights

### Insight 1: Revenue is mostly concentrated in delivered orders

Delivered orders generated 15,419,773.75 in gross item value across 96,478 orders.

Business meaning:
The marketplace has a healthy completed-order base, but revenue reporting should distinguish delivered orders from canceled, shipped, unavailable, processing, and invoiced orders. Non-delivered orders should be monitored separately because they can indicate fulfillment or availability issues.

Recommendation:
Use delivered-order revenue as the primary realized revenue KPI in the dashboard, while tracking non-delivered order value as an operational risk indicator.

### Insight 2: November 2017 was the strongest month

November 2017 generated 1,179,143.77 in gross item value across 7,451 orders.

Business meaning:
The business shows a strong seasonal peak around November, likely connected to major retail campaigns and holiday shopping behavior.

Recommendation:
Use November as a benchmark month for campaign planning, inventory preparation, seller capacity planning, and delivery-risk monitoring.

### Insight 3: Freight is a meaningful part of customer cost

Freight revenue is 2,251,909.54, representing 14.21% of gross item value.

Business meaning:
Shipping cost is large enough to influence conversion, customer satisfaction, and geographic profitability.

Recommendation:
Track freight share by customer state and fulfillment scope. High-freight states should be evaluated for local seller expansion or logistics optimization.

## Customer Insights

### Insight 4: Retention is a major opportunity

Repeat customers are only 3.12% of unique customers. One-time customers contribute 94.29% of gross item value.

Business meaning:
The marketplace depends heavily on acquiring new customers. This creates growth potential, but it also means repeat purchase behavior is underdeveloped.

Recommendation:
Introduce retention-focused actions such as post-purchase campaigns, category-specific recommendations, loyalty offers, and reactivation campaigns for high-value one-time buyers.

### Insight 5: Repeat customers are more valuable

Repeat customers have higher average customer value than one-time customers.

Business meaning:
Even though repeat customers are a small group, improving retention can have an outsized effect on revenue efficiency.

Recommendation:
Create a repeat-customer KPI in the dashboard and monitor repeat behavior by category, state, and purchase month.

## Product and Category Insights

### Insight 6: Top revenue categories are broad consumer categories

The top categories by gross item value are:

| Rank | Category |
|---:|---|
| 1 | health_beauty |
| 2 | watches_gifts |
| 3 | bed_bath_table |

Business meaning:
Revenue is driven by categories with frequent consumer demand, giftability, and household utility.

Recommendation:
Prioritize these categories for executive monitoring, seller operations, campaign planning, and inventory readiness.

### Insight 7: High price and high volume categories behave differently

Computers has the highest average item price among categories with at least 100 items sold, while categories such as bed/bath/table and health/beauty drive high revenue through volume.

Business meaning:
The dashboard should not judge category performance from revenue alone. Average item price, units sold, and satisfaction need to be shown together.

Recommendation:
Use a category scatter plot with gross item value, orders, and average review score to separate premium categories from high-volume categories.

### Insight 8: Office furniture is a satisfaction-risk category

Office furniture has meaningful revenue but weak satisfaction, with a 3.49 average review score and 26.08% low-score reviews.

Business meaning:
This category may have problems related to delivery, product expectations, assembly, size, damage, or seller quality.

Recommendation:
Investigate office furniture sellers, late deliveries, review comments, and return-related signals if available. This category should be highlighted in the product dashboard as a risk area.

## Payment Insights

### Insight 9: Credit card dominates payment value

Credit card payments contribute 78.34% of payment value. Boleto is second at 17.92%.

Business meaning:
Payment behavior is heavily card-driven, so card processing reliability and installment experience are important for marketplace revenue.

Recommendation:
Track payment method share over time and monitor high-value installment behavior, especially during peak months.

## Delivery and Geography Insights

### Insight 10: Same-state fulfillment is much faster

Cross-state delivered orders average 14.58 delivery days, compared with 7.46 days for same-state delivered orders.

Business meaning:
Distance and fulfillment geography materially affect customer experience.

Recommendation:
Use same-state versus cross-state fulfillment as a core delivery dashboard dimension. Consider local seller recruitment or regional fulfillment improvements in high-demand states.

### Insight 11: Cross-state fulfillment is more expensive

Cross-state orders have average item freight of 23.63, compared with 13.45 for same-state orders.

Business meaning:
Cross-state fulfillment creates both cost pressure and service-level risk.

Recommendation:
Track freight and delivery days together. Markets with high revenue, high freight, and slow delivery should be prioritized for operational improvement.

### Insight 12: BA is a high-revenue, slow-delivery market

BA appears as a notable market combining high revenue with slower-than-average delivery.

Business meaning:
BA demand is commercially meaningful, but delivery experience may limit satisfaction and repeat purchase potential.

Recommendation:
Review BA seller coverage, seller-state sources, late delivery rates, and freight share. BA should be visible in the geography dashboard.

## Seller Insights

### Insight 13: Seller revenue is highly concentrated

The top seller decile contributes 66.76% of gross item value.

Business meaning:
The marketplace depends heavily on a relatively small group of sellers.

Recommendation:
Use seller concentration as an executive risk metric. High-revenue sellers should be monitored for review score, late delivery, and category dependence.

### Insight 14: Some high-revenue sellers have weak reviews

Several high-revenue sellers have average review scores below 4.0.

Business meaning:
High sales volume does not always mean healthy customer experience. These sellers may create long-term satisfaction and retention risk.

Recommendation:
Create a seller risk table that combines seller revenue, review score, late delivery percentage, and primary category.

## Dashboard Implications

The Power BI dashboard should include:

- Executive KPI cards for revenue, orders, AOV, freight share, repeat customers, and review score.
- Monthly revenue and order trends.
- Product/category revenue and satisfaction risk visuals.
- Customer geography by state and city.
- Same-state versus cross-state delivery comparisons.
- Payment method share and average payment value.
- Seller performance and seller/category risk tables.

## Final Recommendations

1. Treat retention as a strategic opportunity because repeat customer share is very low.
2. Monitor cross-state fulfillment as a delivery and freight-cost risk.
3. Prioritize office furniture for category-quality investigation.
4. Protect top seller relationships while monitoring their satisfaction and delivery metrics.
5. Use November peak demand as a planning benchmark for inventory, seller capacity, and delivery operations.
6. Build the Power BI dashboard around both performance and risk, not just revenue rankings.
