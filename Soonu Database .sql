CREATE DATABASE Snoou_db;
USE Snoou_db;

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

INSERT INTO customers(first_name, last_name , email ,phone, address) VALUES
	('Ahmed', 'Al-Mohannadi', 'ahmed.m@example.com', '+97450123456', '123 Pearl Street, West Bay, Doha'),
	('Fatima', 'Abdullah', 'fatima.a@example.com', '+97455123456', '456 Al Waab Street, Al Waab, Doha'),
	('Mohammed', 'Khan', 'm.khan@example.com', '+97433123456', '789 Al Sadd Street, Al Sadd,Doha'),
	('Aisha', 'Al-Sulaiti', 'a.sulaiti@example.com', '+97444123456', '321 Lusail Street, Lusail,Qatar'),
	('Khalid', 'Ali', 'k.ali@example.com', '+97477123456', '654 Education City,Al Rayyan,Qatar');

CREATE TABLE categories(
    category_id        INT PRIMARY KEY AUTO_INCREMENT,
    category_name      VARCHAR(50),
    parent_category_id INT,
    description        TEXT
);

SELECT * FROM categories;

INSERT INTO categories (category_name,parent_category_id,description) VALUES
	('Electronics', NULL, 'All electronic devices and accessories'),
	('Mobile Phones', 1, 'Smartphones and feature phones'),
	('Laptops', 1, 'Laptops and notebooks'),
	('Fashion', NULL, 'Clothing and accessories'),
	('Men''s Fashion', 4, 'Clothing for men'),
	('Women''s Fashion', 4, 'Clothing for women'),
	('Home & Kitchen', NULL, 'Home appliances and kitchenware');

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

INSERT INTO products (product_name,description,category_id,price,cost,stock_quantity,sku) VALUES
	('iPhone 15 Pro', 'Latest Apple smartphone with A17 chip', 2, 4299.00, 3500.00, 50, 'APP-IP15P-256'),
	('Samsung Galaxy S23', 'Flagship Android smartphone', 2, 3499.00, 2800.00, 75, 'SAM-GS23-256'),
	('MacBook Pro 14"', 'Apple laptop with M2 Pro chip', 3, 6999.00, 5800.00, 30, 'APP-MBP14-M2'),
	('Dell XPS 15', 'Premium Windows laptop', 3, 5999.00, 4800.00, 40, 'DEL-XPS15-2023'),
	('Qatari Thobe', 'Traditional white thobe for men', 5, 299.00, 150.00, 200, 'FAS-THB-QTR'),
	('Abaya - Black', 'Elegant black abaya for women', 6, 399.00, 200.00, 150, 'FAS-ABY-BLK'),
	('Arabic Coffee Set', 'Traditional Dallah and finjan set', 7, 199.00, 90.00, 100, 'HOM-CAF-ARB');

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

INSERT INTO orders (customer_id,status,total_amount,payment_method,delivery_address,contact_phone) VALUES
	(1, 'Delivered', 4299.00, 'Credit Card', '123 Pearl Street, West Bay, Doha', '+97450123456'),
	(2, 'Processing', 5999.00, 'STC Pay', '456 Al Waab Street, Al Waab, Doha', '+97455123456'),
	(3, 'Shipped', 798.00, 'Cash on Delivery', '789 Al Sadd Street, Al Sadd, Doha', '+97433123456'),
	(4, 'Pending', 3499.00, 'Apple Pay', '321 Lusail Street, Lusail, Qatar', '+97444123456'),
	(5, 'Delivered', 199.00, 'Credit Card', '654 Education City, Al Rayyan, Qatar', '+97477123456');

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

INSERT INTO order_items (order_id,product_id,quantity,subtotal) VALUES
	(1, 1, 1, 4299.00),
	(2, 4, 1, 5999.00),
	(3, 5, 2, 299.00),
	(3, 7, 1, 199.00),
	(4, 2, 1, 3499.00),
	(5, 7, 1, 199.00);
	
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

INSERT INTO payments ( order_id,amount,payment_date,payment_status,transaction_id) VALUES
	(1, 4299.00, '2023-10-01 14:30:00', 'Completed', 'TXN123456789'),
	(2, 5999.00, '2023-10-02 10:15:00', 'Completed', 'TXN987654321'),
	(5, 199.00, '2023-10-03 16:45:00', 'Completed', 'TXN456789123');

SELECT 
	CONCAT(c.first_name,' ',c.last_name) AS Customer_name,c.email,c.phone,SUM(o.total_amount) AS Total_purchased_amount
FROM customers c 
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY Customer_name,c.email,c.phone
ORDER BY Total_purchased_amount DESC 
LIMIT 5;

SELECT 
	p.product_name,p.price,p.stock_quantity,COUNT(o.order_id) AS Total_orders
FROM products p 
LEFT JOIN order_items oi ON p.product_id=oi.product_id
LEFT JOIN orders o ON o.order_id=oi.order_id
WHERE p.stock_quantity<20
GROUP BY p.product_name,p.price,p.stock_quantity
HAVING Total_orders>0;

SELECT 
	status,COUNT(*) AS Total_orders
FROM orders 
WHERE MONTH(order_date)=MONTH(CURRENT_DATE()) AND YEAR(order_date)=YEAR(CURRENT_DATE())
GROUP BY status;

SELECT 
	payment_method,ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM orders),2) AS Percentage
FROM orders
GROUP BY payment_method;

SELECT 
	ct.category_name,SUM(p.price*oi.quantity) AS Total_revenue
FROM categories ct 
JOIN products p ON p.category_id=ct.category_id
JOIN order_items oi ON p.product_id=oi.product_id
GROUP BY ct.category_name
ORDER BY Total_revenue DESC;

SELECT 
	CONCAT(c.first_name,' ',c.last_name) AS Customer_name,COUNT(o.order_id) AS Total_purchases
FROM customers c 
LEFT JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_date >= DATE_SUB(CURRENT_DATE(),INTERVAL 3 MONTH)
GROUP BY Customer_name
HAVING Total_purchases>1;

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

SELECT 
	CONCAT(c.first_name,' ',c.last_name) AS Customer_name,c.phone,c.email,c.address,
    o.order_date,o.status,o.total_amount,o.payment_method,p.product_name
FROM customers c 
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON oi.order_id=o.order_id
JOIN products p ON p.product_id=oi.product_id
WHERE o.total_amount>5000.00;

SELECT 
	p.product_name,o.status AS Order_status,COUNT(o.order_id) AS Total_cancelled_orders
FROM products p 
JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON o.order_id=oi.order_id
WHERE LOWER(o.status) = 'cancelled'
GROUP BY p.product_name,Order_status
ORDER BY Total_cancelled_orders DESC 
LIMIT 3;

SELECT 
	DATE_FORMAT(order_date,'%Y-%m') AS Month,
    SUM(total_amount) AS Total_sales 
FROM orders 
WHERE order_date >=DATE_SUB(CURRENT_DATE(),INTERVAL 6 MONTH)
GROUP BY Month 
ORDER BY Month;
