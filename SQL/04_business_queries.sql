-- E-Commerce Sales Analytics Dashboard
-- Phase 7: Business Analysis
--
-- Goal: answer portfolio-ready business questions from the clean analytical
-- tables. Revenue uses order_items.price + order_items.freight_value, while
-- payment analysis uses order_payments.payment_value.

USE ecommerce_sales;

-- -----------------------------------------------------
-- 1. Revenue Analysis
-- -----------------------------------------------------

-- Q01. What are the headline revenue KPIs?
SELECT
    COUNT(DISTINCT oi.order_id) AS orders_with_items,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_item_value
FROM order_items oi;

-- Q02. What is monthly revenue, order volume, and average order value?
WITH order_values AS (
    SELECT
        o.order_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_id, DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT
    purchase_month,
    COUNT(*) AS orders,
    ROUND(SUM(order_value), 2) AS gross_item_value,
    ROUND(AVG(order_value), 2) AS avg_order_value
FROM order_values
GROUP BY purchase_month
ORDER BY purchase_month;

-- Q03. How is revenue trending month over month?
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        SUM(oi.price + oi.freight_value) AS gross_item_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT
    purchase_month,
    ROUND(gross_item_value, 2) AS gross_item_value,
    ROUND(LAG(gross_item_value) OVER (ORDER BY purchase_month), 2) AS previous_month_value,
    ROUND(
        (gross_item_value - LAG(gross_item_value) OVER (ORDER BY purchase_month))
        / NULLIF(LAG(gross_item_value) OVER (ORDER BY purchase_month), 0) * 100,
        2
    ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY purchase_month;

-- Q04. Which months generated the highest revenue?
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT
    purchase_month,
    orders,
    ROUND(gross_item_value, 2) AS gross_item_value
FROM monthly_revenue
ORDER BY gross_item_value DESC
LIMIT 10;

-- Q05. What is revenue by order status?
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY gross_item_value DESC;

-- Q06. What share of revenue comes from freight?
SELECT
    ROUND(SUM(price), 2) AS product_revenue,
    ROUND(SUM(freight_value), 2) AS freight_revenue,
    ROUND(SUM(freight_value) / NULLIF(SUM(price + freight_value), 0) * 100, 2) AS freight_share_pct
FROM order_items;

-- -----------------------------------------------------
-- 2. Customer Analysis
-- -----------------------------------------------------

-- Q07. Who are the top customers by lifetime gross item value?
WITH customer_values AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    orders,
    ROUND(gross_item_value, 2) AS lifetime_value,
    ROUND(gross_item_value / orders, 2) AS avg_order_value
FROM customer_values
ORDER BY lifetime_value DESC
LIMIT 20;

-- Q08. What percentage of customers purchase more than once?
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS unique_customers,
    SUM(orders > 1) AS repeat_customers,
    ROUND(SUM(orders > 1) * 100.0 / COUNT(*), 2) AS repeat_customer_pct,
    ROUND(AVG(orders), 2) AS avg_orders_per_customer
FROM customer_orders;

-- Q09. How much revenue comes from repeat customers versus one-time customers?
WITH customer_values AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE WHEN orders > 1 THEN 'repeat_customer' ELSE 'one_time_customer' END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(gross_item_value), 2) AS gross_item_value,
    ROUND(SUM(gross_item_value) * 100.0 / SUM(SUM(gross_item_value)) OVER (), 2) AS revenue_share_pct,
    ROUND(AVG(gross_item_value), 2) AS avg_customer_value
FROM customer_values
GROUP BY CASE WHEN orders > 1 THEN 'repeat_customer' ELSE 'one_time_customer' END
ORDER BY gross_item_value DESC;

-- Q10. Which customer states produce the most revenue?
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY gross_item_value DESC;

-- Q11. Which customer cities produce the most revenue?
SELECT
    c.customer_state,
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state, c.customer_city
ORDER BY gross_item_value DESC
LIMIT 25;

-- Q12. How long is the gap between repeat purchases?
WITH customer_order_dates AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS previous_purchase_timestamp
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
)
SELECT
    COUNT(*) AS repeat_purchase_events,
    ROUND(AVG(TIMESTAMPDIFF(DAY, previous_purchase_timestamp, order_purchase_timestamp)), 2) AS avg_days_between_purchases,
    MIN(TIMESTAMPDIFF(DAY, previous_purchase_timestamp, order_purchase_timestamp)) AS min_days_between_purchases,
    MAX(TIMESTAMPDIFF(DAY, previous_purchase_timestamp, order_purchase_timestamp)) AS max_days_between_purchases
FROM customer_order_dates
WHERE previous_purchase_timestamp IS NOT NULL;

-- Q13. How do first orders compare with later orders?
WITH ranked_customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_number
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
),
order_values AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT
    CASE WHEN r.order_number = 1 THEN 'first_order' ELSE 'later_order' END AS order_stage,
    COUNT(*) AS orders,
    ROUND(SUM(v.order_value), 2) AS gross_item_value,
    ROUND(AVG(v.order_value), 2) AS avg_order_value
FROM ranked_customer_orders r
INNER JOIN order_values v
    ON r.order_id = v.order_id
GROUP BY CASE WHEN r.order_number = 1 THEN 'first_order' ELSE 'later_order' END;

-- -----------------------------------------------------
-- 3. Product and Category Analysis
-- -----------------------------------------------------

-- Q14. Which categories generate the most revenue?
SELECT
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY COALESCE(t.product_category_name_english, 'unknown')
ORDER BY gross_item_value DESC
LIMIT 20;

-- Q15. Which categories have the highest average item price?
SELECT
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(*) AS items_sold,
    ROUND(AVG(oi.price), 2) AS avg_item_price,
    ROUND(SUM(oi.price), 2) AS product_revenue
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY COALESCE(t.product_category_name_english, 'unknown')
HAVING COUNT(*) >= 100
ORDER BY avg_item_price DESC
LIMIT 20;

-- Q16. Which products generate the most revenue?
SELECT
    oi.product_id,
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY oi.product_id, COALESCE(t.product_category_name_english, 'unknown')
ORDER BY gross_item_value DESC
LIMIT 25;

-- Q17. Which products sell the most units?
SELECT
    oi.product_id,
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY oi.product_id, COALESCE(t.product_category_name_english, 'unknown')
ORDER BY units_sold DESC, gross_item_value DESC
LIMIT 25;

-- Q18. Which categories are growing or declining month over month?
WITH category_monthly AS (
    SELECT
        COALESCE(t.product_category_name_english, 'unknown') AS category_name,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        SUM(oi.price + oi.freight_value) AS gross_item_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY
        COALESCE(t.product_category_name_english, 'unknown'),
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),
category_with_lag AS (
    SELECT
        category_name,
        purchase_month,
        gross_item_value,
        LAG(gross_item_value) OVER (
            PARTITION BY category_name
            ORDER BY purchase_month
        ) AS previous_month_value
    FROM category_monthly
)
SELECT
    category_name,
    purchase_month,
    ROUND(gross_item_value, 2) AS gross_item_value,
    ROUND(previous_month_value, 2) AS previous_month_value,
    ROUND((gross_item_value - previous_month_value) / NULLIF(previous_month_value, 0) * 100, 2) AS mom_growth_pct
FROM category_with_lag
WHERE previous_month_value IS NOT NULL
ORDER BY ABS((gross_item_value - previous_month_value) / NULLIF(previous_month_value, 0)) DESC
LIMIT 30;

-- Q19. Which categories have the strongest review scores?
SELECT
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(DISTINCT oi.order_id) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    SUM(r.review_score >= 4) AS positive_reviews,
    SUM(r.review_score <= 2) AS negative_reviews
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
INNER JOIN order_reviews r
    ON oi.order_id = r.order_id
GROUP BY COALESCE(t.product_category_name_english, 'unknown')
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY avg_review_score DESC, reviewed_orders DESC
LIMIT 20;

-- Q20. Which categories have weak satisfaction despite high revenue?
WITH category_metrics AS (
    SELECT
        COALESCE(t.product_category_name_english, 'unknown') AS category_name,
        COUNT(DISTINCT oi.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value,
        AVG(r.review_score) AS avg_review_score
    FROM order_items oi
    INNER JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    INNER JOIN order_reviews r
        ON oi.order_id = r.order_id
    GROUP BY COALESCE(t.product_category_name_english, 'unknown')
)
SELECT
    category_name,
    orders,
    ROUND(gross_item_value, 2) AS gross_item_value,
    ROUND(avg_review_score, 2) AS avg_review_score
FROM category_metrics
WHERE gross_item_value >= (
        SELECT AVG(gross_item_value)
        FROM category_metrics
    )
  AND avg_review_score < (
        SELECT AVG(avg_review_score)
        FROM category_metrics
    )
ORDER BY gross_item_value DESC;

-- -----------------------------------------------------
-- 4. Payment Analysis
-- -----------------------------------------------------

-- Q21. Which payment methods drive the most payment value?
SELECT
    payment_type,
    COUNT(*) AS payment_rows,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(SUM(payment_value) * 100.0 / SUM(SUM(payment_value)) OVER (), 2) AS payment_value_share_pct
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;

-- Q22. What is the average payment value by payment method?
SELECT
    payment_type,
    COUNT(*) AS payment_rows,
    ROUND(AVG(payment_value), 2) AS avg_payment_value,
    ROUND(MIN(payment_value), 2) AS min_payment_value,
    ROUND(MAX(payment_value), 2) AS max_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY avg_payment_value DESC;

-- Q23. How do installment counts affect payment value?
SELECT
    payment_installments,
    COUNT(*) AS payment_rows,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;

-- Q24. Which payment methods are most common by month?
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
    p.payment_type,
    COUNT(*) AS payment_rows,
    ROUND(SUM(p.payment_value), 2) AS payment_value
FROM orders o
INNER JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m'), p.payment_type
ORDER BY purchase_month, payment_value DESC;

-- Q25. Which orders used multiple payment rows?
SELECT
    order_id,
    COUNT(*) AS payment_rows,
    COUNT(DISTINCT payment_type) AS payment_types,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_rows DESC, total_payment_value DESC
LIMIT 25;

-- -----------------------------------------------------
-- 5. Delivery Analysis
-- -----------------------------------------------------

-- Q26. What are the core delivery KPIs for delivered orders?
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 2) AS avg_delivery_days,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_carrier_date)), 2) AS avg_days_to_carrier,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_delivered_carrier_date, order_delivered_customer_date)), 2) AS avg_carrier_to_customer_days,
    SUM(order_delivered_customer_date <= order_estimated_delivery_date) AS on_or_before_estimate,
    ROUND(SUM(order_delivered_customer_date <= order_estimated_delivery_date) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- Q27. Which customer states have the slowest average delivery?
SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)), 2) AS avg_delivery_days,
    ROUND(SUM(o.order_delivered_customer_date > o.order_estimated_delivery_date) * 100.0 / COUNT(*), 2) AS late_delivery_pct
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY avg_delivery_days DESC;

-- Q28. Which categories are most affected by late deliveries?
SELECT
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END) AS late_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END)
        * 100.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_pct
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY COALESCE(t.product_category_name_english, 'unknown')
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY late_delivery_pct DESC
LIMIT 20;

-- Q29. How does delivery performance affect review scores?
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'on_or_before_estimate'
        ELSE 'late'
    END AS delivery_performance,
    COUNT(DISTINCT o.order_id) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    SUM(r.review_score <= 2) AS low_score_reviews,
    ROUND(SUM(r.review_score <= 2) * 100.0 / COUNT(*), 2) AS low_score_review_pct
FROM orders o
INNER JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'on_or_before_estimate'
        ELSE 'late'
    END;

-- Q30. Which sellers have the highest late-delivery rate?
SELECT
    oi.seller_id,
    s.seller_state,
    s.seller_city,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END) AS late_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END)
        * 100.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_pct
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id, s.seller_state, s.seller_city
HAVING COUNT(DISTINCT o.order_id) >= 30
ORDER BY late_delivery_pct DESC, delivered_orders DESC
LIMIT 25;

-- Q31. How often do sellers miss their shipping limit?
SELECT
    oi.seller_id,
    s.seller_state,
    s.seller_city,
    COUNT(*) AS shipped_items,
    SUM(o.order_delivered_carrier_date > oi.shipping_limit_date) AS items_shipped_after_limit,
    ROUND(SUM(o.order_delivered_carrier_date > oi.shipping_limit_date) * 100.0 / COUNT(*), 2) AS late_ship_limit_pct
FROM order_items oi
INNER JOIN orders o
    ON oi.order_id = o.order_id
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE o.order_delivered_carrier_date IS NOT NULL
GROUP BY oi.seller_id, s.seller_state, s.seller_city
HAVING COUNT(*) >= 30
ORDER BY late_ship_limit_pct DESC, shipped_items DESC
LIMIT 25;

-- -----------------------------------------------------
-- 6. Geography Analysis
-- -----------------------------------------------------

-- Q32. Which customer-state and seller-state pairs generate the most revenue?
SELECT
    c.customer_state,
    s.seller_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.freight_value), 2) AS avg_item_freight
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY c.customer_state, s.seller_state
ORDER BY gross_item_value DESC
LIMIT 30;

-- Q33. How much revenue is local within the same state versus cross-state?
SELECT
    CASE
        WHEN c.customer_state = s.seller_state THEN 'same_state'
        ELSE 'cross_state'
    END AS fulfillment_scope,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.freight_value), 2) AS avg_item_freight,
    ROUND(AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)), 2) AS avg_delivery_days
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN c.customer_state = s.seller_state THEN 'same_state'
        ELSE 'cross_state'
    END;

-- Q34. Which states are most dependent on out-of-state sellers?
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN c.customer_state <> s.seller_state THEN o.order_id END) AS cross_state_orders,
    ROUND(COUNT(DISTINCT CASE WHEN c.customer_state <> s.seller_state THEN o.order_id END) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS cross_state_order_pct
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY cross_state_order_pct DESC;

-- Q35. Which customer states pay the highest freight share?
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(SUM(oi.freight_value) / NULLIF(SUM(oi.price + oi.freight_value), 0) * 100, 2) AS freight_share_pct
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY freight_share_pct DESC;

-- Q36. Which seller states generate the most revenue?
SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS sellers,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT s.seller_id), 2) AS revenue_per_seller
FROM sellers s
INNER JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY gross_item_value DESC;

-- -----------------------------------------------------
-- 7. Seller Analysis
-- -----------------------------------------------------

-- Q37. Who are the top sellers by revenue?
SELECT
    oi.seller_id,
    s.seller_state,
    s.seller_city,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_state, s.seller_city
ORDER BY gross_item_value DESC
LIMIT 25;

-- Q38. How concentrated is seller revenue?
WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price + freight_value) AS gross_item_value
    FROM order_items
    GROUP BY seller_id
),
seller_ranked AS (
    SELECT
        seller_id,
        gross_item_value,
        NTILE(10) OVER (ORDER BY gross_item_value DESC) AS revenue_decile
    FROM seller_revenue
)
SELECT
    revenue_decile,
    COUNT(*) AS sellers,
    ROUND(SUM(gross_item_value), 2) AS gross_item_value,
    ROUND(SUM(gross_item_value) * 100.0 / SUM(SUM(gross_item_value)) OVER (), 2) AS revenue_share_pct
FROM seller_ranked
GROUP BY revenue_decile
ORDER BY revenue_decile;

-- Q39. Which sellers have strong revenue and strong reviews?
WITH seller_metrics AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value,
        AVG(r.review_score) AS avg_review_score
    FROM order_items oi
    INNER JOIN order_reviews r
        ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
)
SELECT
    seller_id,
    orders,
    ROUND(gross_item_value, 2) AS gross_item_value,
    ROUND(avg_review_score, 2) AS avg_review_score
FROM seller_metrics
WHERE orders >= 50
ORDER BY avg_review_score DESC, gross_item_value DESC
LIMIT 25;

-- Q40. Which sellers have high revenue but weak reviews?
WITH seller_metrics AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value,
        AVG(r.review_score) AS avg_review_score
    FROM order_items oi
    INNER JOIN order_reviews r
        ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
)
SELECT
    seller_id,
    orders,
    ROUND(gross_item_value, 2) AS gross_item_value,
    ROUND(avg_review_score, 2) AS avg_review_score
FROM seller_metrics
WHERE orders >= 50
  AND avg_review_score < 4
ORDER BY gross_item_value DESC
LIMIT 25;

-- Q41. Which sellers sell across the widest customer geography?
SELECT
    oi.seller_id,
    s.seller_state,
    s.seller_city,
    COUNT(DISTINCT c.customer_state) AS customer_states_served,
    COUNT(DISTINCT c.customer_city) AS customer_cities_served,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value
FROM order_items oi
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY oi.seller_id, s.seller_state, s.seller_city
ORDER BY customer_states_served DESC, customer_cities_served DESC, gross_item_value DESC
LIMIT 25;

-- Q42. Which sellers rely on a single category?
WITH seller_category_revenue AS (
    SELECT
        oi.seller_id,
        COALESCE(t.product_category_name_english, 'unknown') AS category_name,
        SUM(oi.price + oi.freight_value) AS category_revenue
    FROM order_items oi
    INNER JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY oi.seller_id, COALESCE(t.product_category_name_english, 'unknown')
),
seller_totals AS (
    SELECT
        seller_id,
        SUM(category_revenue) AS seller_revenue
    FROM seller_category_revenue
    GROUP BY seller_id
),
seller_top_category AS (
    SELECT
        r.seller_id,
        r.category_name,
        r.category_revenue,
        t.seller_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY r.seller_id
            ORDER BY r.category_revenue DESC
        ) AS category_rank
    FROM seller_category_revenue r
    INNER JOIN seller_totals t
        ON r.seller_id = t.seller_id
)
SELECT
    seller_id,
    category_name AS top_category,
    ROUND(category_revenue, 2) AS top_category_revenue,
    ROUND(seller_revenue, 2) AS seller_revenue,
    ROUND(category_revenue / NULLIF(seller_revenue, 0) * 100, 2) AS top_category_revenue_pct
FROM seller_top_category
WHERE category_rank = 1
  AND seller_revenue >= 1000
ORDER BY top_category_revenue_pct DESC, seller_revenue DESC
LIMIT 25;

-- -----------------------------------------------------
-- 8. Review and Satisfaction Analysis
-- -----------------------------------------------------

-- Q43. What is the review distribution by month?
SELECT
    DATE_FORMAT(review_creation_date, '%Y-%m') AS review_month,
    COUNT(*) AS reviews,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    SUM(review_score = 5) AS five_star_reviews,
    SUM(review_score <= 2) AS low_score_reviews
FROM order_reviews
GROUP BY DATE_FORMAT(review_creation_date, '%Y-%m')
ORDER BY review_month;

-- Q44. How does order value relate to review score?
WITH order_values AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT
    r.review_score,
    COUNT(DISTINCT r.order_id) AS reviewed_orders,
    ROUND(AVG(v.order_value), 2) AS avg_order_value,
    ROUND(SUM(v.order_value), 2) AS gross_item_value
FROM order_reviews r
INNER JOIN order_values v
    ON r.order_id = v.order_id
GROUP BY r.review_score
ORDER BY r.review_score;

-- Q45. Are written comments more common on low or high reviews?
SELECT
    review_score,
    COUNT(*) AS reviews,
    SUM(review_comment_message IS NOT NULL) AS reviews_with_message,
    ROUND(SUM(review_comment_message IS NOT NULL) * 100.0 / COUNT(*), 2) AS pct_with_message
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- Q46. Which categories receive the most low-score reviews?
SELECT
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(*) AS reviews,
    SUM(r.review_score <= 2) AS low_score_reviews,
    ROUND(SUM(r.review_score <= 2) * 100.0 / COUNT(*), 2) AS low_score_review_pct,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews r
INNER JOIN order_items oi
    ON r.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY COALESCE(t.product_category_name_english, 'unknown')
HAVING COUNT(*) >= 100
ORDER BY low_score_review_pct DESC, reviews DESC
LIMIT 20;

-- -----------------------------------------------------
-- 9. Executive Dashboard Support Queries
-- -----------------------------------------------------

-- Q47. What are monthly executive KPIs in one table?
WITH order_values AS (
    SELECT
        o.order_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_id, DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),
monthly_reviews AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        AVG(r.review_score) AS avg_review_score
    FROM orders o
    INNER JOIN order_reviews r
        ON o.order_id = r.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),
monthly_delivery AS (
    SELECT
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
        AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS avg_delivery_days,
        SUM(order_delivered_customer_date <= order_estimated_delivery_date) * 100.0 / COUNT(*) AS on_time_pct
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
)
SELECT
    v.purchase_month,
    COUNT(*) AS orders,
    ROUND(SUM(v.order_value), 2) AS gross_item_value,
    ROUND(AVG(v.order_value), 2) AS avg_order_value,
    ROUND(r.avg_review_score, 2) AS avg_review_score,
    ROUND(d.avg_delivery_days, 2) AS avg_delivery_days,
    ROUND(d.on_time_pct, 2) AS on_time_pct
FROM order_values v
LEFT JOIN monthly_reviews r
    ON v.purchase_month = r.purchase_month
LEFT JOIN monthly_delivery d
    ON v.purchase_month = d.purchase_month
GROUP BY
    v.purchase_month,
    r.avg_review_score,
    d.avg_delivery_days,
    d.on_time_pct
ORDER BY v.purchase_month;

-- Q48. Which categories should be prioritized for dashboard monitoring?
WITH category_metrics AS (
    SELECT
        COALESCE(t.product_category_name_english, 'unknown') AS category_name,
        COUNT(DISTINCT oi.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value,
        AVG(r.review_score) AS avg_review_score
    FROM order_items oi
    INNER JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    LEFT JOIN order_reviews r
        ON oi.order_id = r.order_id
    GROUP BY COALESCE(t.product_category_name_english, 'unknown')
)
SELECT
    category_name,
    orders,
    ROUND(gross_item_value, 2) AS gross_item_value,
    ROUND(avg_review_score, 2) AS avg_review_score,
    RANK() OVER (ORDER BY gross_item_value DESC) AS revenue_rank,
    RANK() OVER (ORDER BY avg_review_score ASC) AS satisfaction_risk_rank
FROM category_metrics
WHERE orders >= 100
ORDER BY revenue_rank
LIMIT 20;

-- Q49. Which markets combine high revenue with slow delivery?
WITH state_metrics AS (
    SELECT
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value,
        AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY c.customer_state
)
SELECT
    customer_state,
    orders,
    ROUND(gross_item_value, 2) AS gross_item_value,
    ROUND(avg_delivery_days, 2) AS avg_delivery_days
FROM state_metrics
WHERE gross_item_value >= (
        SELECT AVG(gross_item_value)
        FROM state_metrics
    )
  AND avg_delivery_days >= (
        SELECT AVG(avg_delivery_days)
        FROM state_metrics
    )
ORDER BY gross_item_value DESC;

-- Q50. Which seller and category combinations deserve account-management attention?
WITH seller_category_metrics AS (
    SELECT
        oi.seller_id,
        COALESCE(t.product_category_name_english, 'unknown') AS category_name,
        COUNT(DISTINCT oi.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value,
        AVG(r.review_score) AS avg_review_score,
        COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END) * 100.0
            / NULLIF(COUNT(DISTINCT o.order_id), 0) AS late_delivery_pct
    FROM order_items oi
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    LEFT JOIN order_reviews r
        ON oi.order_id = r.order_id
    GROUP BY oi.seller_id, COALESCE(t.product_category_name_english, 'unknown')
)
SELECT
    seller_id,
    category_name,
    orders,
    ROUND(gross_item_value, 2) AS gross_item_value,
    ROUND(avg_review_score, 2) AS avg_review_score,
    ROUND(late_delivery_pct, 2) AS late_delivery_pct
FROM seller_category_metrics
WHERE orders >= 20
  AND (avg_review_score < 4 OR late_delivery_pct > 15)
ORDER BY gross_item_value DESC
LIMIT 30;
