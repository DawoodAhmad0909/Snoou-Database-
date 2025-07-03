# Snoou Database
## Overview
The Snoou_db database is a compact e-commerce system designed to manage customers, products, orders, and payments. It supports key operations like tracking purchases, inventory, and customer behavior.
## Objectives
To design and implement a comprehensive e-commerce database system for Qatari businesses that efficiently manages products, customers, orders, and payments to optimize online retail operations and enhance customer experience.
## Database Creation
``` sql
CREATE DATABASE Snoou_db;
USE Snoou_db;
```
## Table Creation
### Table:customers
``` sql
CREATE TABLE customers(
    customer_id       INT PRIMARY KEY AUTO_INCREMENT,
    first_name        VARCHAR(25),
    last_name         VARCHAR(25),
    email             TEXT,
    phone             VARCHAR(15),
    address           TEXT,
    city              VARCHAR(25),
    country           VARCHAR(25),
    registration_date DATE,
    loyalty_points    INT
);

SELECT * FROM customers;
```
### Table:categories
``` sql
CREATE TABLE categories(
    category_id        INT PRIMARY KEY AUTO_INCREMENT,
    category_name      VARCHAR(50),
    parent_category_id INT,
    description        TEXT
);

SELECT * FROM categories;
```
### Table:products
``` sql
CREATE TABLE products(
    product_id     INT PRIMARY KEY AUTO_INCREMENT,
    product_name   TEXT,
    description    TEXT,
    category_id    INT,
    price          DECIMAL(10,2),
    cost           DECIMAL(10,2),
    stock_quantity INT,
    sku            VARCHAR(50),
    created_at     DATETIME,
    updated_at     DATETIME,
    is_active      BOOLEAN,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

SELECT * FROM products;
```
### Table:orders
``` sql
CREATE TABLE orders(
    order_id         INT PRIMARY KEY AUTO_INCREMENT,
    customer_id      INT,
    order_date       DATETIME,
    status           VARCHAR(25),
    total_amount     DECIMAL(10,2),
    payment_method   VARCHAR(50),
    delivery_address TEXT,
    contact_phone    VARCHAR(15),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SELECT * FROM orders;
```
### Table:order_items
``` sql
CREATE TABLE order_items(
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    subtotal      DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SELECT * FROM order_items;
```
### Table:payments
``` sql
CREATE TABLE payments(
    payment_id     INT PRIMARY KEY AUTO_INCREMENT,
    order_id       INT,
    amount         DECIMAL(10,2),
    payment_date   DATETIME,
    transaction_id VARCHAR(25),
    payment_status VARCHAR(25),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SELECT * FROM payments;
```
## Key Queries 

### 1. Customer Spending Analysis
#### List the top 5 customers by total purchase amount, including their contact information.
``` sql
SELECT 
        CONCAT(c.first_name,' ',c.last_name) AS Customer_name,c.email,c.phone,SUM(o.total_amount) AS Total_purchased_amount
FROM customers c 
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY Customer_name,c.email,c.phone
ORDER BY Total_purchased_amount DESC 
LIMIT 5;
```
### 2. Product Performance Report
#### Show products with low stock (less than 20 items) that have been ordered at least once.
``` sql
SELECT 
        p.product_name,p.price,p.stock_quantity,COUNT(o.order_id) AS Total_orders
FROM products p 
LEFT JOIN order_items oi ON p.product_id=oi.product_id
LEFT JOIN orders o ON o.order_id=oi.order_id
WHERE p.stock_quantity<20
GROUP BY p.product_name,p.price,p.stock_quantity
HAVING Total_orders>0;
```
### 3. Order Status Summary
#### Count orders by each status category (Pending, Processing, etc.) for the current month.
``` sql
SELECT 
        status,COUNT(*) AS Total_orders
FROM orders 
WHERE MONTH(order_date)=MONTH(CURRENT_DATE()) AND YEAR(order_date)=YEAR(CURRENT_DATE())
GROUP BY status;
```
### 4. Payment Method Preferences
#### Calculate the percentage distribution of payment methods used across all orders.
``` sql
SELECT 
        payment_method,ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM orders),2) AS Percentage
FROM orders
GROUP BY payment_method;
```
### 5. Category Sales Breakdown
#### Display sales figures by product category, sorted by highest revenue.
``` sql
SELECT 
        ct.category_name,SUM(p.price*oi.quantity) AS Total_revenue
FROM categories ct 
JOIN products p ON p.category_id=ct.category_id
JOIN order_items oi ON p.product_id=oi.product_id
GROUP BY ct.category_name
ORDER BY Total_revenue DESC;
```
### 6. Customer Retention Analysis
#### Identify customers who made more than one purchase within the last 3 months.
``` sql
SELECT 
        CONCAT(c.first_name,' ',c.last_name) AS Customer_name,COUNT(o.order_id) AS Total_purchases
FROM customers c 
LEFT JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_date >= DATE_SUB(CURRENT_DATE(),INTERVAL 3 MONTH)
GROUP BY Customer_name
HAVING Total_purchases>1;
```
### 7. Delivery Area Insights
#### Show the distribution of deliveries by city (Doha, Lusail, Al Rayyan, etc.).
``` sql
SELECT 
        CASE 
                WHEN delivery_address LIKE '%Doha%' THEN 'Doha'
        WHEN delivery_address LIKE '%Lusail%' THEN 'Lusail'
        WHEN delivery_address LIKE '%Al Rayyan%' THEN 'Al Rayyan'
        ELSE 'Other'
        END AS City,
    COUNT(*) AS Total_deliveries
FROM orders 
GROUP BY City;
```
### 8. High-Value Order Report
#### List all orders above 5,000 QAR with customer details and purchased items.
``` sql
SELECT 
        CONCAT(c.first_name,' ',c.last_name) AS Customer_name,c.phone,c.email,c.address,
    o.order_date,o.status,o.total_amount,o.payment_method,p.product_name
FROM customers c 
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON oi.order_id=o.order_id
JOIN products p ON p.product_id=oi.product_id
WHERE o.total_amount>5000.00;
```
### 9. Product Return Probability
#### Find products that appear most frequently in cancelled orders.
``` sql
SELECT 
        p.product_name,o.status AS Order_status,COUNT(o.order_id) AS Total_cancelled_orders
FROM products p 
JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON o.order_id=oi.order_id
WHERE LOWER(o.status) = 'cancelled'
GROUP BY p.product_name,Order_status
ORDER BY Total_cancelled_orders DESC 
LIMIT 3;
```
### 10. Seasonal Sales Trends
#### Compare monthly sales totals for the last 6 months (requires date range extension).
``` sql
SELECT 
        DATE_FORMAT(order_date,'%Y-%m') AS Month,
    SUM(total_amount) AS Total_sales 
FROM orders 
WHERE order_date >=DATE_SUB(CURRENT_DATE(),INTERVAL 6 MONTH)
GROUP BY Month 
ORDER BY Month;
```
## Conclusion 
With structured tables and analytical queries, this database enables insights into sales performance, payment preferences, delivery trends, and customer engagement. This design ensures efficient order management and helps drive informed business decisions.
