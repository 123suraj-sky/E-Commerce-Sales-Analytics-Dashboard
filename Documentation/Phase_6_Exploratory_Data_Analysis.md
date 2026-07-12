# Phase 6 Exploratory Data Analysis

Phase 6 establishes baseline context from the clean analytical tables before deeper business analysis.

EDA script:
`SQL/phase_6_exploratory_analysis.sql`

EDA run date:
July 12, 2026

## Dataset Overview

| Metric | Value |
|---|---:|
| Customers | 99,441 |
| Unique customers | 96,096 |
| Orders | 99,441 |
| Order items | 112,650 |
| Order payments | 103,886 |
| Order reviews | 99,224 |
| Products | 32,951 |
| Sellers | 3,095 |
| Product categories translated | 73 |
| Geolocation zip prefixes | 19,015 |

## Date Coverage

| Metric | Value |
|---|---|
| First purchase | 2016-09-04 21:15:19 |
| Last purchase | 2018-10-17 17:30:18 |
| Active purchase months | 25 |

Orders by year:

| Year | Orders |
|---:|---:|
| 2016 | 329 |
| 2017 | 45,101 |
| 2018 | 54,011 |

## Orders

Most orders are delivered.

| Status | Orders | Percent |
|---|---:|---:|
| delivered | 96,478 | 97.02 |
| shipped | 1,107 | 1.11 |
| canceled | 625 | 0.63 |
| unavailable | 609 | 0.61 |
| invoiced | 314 | 0.32 |
| processing | 301 | 0.30 |
| created | 5 | 0.01 |
| approved | 2 | 0.00 |

Most orders contain one item:

| Items per order | Orders |
|---:|---:|
| 1 | 88,863 |
| 2 | 7,516 |
| 3 | 1,322 |
| 4 | 505 |
| 5 | 204 |
| 6 | 198 |

## Revenue and Payments

| Metric | Value |
|---|---:|
| Product revenue | 13,591,643.70 |
| Freight revenue | 2,251,909.54 |
| Gross item value | 15,843,553.24 |
| Average item price | 120.65 |
| Average item freight | 19.99 |
| Orders with items | 98,666 |
| Average order value | 160.58 |
| Minimum order value | 9.59 |
| Maximum order value | 13,664.08 |
| Total payment value | 16,008,872.12 |
| Average payment value | 154.10 |
| Average installments | 2.85 |

Payment method distribution:

| Payment type | Payment rows | Payment value | Percent of payment rows |
|---|---:|---:|---:|
| credit_card | 76,795 | 12,542,084.19 | 73.92 |
| boleto | 19,784 | 2,869,361.27 | 19.04 |
| voucher | 5,775 | 379,436.87 | 5.56 |
| debit_card | 1,529 | 217,989.79 | 1.47 |
| not_defined | 3 | 0.00 | 0.00 |

## Customers and Sellers

Most unique customers placed one order.

| Orders per unique customer | Unique customers |
|---:|---:|
| 1 | 93,099 |
| 2 | 2,745 |
| 3 | 203 |
| 4 | 30 |
| 5 | 8 |
| 6 | 6 |
| 7 | 3 |
| 9 | 1 |
| 17 | 1 |

Top customer states by orders:

| State | Orders |
|---|---:|
| SP | 41,746 |
| RJ | 12,852 |
| MG | 11,635 |
| RS | 5,466 |
| PR | 5,045 |
| SC | 3,637 |
| BA | 3,380 |
| DF | 2,140 |
| ES | 2,033 |
| GO | 2,020 |

Top seller states by seller count:

| State | Sellers |
|---|---:|
| SP | 1,849 |
| PR | 349 |
| MG | 244 |
| SC | 190 |
| RJ | 171 |
| RS | 129 |
| GO | 40 |
| DF | 30 |
| ES | 23 |
| BA | 19 |

## Products and Categories

| Metric | Value |
|---|---:|
| Products | 32,951 |
| Products with category | 32,341 |
| Products without category | 610 |
| Distinct product categories | 73 |

Top categories by items sold:

| Category | Items sold | Gross item value |
|---|---:|---:|
| bed_bath_table | 11,115 | 1,241,681.72 |
| health_beauty | 9,670 | 1,441,248.07 |
| sports_leisure | 8,641 | 1,156,656.48 |
| furniture_decor | 8,334 | 902,511.79 |
| computers_accessories | 7,827 | 1,059,272.40 |
| housewares | 6,964 | 778,397.77 |
| watches_gifts | 5,991 | 1,305,541.61 |
| telephony | 4,545 | 394,883.32 |
| garden_tools | 4,347 | 584,219.21 |
| auto | 4,235 | 685,384.32 |

## Reviews

| Metric | Value |
|---|---:|
| Reviews | 99,224 |
| Average review score | 4.09 |
| Reviews with title | 11,566 |
| Reviews with message | 40,968 |

Review score distribution:

| Score | Reviews | Percent |
|---:|---:|---:|
| 1 | 11,424 | 11.51 |
| 2 | 3,151 | 3.18 |
| 3 | 8,179 | 8.24 |
| 4 | 19,142 | 19.29 |
| 5 | 57,328 | 57.78 |

## Delivery

Delivered orders with customer delivery date:
96,470

| Metric | Value |
|---|---:|
| Average delivery days | 12.09 |
| Minimum delivery days | 0 |
| Maximum delivery days | 209 |
| Delivered on or before estimate | 88,644 |
| Delivered after estimate | 7,826 |
| Percent on or before estimate | 91.89 |

## EDA Takeaways

- The dataset is heavily concentrated in delivered orders, so delivery and customer satisfaction analysis should focus mainly on delivered orders while still treating non-delivered statuses separately.
- Credit card is the dominant payment method by both count and value.
- Most customers are one-time customers, which makes retention and repeat purchase analysis important in the business analysis phase.
- SP dominates both customer orders and seller count, so geography analysis should compare SP against the rest of Brazil rather than only ranking states.
- Review sentiment is generally positive, with 57.78% of reviews rated 5 stars.
- Delivery performance is strong against estimates overall, but late deliveries and the preserved chronology anomalies should be handled carefully in Phase 7.

## Next Step

Start Phase 7 by writing structured business analysis queries in `SQL/04_business_queries.sql`.
