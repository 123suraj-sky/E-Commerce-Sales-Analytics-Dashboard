-- E-Commerce Sales Analytics Dashboard
-- Phase 8: Power BI reporting views
--
-- These views provide a stable semantic layer for Power BI. They keep the
-- dashboard focused on reporting fields instead of long ad hoc SQL queries.

USE ecommerce_sales;

-- -----------------------------------------------------
-- Reset reporting views
-- -----------------------------------------------------

DROP VIEW IF EXISTS vw_powerbi_seller_category_risk;
DROP VIEW IF EXISTS vw_powerbi_payment_methods;
DROP VIEW IF EXISTS vw_powerbi_delivery_performance;
DROP VIEW IF EXISTS vw_powerbi_seller_performance;
DROP VIEW IF EXISTS vw_powerbi_customer_markets;
DROP VIEW IF EXISTS vw_powerbi_category_performance;
DROP VIEW IF EXISTS vw_powerbi_monthly_kpis;
DROP VIEW IF EXISTS vw_powerbi_dashboard_kpis;
DROP VIEW IF EXISTS vw_powerbi_order_items_enriched;

-- -----------------------------------------------------
-- 1. Enriched item-level fact view
-- -----------------------------------------------------
-- Primary Power BI fact table. One row per order item.

CREATE VIEW vw_powerbi_order_items_enriched AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_status,
    DATE(o.order_purchase_timestamp) AS purchase_date,
    YEAR(o.order_purchase_timestamp) AS purchase_year,
    QUARTER(o.order_purchase_timestamp) AS purchase_quarter,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
    DAYNAME(o.order_purchase_timestamp) AS purchase_day_name,
    c.customer_state,
    c.customer_city,
    s.seller_state,
    s.seller_city,
    CASE
        WHEN c.customer_state = s.seller_state THEN 'same_state'
        ELSE 'cross_state'
    END AS fulfillment_scope,
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    oi.price AS product_revenue,
    oi.freight_value AS freight_revenue,
    oi.price + oi.freight_value AS gross_item_value,
    oi.shipping_limit_date,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days,
    TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_carrier_date) AS days_to_carrier,
    TIMESTAMPDIFF(DAY, o.order_delivered_carrier_date, o.order_delivered_customer_date) AS carrier_to_customer_days,
    CASE
        WHEN o.order_status = 'delivered'
             AND o.order_delivered_customer_date IS NOT NULL
             AND o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_on_time_delivery,
    CASE
        WHEN o.order_status = 'delivered'
             AND o.order_delivered_customer_date IS NOT NULL
             AND o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_late_delivery,
    CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
             AND o.order_delivered_carrier_date > oi.shipping_limit_date THEN 1
        ELSE 0
    END AS is_late_shipping_limit,
    rs.review_count,
    rs.avg_review_score,
    rs.low_score_review_count,
    ps.payment_count,
    ps.payment_type_count,
    ps.total_payment_value
FROM order_items oi
INNER JOIN orders o
    ON oi.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN (
    SELECT
        order_id,
        COUNT(*) AS review_count,
        AVG(review_score) AS avg_review_score,
        SUM(review_score <= 2) AS low_score_review_count
    FROM order_reviews
    GROUP BY order_id
) rs
    ON oi.order_id = rs.order_id
LEFT JOIN (
    SELECT
        order_id,
        COUNT(*) AS payment_count,
        COUNT(DISTINCT payment_type) AS payment_type_count,
        SUM(payment_value) AS total_payment_value
    FROM order_payments
    GROUP BY order_id
) ps
    ON oi.order_id = ps.order_id;

-- -----------------------------------------------------
-- 2. Executive KPI views
-- -----------------------------------------------------

CREATE VIEW vw_powerbi_dashboard_kpis AS
SELECT
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT oi.order_id), 2) AS avg_order_value,
    ROUND(SUM(oi.freight_value) / NULLIF(SUM(oi.price + oi.freight_value), 0) * 100, 2) AS freight_share_pct,
    (
        SELECT COUNT(DISTINCT customer_unique_id)
        FROM customers
    ) AS unique_customers,
    (
        SELECT ROUND(SUM(order_count > 1) * 100.0 / COUNT(*), 2)
        FROM (
            SELECT
                customer_unique_id,
                COUNT(*) AS order_count
            FROM customers
            GROUP BY customer_unique_id
        ) customer_order_counts
    ) AS repeat_customer_pct,
    (
        SELECT ROUND(AVG(review_score), 2)
        FROM order_reviews
    ) AS avg_review_score
FROM order_items oi
INNER JOIN orders o
    ON oi.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id;

CREATE VIEW vw_powerbi_monthly_kpis AS
SELECT
    ov.purchase_month,
    ov.purchase_year,
    ov.purchase_month_number,
    ov.orders,
    ROUND(ov.gross_item_value, 2) AS gross_item_value,
    ROUND(ov.gross_item_value / NULLIF(ov.orders, 0), 2) AS avg_order_value,
    ROUND(ov.freight_revenue, 2) AS freight_revenue,
    ROUND(ov.freight_revenue / NULLIF(ov.gross_item_value, 0) * 100, 2) AS freight_share_pct,
    ROUND(mr.avg_review_score, 2) AS avg_review_score,
    ROUND(md.avg_delivery_days, 2) AS avg_delivery_days,
    ROUND(md.on_time_pct, 2) AS on_time_pct,
    ROUND(
        (ov.gross_item_value - LAG(ov.gross_item_value) OVER (ORDER BY ov.purchase_month))
        / NULLIF(LAG(ov.gross_item_value) OVER (ORDER BY ov.purchase_month), 0) * 100,
        2
    ) AS mom_growth_pct
FROM (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        YEAR(o.order_purchase_timestamp) AS purchase_year,
        MONTH(o.order_purchase_timestamp) AS purchase_month_number,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price + oi.freight_value) AS gross_item_value,
        SUM(oi.freight_value) AS freight_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m'),
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
) ov
LEFT JOIN (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        AVG(r.review_score) AS avg_review_score
    FROM orders o
    INNER JOIN order_reviews r
        ON o.order_id = r.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
) mr
    ON ov.purchase_month = mr.purchase_month
LEFT JOIN (
    SELECT
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
        AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS avg_delivery_days,
        SUM(order_delivered_customer_date <= order_estimated_delivery_date) * 100.0 / COUNT(*) AS on_time_pct
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
) md
    ON ov.purchase_month = md.purchase_month;

-- -----------------------------------------------------
-- 3. Power BI page support views
-- -----------------------------------------------------

CREATE VIEW vw_powerbi_category_performance AS
SELECT
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.price), 2) AS avg_item_price,
    ROUND(AVG(rs.avg_review_score), 2) AS avg_review_score,
    SUM(COALESCE(rs.low_score_review_count, 0)) AS low_score_reviews,
    RANK() OVER (ORDER BY SUM(oi.price + oi.freight_value) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY AVG(rs.avg_review_score) ASC) AS satisfaction_risk_rank
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score,
        SUM(review_score <= 2) AS low_score_review_count
    FROM order_reviews
    GROUP BY order_id
) rs
    ON oi.order_id = rs.order_id
GROUP BY COALESCE(t.product_category_name_english, 'unknown');

CREATE VIEW vw_powerbi_customer_markets AS
SELECT
    c.customer_state,
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.freight_value) / NULLIF(SUM(oi.price + oi.freight_value), 0) * 100, 2) AS freight_share_pct
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state, c.customer_city;

CREATE VIEW vw_powerbi_seller_performance AS
SELECT
    oi.seller_id,
    s.seller_state,
    s.seller_city,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(DISTINCT c.customer_state) AS customer_states_served,
    COUNT(DISTINCT c.customer_city) AS customer_cities_served,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.price), 2) AS avg_item_price,
    ROUND(AVG(rs.avg_review_score), 2) AS avg_review_score,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END)
        * 100.0 / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS late_delivery_pct
FROM order_items oi
INNER JOIN sellers s
    ON oi.seller_id = s.seller_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM order_reviews
    GROUP BY order_id
) rs
    ON oi.order_id = rs.order_id
GROUP BY oi.seller_id, s.seller_state, s.seller_city;

CREATE VIEW vw_powerbi_delivery_performance AS
SELECT
    c.customer_state,
    s.seller_state,
    CASE
        WHEN c.customer_state = s.seller_state THEN 'same_state'
        ELSE 'cross_state'
    END AS fulfillment_scope,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(oi.freight_value), 2) AS avg_item_freight,
    ROUND(AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)), 2) AS avg_delivery_days,
    COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END) AS late_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END)
        * 100.0 / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS late_delivery_pct
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
    c.customer_state,
    s.seller_state,
    CASE
        WHEN c.customer_state = s.seller_state THEN 'same_state'
        ELSE 'cross_state'
    END;

CREATE VIEW vw_powerbi_payment_methods AS
SELECT
    p.payment_type,
    COUNT(*) AS payment_rows,
    COUNT(DISTINCT p.order_id) AS orders,
    ROUND(SUM(p.payment_value), 2) AS payment_value,
    ROUND(AVG(p.payment_value), 2) AS avg_payment_value,
    ROUND(SUM(p.payment_value) * 100.0 / SUM(SUM(p.payment_value)) OVER (), 2) AS payment_value_share_pct,
    ROUND(AVG(p.payment_installments), 2) AS avg_installments
FROM order_payments p
GROUP BY p.payment_type;

CREATE VIEW vw_powerbi_seller_category_risk AS
SELECT
    oi.seller_id,
    COALESCE(t.product_category_name_english, 'unknown') AS category_name,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_item_value,
    ROUND(AVG(rs.avg_review_score), 2) AS avg_review_score,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id END)
        * 100.0 / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS late_delivery_pct
FROM order_items oi
INNER JOIN orders o
    ON oi.order_id = o.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM order_reviews
    GROUP BY order_id
) rs
    ON oi.order_id = rs.order_id
GROUP BY oi.seller_id, COALESCE(t.product_category_name_english, 'unknown');
