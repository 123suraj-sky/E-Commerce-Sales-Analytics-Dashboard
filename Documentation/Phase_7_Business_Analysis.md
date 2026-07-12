# Phase 7 Business Analysis

Phase 7 adds structured business-analysis SQL queries for the clean analytical tables.

Business analysis script:
`SQL/04_business_queries.sql`

Draft date:
July 12, 2026

Execution date:
July 12, 2026

## Query Coverage

The script contains 50 business questions organized into these sections:

| Section | Query range | Focus |
|---|---:|---|
| Revenue Analysis | Q01-Q06 | Gross item value, monthly revenue, order value, freight share, order status revenue |
| Customer Analysis | Q07-Q13 | Customer lifetime value, repeat behavior, customer geography, purchase gaps |
| Product and Category Analysis | Q14-Q20 | Category revenue, product performance, category trends, satisfaction risk |
| Payment Analysis | Q21-Q25 | Payment value, payment methods, installments, split payments |
| Delivery Analysis | Q26-Q31 | Delivery speed, late delivery, seller shipping-limit performance |
| Geography Analysis | Q32-Q36 | Customer-seller state flows, same-state versus cross-state fulfillment, freight burden |
| Seller Analysis | Q37-Q42 | Seller revenue, revenue concentration, seller satisfaction, category concentration |
| Review and Satisfaction Analysis | Q43-Q46 | Review trends, low-score reviews, written feedback behavior |
| Executive Dashboard Support | Q47-Q50 | Dashboard-ready KPI tables and prioritized monitoring lists |

## Design Notes

- Revenue analysis uses `order_items.price + order_items.freight_value`.
- Payment analysis uses `order_payments.payment_value`.
- Delivery and late-order metrics use delivered orders with available customer delivery dates where appropriate.
- Queries that join order items to orders use `COUNT(DISTINCT order_id)` for order-level metrics to avoid counting multi-item orders more than once.
- Category labels use English names from `product_category_translation` and fall back to `unknown` when product category metadata is missing.

## Verification Status

The SQL file was executed successfully against the local MySQL `ecommerce_sales` database.

Execution evidence:
`Documentation/Phase_7_Business_Analysis_Output.txt`

No SQL errors were found in the captured output.

## Key Findings

| Area | Finding |
|---|---|
| Revenue | Gross item value is 15,843,553.24, including 13,591,643.70 product revenue and 2,251,909.54 freight revenue. |
| Freight | Freight represents 14.21% of gross item value. |
| Seasonality | November 2017 is the strongest month, with 1,179,143.77 gross item value across 7,451 orders. |
| Customer retention | Repeat customers are only 3.12% of unique customers, but their average customer value is higher than one-time customers. |
| Geography | SP is the largest customer market with 5,921,678.12 gross item value, followed by RJ and MG. |
| Product categories | Health and beauty, watches and gifts, and bed/bath/table are the top three categories by gross item value. |
| Payments | Credit card is the dominant payment method, contributing 78.34% of payment value. |
| Delivery | Cross-state fulfillment takes much longer than same-state fulfillment: 14.58 days versus 7.46 days on average. |
| Sellers | Seller revenue is highly concentrated: the top seller decile contributes 66.76% of gross item value. |
| Satisfaction risk | Office furniture is a high-revenue category with weak satisfaction, averaging 3.49 review score and 26.08% low-score reviews. |

## Next Step

Move to Phase 8 by designing the Power BI dashboard around the executive KPIs, category performance, customer geography, delivery performance, and seller risk tables from `SQL/04_business_queries.sql`.
