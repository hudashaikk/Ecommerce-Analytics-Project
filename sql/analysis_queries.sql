-- =====================================================
-- E-COMMERCE SALES & CUSTOMER INSIGHTS ANALYTICS
-- SQL Analysis
-- =====================================================


-- =====================================================
-- 1. BASIC DATA EXPLORATION
-- =====================================================

-- View sample records
SELECT *
FROM sales
LIMIT 10;

-- Total number of records
SELECT COUNT(*) AS total_records
FROM sales;

-- Check available columns
PRAGMA table_info(sales);

-- Minimum and maximum order dates
SELECT
    MIN("Order Date") AS first_order_date,
    MAX("Order Date") AS last_order_date
FROM sales;

-- Total orders, customers, and products
SELECT
    COUNT(DISTINCT "Order ID") AS total_orders,
    COUNT(DISTINCT "Customer ID") AS total_customers,
    COUNT(DISTINCT "Product ID") AS total_products
FROM sales;
-- Sales by year
SELECT
    strftime('%Y', "Order Date") AS year,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY year
ORDER BY year;

-- Year-over-year sales growth
WITH yearly_sales AS (
    SELECT
        strftime('%Y', "Order Date") AS year,
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY year
)

SELECT
    year,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(LAG(total_sales) OVER (ORDER BY year), 2) AS previous_year_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY year))
        * 100.0
        / LAG(total_sales) OVER (ORDER BY year),
        2
    ) AS yoy_growth_pct
FROM yearly_sales
ORDER BY year;

-- Sales performance by category
SELECT
    "Category",
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(AVG(Sales), 2) AS average_sales,
    COUNT(*) AS number_of_records
FROM sales
GROUP BY "Category"
ORDER BY total_sales DESC;

-- Sales performance by sub-category
SELECT
    "Sub-Category",
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(AVG(Sales), 2) AS average_sales,
    COUNT(*) AS number_of_records
FROM sales
GROUP BY "Sub-Category"
ORDER BY total_sales DESC;

-- Top 10 products by total sales
SELECT
    "Product Name",
    ROUND(SUM(Sales), 2) AS total_sales,
    COUNT(*) AS number_of_records
FROM sales
GROUP BY "Product Name"
ORDER BY total_sales DESC
LIMIT 10;

-- Top 10 customers by total sales
SELECT
    "Customer ID",
    "Customer Name",
    ROUND(SUM(Sales), 2) AS total_sales,
    COUNT(DISTINCT "Order ID") AS total_orders
FROM sales
GROUP BY "Customer ID", "Customer Name"
ORDER BY total_sales DESC
LIMIT 10;

-- Sales performance by customer segment
SELECT
    "Segment",
    ROUND(SUM(Sales), 2) AS total_sales,
    COUNT(DISTINCT "Customer ID") AS total_customers,
    COUNT(DISTINCT "Order ID") AS total_orders,
    ROUND(AVG(Sales), 2) AS average_sales
FROM sales
GROUP BY "Segment"
ORDER BY total_sales DESC;

-- Sales performance by region
SELECT
    "Region",
    ROUND(SUM(Sales), 2) AS total_sales,
    COUNT(DISTINCT "Order ID") AS total_orders,
    COUNT(DISTINCT "Customer ID") AS total_customers,
    ROUND(AVG(Sales), 2) AS average_sales
FROM sales
GROUP BY "Region"
ORDER BY total_sales DESC;

-- Sales performance by state
SELECT
    "State",
    ROUND(SUM(Sales), 2) AS total_sales,
    COUNT(DISTINCT "Order ID") AS total_orders,
    COUNT(DISTINCT "Customer ID") AS total_customers
FROM sales
GROUP BY "State"
ORDER BY total_sales DESC;

-- Top 10 cities by sales
SELECT
    "City",
    "State",
    ROUND(SUM(Sales), 2) AS total_sales,
    COUNT(DISTINCT "Order ID") AS total_orders
FROM sales
GROUP BY "City", "State"
ORDER BY total_sales DESC
LIMIT 10;

-- Shipping mode performance
SELECT
    "Ship Mode",
    COUNT(DISTINCT "Order ID") AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(AVG("Shipping Days"), 2) AS average_shipping_days
FROM sales
GROUP BY "Ship Mode"
ORDER BY total_orders DESC;

-- Monthly sales trend
SELECT
    strftime('%Y-%m', "Order Date") AS year_month,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY year_month
ORDER BY year_month;

-- Average order value
SELECT
    ROUND(
        SUM(Sales) / COUNT(DISTINCT "Order ID"),
        2
    ) AS average_order_value
FROM sales;

-- Customers with more than one order
SELECT
    "Customer ID",
    "Customer Name",
    COUNT(DISTINCT "Order ID") AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY "Customer ID", "Customer Name"
HAVING COUNT(DISTINCT "Order ID") > 1
ORDER BY total_orders DESC;

-- Customers with the highest number of orders
SELECT
    "Customer ID",
    "Customer Name",
    COUNT(DISTINCT "Order ID") AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY "Customer ID", "Customer Name"
ORDER BY total_orders DESC
LIMIT 10;

-- Category contribution to total sales
SELECT
    "Category",
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(
        SUM(Sales) * 100.0 / (SELECT SUM(Sales) FROM sales),
        2
    ) AS sales_percentage
FROM sales
GROUP BY "Category"
ORDER BY total_sales DESC;

-- Rank products by total sales
WITH product_sales AS (
    SELECT
        "Product Name",
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY "Product Name"
)

SELECT
    "Product Name",
    ROUND(total_sales, 2) AS total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM product_sales
ORDER BY sales_rank
LIMIT 10;

-- Monthly sales pattern across years
SELECT
    strftime('%m', "Order Date") AS month_number,
    strftime('%m', "Order Date") AS month,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY month_number
ORDER BY month_number;

-- Category performance within each region
SELECT
    "Region",
    "Category",
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY "Region", "Category"
ORDER BY "Region", total_sales DESC;

-- Average shipping time by region
SELECT
    "Region",
    ROUND(AVG("Shipping Days"), 2) AS average_shipping_days,
    COUNT(DISTINCT "Order ID") AS total_orders
FROM sales
GROUP BY "Region"
ORDER BY average_shipping_days;

-- Top-selling product within each category
WITH product_category_sales AS (
    SELECT
        "Category",
        "Product Name",
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY "Category", "Product Name"
),

ranked_products AS (
    SELECT
        "Category",
        "Product Name",
        total_sales,
        RANK() OVER (
            PARTITION BY "Category"
            ORDER BY total_sales DESC
        ) AS product_rank
    FROM product_category_sales
)

SELECT
    "Category",
    "Product Name",
    ROUND(total_sales, 2) AS total_sales
FROM ranked_products
WHERE product_rank = 1
ORDER BY "Category";

-- Executive sales summary
SELECT
    ROUND(SUM(Sales), 2) AS total_sales,
    COUNT(DISTINCT "Order ID") AS total_orders,
    COUNT(DISTINCT "Customer ID") AS total_customers,
    COUNT(DISTINCT "Product ID") AS total_products,
    ROUND(
        SUM(Sales) / COUNT(DISTINCT "Order ID"),
        2
    ) AS average_order_value,
    ROUND(AVG("Shipping Days"), 2) AS average_shipping_days
FROM sales;


---1.  Basic Data Exploration
---2.  Total Records
---3.  Total Sales
---4.  Orders / Customers / Products
---5.  Yearly Sales
---6.  YoY Growth
---7.  Category Analysis
---8.  Sub-Category Analysis
---9.  Top Products
---10. Customer Analysis
---11. Segment Analysis
---12. Regional Analysis
---13. State Analysis
---14. City Analysis
---15. Shipping Analysis
---16. Monthly Trend
---17. Average Order Value
---18. Repeat Customers
---19. Top Customers by Orders
---20. Category Contribution
---21. Product Ranking
---22. Monthly Pattern
---23. Category × Region
---24. Shipping × Region
---25. Top Product by Category
---26. Executive Summary