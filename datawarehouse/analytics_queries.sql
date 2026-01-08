
-- OLAP Analytics Queries for FlexiMart Data Warehouse
-- analytics_queries.sql

-- Query 1: Monthly Sales Drill-Down Analysis
-- Business Scenario: The CEO wants to see sales performance broken down by time periods. 
-- Start with yearly total, then quarterly, then monthly sales for 2024.
-- Demonstrates: Drill-down from Year → Quarter → Month

SELECT 
    d.year,
    d.quarter,
    d.month_name,
    COUNT(DISTINCT f.sale_key) AS total_transactions,
    SUM(f.quantity_sold) AS total_quantity,
    SUM(f.total_amount) AS total_sales,
    ROUND(AVG(f.total_amount), 2) AS avg_transaction_value
FROM 
    fact_sales f
    INNER JOIN dim_date d ON f.date_key = d.date_key
WHERE 
    d.year = 2024
GROUP BY 
    d.year, d.quarter, d.month, d.month_name
ORDER BY 
    d.year, d.month;


-- Query 2: Product Performance Analysis
-- Business Scenario: The product manager needs to identify top-performing products. 
-- Show the top 10 products by revenue, along with their category, total units sold, 
-- and revenue contribution percentage.
-- Includes: Revenue percentage calculation

WITH product_revenue AS (
    SELECT 
        p.product_name,
        p.category,
        p.subcategory,
        SUM(f.quantity_sold) AS units_sold,
        SUM(f.total_amount) AS revenue,
        SUM(f.discount_amount) AS total_discounts
    FROM 
        fact_sales f
        INNER JOIN dim_product p ON f.product_key = p.product_key
    GROUP BY 
        p.product_key, p.product_name, p.category, p.subcategory
),
total_revenue AS (
    SELECT SUM(revenue) AS overall_revenue
    FROM product_revenue
)
SELECT 
    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.units_sold,
    ROUND(pr.revenue, 2) AS revenue,
    ROUND(pr.total_discounts, 2) AS total_discounts,
    CONCAT(ROUND((pr.revenue / tr.overall_revenue * 100), 2), '%') AS revenue_percentage,
    ROUND(pr.revenue / pr.units_sold, 2) AS avg_revenue_per_unit
FROM 
    product_revenue pr
    CROSS JOIN total_revenue tr
ORDER BY 
    pr.revenue DESC
LIMIT 10;


-- Query 3: Customer Segmentation Analysis
-- Business Scenario: Marketing wants to target high-value customers. Segment customers 
-- into 'High Value' (>₹50,000 spent), 'Medium Value' (₹20,000-₹50,000), and 
-- 'Low Value' (<₹20,000). Show count of customers and total revenue in each segment.
-- Segments: High/Medium/Low value customers

WITH customer_spending AS (
    SELECT 
        c.customer_key,
        c.customer_name,
        c.city,
        c.state,
        SUM(f.total_amount) AS total_spent,
        COUNT(DISTINCT f.sale_key) AS purchase_count,
        AVG(f.total_amount) AS avg_transaction_value
    FROM 
        fact_sales f
        INNER JOIN dim_customer c ON f.customer_key = c.customer_key
    GROUP BY 
        c.customer_key, c.customer_name, c.city, c.state
),
segmented_customers AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent > 50000 THEN 'High Value'
            WHEN total_spent BETWEEN 20000 AND 50000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_spending
)
SELECT 
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spent), 2) AS total_revenue,
    ROUND(AVG(total_spent), 2) AS avg_revenue_per_customer,
    ROUND(AVG(purchase_count), 1) AS avg_purchases_per_customer,
    ROUND(AVG(avg_transaction_value), 2) AS avg_transaction_value
FROM 
    segmented_customers
GROUP BY 
    customer_segment
ORDER BY 
    FIELD(customer_segment, 'High Value', 'Medium Value', 'Low Value');


-- Additional Bonus Query: Weekend vs Weekday Sales Analysis
-- Shows sales patterns by day type to optimize inventory and staffing

SELECT 
    CASE 
        WHEN d.is_weekend = TRUE THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT f.sale_key) AS total_transactions,
    SUM(f.quantity_sold) AS total_units_sold,
    ROUND(SUM(f.total_amount), 2) AS total_revenue,
    ROUND(AVG(f.total_amount), 2) AS avg_transaction_value,
    ROUND(SUM(f.discount_amount), 2) AS total_discounts
FROM 
    fact_sales f
    INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY 
    d.is_weekend
ORDER BY 
    day_type;


-- Additional Bonus Query: Category Performance by City
-- Geographic analysis of product category preferences

SELECT 
    c.city,
    p.category,
    COUNT(DISTINCT f.sale_key) AS transactions,
    SUM(f.quantity_sold) AS units_sold,
    ROUND(SUM(f.total_amount), 2) AS revenue,
    ROUND(AVG(f.total_amount), 2) AS avg_transaction_value
FROM 
    fact_sales f
    INNER JOIN dim_customer c ON f.customer_key = c.customer_key
    INNER JOIN dim_product p ON f.product_key = p.product_key
GROUP BY 
    c.city, p.category
ORDER BY 
    c.city, revenue DESC;

