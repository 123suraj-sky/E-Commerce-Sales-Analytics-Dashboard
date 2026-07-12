# Business Insights

This document will become the final business-insights layer after the Power BI dashboard is built. The notes below capture the strongest findings from Phase 7 SQL analysis.

## Phase 7 Preliminary Insights

### Revenue

- Gross item value is 15,843,553.24.
- Product revenue is 13,591,643.70.
- Freight revenue is 2,251,909.54, or 14.21% of gross item value.
- November 2017 is the highest revenue month, with 1,179,143.77 gross item value across 7,451 orders.
- Delivered orders generate almost all realized item value: 15,419,773.75 from 96,478 delivered orders.

### Customers

- Repeat customers are only 3.12% of unique customers.
- One-time customers contribute 94.29% of gross item value.
- Repeat customers have a higher average customer value than one-time customers, which makes retention a clear improvement opportunity.
- SP, RJ, and MG are the top three customer states by gross item value.

### Products and Categories

- The top categories by gross item value are health and beauty, watches and gifts, and bed/bath/table.
- Computers has the highest average item price among categories with at least 100 items sold.
- Office furniture stands out as a risk category: it has meaningful revenue but an average review score of 3.49.

### Payments

- Credit card dominates payment value at 78.34%.
- Boleto is the second-largest payment method at 17.92%.
- Voucher and debit card contribute much smaller shares of payment value.

### Delivery and Geography

- Cross-state fulfillment accounts for more orders and revenue than same-state fulfillment, but it is slower and more expensive.
- Cross-state delivered orders average 14.58 delivery days, compared with 7.46 days for same-state delivered orders.
- Cross-state orders also have higher average item freight: 23.63 versus 13.45.
- BA is a notable market with both high revenue and slower-than-average delivery.

### Sellers

- Seller revenue is highly concentrated: the top seller decile contributes 66.76% of gross item value.
- Several high-revenue sellers have average review scores below 4.0, making seller quality a useful dashboard risk view.

## Dashboard Implications

- The executive dashboard should track gross item value, orders, average order value, review score, delivery days, and on-time delivery percentage by month.
- The product dashboard should compare revenue rank against satisfaction risk rank.
- The geography dashboard should separate same-state and cross-state fulfillment because delivery speed and freight economics differ sharply.
- The seller dashboard should highlight revenue concentration, weak-review sellers, and seller-category combinations with late delivery or low satisfaction.
