-- =========================================================
-- SMART RETAIL DATABASE PROJECT
-- SQL Developer & Business Analysis Project
-- Developed By: Sneh Parekh
-- =========================================================


-- =========================================================
-- SECTION 1: DATABASE CREATION
-- =========================================================

CREATE DATABASE smart_retail_db;

USE smart_retail_db;


-- =========================================================
-- SECTION 2: TABLE CREATION
-- =========================================================

-- ---------------------------------------------------------
-- TABLE: CUSTOMERS
-- Stores customer information
-- ---------------------------------------------------------

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    signup_date DATE
);

-- ---------------------------------------------------------
-- TABLE: PRODUCTS
-- Stores product details and inventory information
-- ---------------------------------------------------------

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

-- ---------------------------------------------------------
-- TABLE: ORDERS
-- Stores order-level information
-- ---------------------------------------------------------

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    payment_method VARCHAR(50),
    order_status VARCHAR(50)
);

-- ---------------------------------------------------------
-- TABLE: ORDER_ITEMS
-- Stores product-level details for each order
-- ---------------------------------------------------------

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    sales_amount DECIMAL(10,2)
);


-- =========================================================
-- SECTION 3: FOREIGN KEY RELATIONSHIPS
-- =========================================================

-- ---------------------------------------------------------
-- RELATIONSHIP: ORDERS -> CUSTOMERS
-- One customer can place many orders
-- ---------------------------------------------------------

ALTER TABLE orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- ---------------------------------------------------------
-- RELATIONSHIP: ORDER_ITEMS -> ORDERS
-- One order can contain many products
-- ---------------------------------------------------------

ALTER TABLE order_items
ADD CONSTRAINT fk_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- ---------------------------------------------------------
-- RELATIONSHIP: ORDER_ITEMS -> PRODUCTS
-- Links products with order items
-- ---------------------------------------------------------

ALTER TABLE order_items
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);


-- =========================================================
-- SECTION 4: VERIFY TABLE STRUCTURE
-- =========================================================

SHOW CREATE TABLE orders;

SHOW CREATE TABLE order_items;


-- =========================================================
-- SECTION 5: DATA VALIDATION
-- Check imported data
-- =========================================================

SELECT * FROM customers;

SELECT * FROM products;

SELECT * FROM orders;

SELECT * FROM order_items;

-- ---------------------------------------------------------
-- Preview first 10 rows from order_items
-- ---------------------------------------------------------

SELECT * 
FROM order_items
LIMIT 10;

-- ---------------------------------------------------------
-- Count total rows in order_items
-- ---------------------------------------------------------

SELECT COUNT(*) AS total_order_items
FROM order_items;


-- =========================================================
-- SECTION 6: BASIC SQL QUERIES
-- =========================================================

-- ---------------------------------------------------------
-- Display customer names and cities
-- ---------------------------------------------------------

SELECT customer_name,
       city
FROM customers;

-- ---------------------------------------------------------
-- Customers from Ahmedabad
-- ---------------------------------------------------------

SELECT *
FROM customers
WHERE city = 'Ahmedabad';

-- ---------------------------------------------------------
-- Products sorted by price
-- ---------------------------------------------------------

SELECT *
FROM products
ORDER BY price ASC;

-- ---------------------------------------------------------
-- Top 5 cheapest products
-- ---------------------------------------------------------

SELECT *
FROM products
LIMIT 5;

-- ---------------------------------------------------------
-- Mobile category products
-- ---------------------------------------------------------

SELECT product_name,
       price
FROM products
WHERE category = 'Mobile'
ORDER BY price ASC
LIMIT 5;


-- =========================================================
-- SECTION 7: AGGREGATE FUNCTIONS
-- =========================================================

-- ---------------------------------------------------------
-- Total customers
-- ---------------------------------------------------------

SELECT COUNT(*) AS total_customers
FROM customers;

-- ---------------------------------------------------------
-- Total revenue generated
-- ---------------------------------------------------------

SELECT SUM(sales_amount) AS total_revenue
FROM order_items;

-- ---------------------------------------------------------
-- Average product price
-- ---------------------------------------------------------

SELECT AVG(price) AS average_product_price
FROM products;

-- ---------------------------------------------------------
-- Highest priced product
-- ---------------------------------------------------------

SELECT MAX(price) AS highest_price
FROM products;

-- ---------------------------------------------------------
-- Lowest priced product
-- ---------------------------------------------------------

SELECT MIN(price) AS lowest_price
FROM products;


-- =========================================================
-- SECTION 8: GROUP BY & HAVING
-- =========================================================

-- ---------------------------------------------------------
-- Count products by category
-- ---------------------------------------------------------

SELECT category,
       COUNT(*) AS total_products
FROM products
GROUP BY category;

-- ---------------------------------------------------------
-- Total sales by product
-- ---------------------------------------------------------

SELECT product_id,
       SUM(sales_amount) AS total_sales
FROM order_items
GROUP BY product_id;

-- ---------------------------------------------------------
-- Categories having more than 5 products
-- ---------------------------------------------------------

SELECT category,
       COUNT(*) AS total_products
FROM products
GROUP BY category
HAVING COUNT(*) > 5;


-- =========================================================
-- SECTION 9: SQL JOINS
-- =========================================================

-- ---------------------------------------------------------
-- INNER JOIN: Customers and Orders
-- ---------------------------------------------------------

SELECT c.customer_name,
       o.order_id,
       o.order_date
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id;

-- ---------------------------------------------------------
-- MULTI-TABLE JOIN
-- Customers + Orders + Order Items
-- ---------------------------------------------------------

SELECT c.customer_name,
       o.order_id,
       oi.product_id,
       oi.quantity
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id;

-- ---------------------------------------------------------
-- FULL SALES ANALYSIS JOIN
-- ---------------------------------------------------------

SELECT c.customer_name,
       p.product_name,
       oi.quantity,
       oi.sales_amount
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id;

-- ---------------------------------------------------------
-- LEFT JOIN: Find customers with no orders
-- ---------------------------------------------------------

SELECT c.customer_name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- =========================================================
-- SECTION 10: CASE WHEN STATEMENTS
-- =========================================================

-- ---------------------------------------------------------
-- Product price categorization
-- ---------------------------------------------------------

SELECT product_name,
       price,
       CASE
           WHEN price >= 70000 THEN 'Premium'
           WHEN price >= 30000 THEN 'Mid-Range'
           ELSE 'Budget'
       END AS price_category
FROM products
ORDER BY price DESC;

-- ---------------------------------------------------------
-- High value order classification
-- ---------------------------------------------------------

SELECT order_id,
       sales_amount,
       CASE
           WHEN sales_amount >= 100000 THEN 'High Value'
           WHEN sales_amount >= 30000 THEN 'Medium Value'
           ELSE 'Normal'
       END AS order_type
FROM order_items;


-- =========================================================
-- SECTION 11: SUBQUERIES
-- =========================================================

-- ---------------------------------------------------------
-- Products above average price
-- ---------------------------------------------------------

SELECT product_name, price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);

-- ---------------------------------------------------------
-- Customer with maximum orders
-- ---------------------------------------------------------

SELECT customer_id,
       COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) = (
    SELECT MAX(order_count)
    FROM (
        SELECT customer_id,
               COUNT(*) AS order_count
        FROM orders
        GROUP BY customer_id
    ) AS temp_table
);


-- =========================================================
-- SECTION 12: CTE (COMMON TABLE EXPRESSIONS)
-- =========================================================

-- ---------------------------------------------------------
-- High revenue customers
-- ---------------------------------------------------------

WITH customer_revenue AS (
    SELECT c.customer_name,
           SUM(oi.sales_amount) AS total_revenue
    FROM customers c
    INNER JOIN orders o
    ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
    ON o.order_id = oi.order_id
    GROUP BY c.customer_name
)

SELECT *
FROM customer_revenue
WHERE total_revenue > 300000
ORDER BY total_revenue ASC;


-- =========================================================
-- SECTION 13: WINDOW FUNCTIONS
-- =========================================================

-- ---------------------------------------------------------
-- Product price ranking
-- ---------------------------------------------------------

SELECT product_name,
       price,
       RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;

-- ---------------------------------------------------------
-- Running total revenue
-- ---------------------------------------------------------

SELECT order_id,
       sales_amount,
       SUM(sales_amount) OVER (
           ORDER BY order_id
       ) AS running_total
FROM order_items;


-- =========================================================
-- SECTION 14: REAL BUSINESS ANALYSIS
-- =========================================================

-- ---------------------------------------------------------
-- TASK 1: TOP CUSTOMERS BY REVENUE
-- ---------------------------------------------------------

SELECT c.customer_name,
       SUM(oi.sales_amount) AS total_revenue
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- ---------------------------------------------------------
-- TASK 2: MONTHLY REVENUE TREND
-- ---------------------------------------------------------

SELECT MONTH(o.order_date) AS month_no,
       SUM(oi.sales_amount) AS monthly_revenue
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY MONTH(o.order_date)
ORDER BY month_no;

-- ---------------------------------------------------------
-- TASK 3: BEST SELLING PRODUCTS
-- ---------------------------------------------------------

SELECT p.product_name,
       SUM(oi.quantity) AS total_quantity_sold,
       SUM(oi.sales_amount) AS total_sales
FROM products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- ---------------------------------------------------------
-- TASK 4: LOW INVENTORY PRODUCTS
-- ---------------------------------------------------------

SELECT product_name,
       stock_quantity,
       CASE
           WHEN stock_quantity < 20 THEN 'Critical Stock'
           WHEN stock_quantity < 50 THEN 'Low Stock'
           ELSE 'Sufficient Stock'
       END AS inventory_status
FROM products
ORDER BY stock_quantity ASC;

-- ---------------------------------------------------------
-- TASK 5: PAYMENT METHOD ANALYSIS
-- ---------------------------------------------------------

SELECT payment_method,
       COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- ---------------------------------------------------------
-- TASK 6: REPEAT CUSTOMERS
-- ---------------------------------------------------------

SELECT c.customer_name,
       COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- ---------------------------------------------------------
-- TASK 7: CUSTOMER SEGMENTATION
-- ---------------------------------------------------------

SELECT c.customer_name,
       SUM(oi.sales_amount) AS total_spent,
       CASE
           WHEN SUM(oi.sales_amount) >= 500000 THEN 'VIP'
           WHEN SUM(oi.sales_amount) >= 200000 THEN 'Regular'
           ELSE 'Low Value'
       END AS customer_segment
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

-- ---------------------------------------------------------
-- TASK 8: MONTH-OVER-MONTH GROWTH
-- ---------------------------------------------------------

WITH monthly_sales AS (
    SELECT MONTH(o.order_date) AS month_no,
           SUM(oi.sales_amount) AS revenue
    FROM orders o
    INNER JOIN order_items oi
    ON o.order_id = oi.order_id
    GROUP BY MONTH(o.order_date)
)

SELECT month_no,
       revenue,
       revenue - LAG(revenue) OVER (
           ORDER BY month_no
       ) AS revenue_growth
FROM monthly_sales;


-- =========================================================
-- SECTION 15: SQL VIEWS
-- =========================================================

-- ---------------------------------------------------------
-- VIEW: CUSTOMER SALES VIEW
-- ---------------------------------------------------------

CREATE VIEW customer_sales_view AS
SELECT c.customer_name,
       p.product_name,
       oi.quantity,
       oi.sales_amount
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id;

-- ---------------------------------------------------------
-- Display View Data
-- ---------------------------------------------------------

SELECT * FROM customer_sales_view;


-- =========================================================
-- SECTION 16: STORED PROCEDURES
-- =========================================================

DELIMITER //

CREATE PROCEDURE GetTopCustomers()
BEGIN

    SELECT c.customer_name,
           SUM(oi.sales_amount) AS total_revenue
    FROM customers c
    INNER JOIN orders o
    ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
    ON o.order_id = oi.order_id
    GROUP BY c.customer_name
    ORDER BY total_revenue DESC
    LIMIT 5;

END //

DELIMITER ;

-- ---------------------------------------------------------
-- Execute Stored Procedure
-- ---------------------------------------------------------

CALL GetTopCustomers();


-- =========================================================
-- SECTION 17: INDEXING
-- =========================================================

-- ---------------------------------------------------------
-- Create Index on customer_id
-- ---------------------------------------------------------

CREATE INDEX idx_customer_id
ON orders(customer_id);

-- ---------------------------------------------------------
-- View Indexes
-- ---------------------------------------------------------

SHOW INDEXES FROM orders;


-- =========================================================
-- SECTION 18: QUERY OPTIMIZATION
-- =========================================================

-- ---------------------------------------------------------
-- EXPLAIN QUERY EXECUTION PLAN
-- ---------------------------------------------------------

EXPLAIN
SELECT c.customer_name,
       SUM(oi.sales_amount)
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_name;