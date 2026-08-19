-- ============================================================
-- Sunrise Supermarket — Practice Project
-- Author : Benjamin Ochieng
-- Programme : LuxDevHQ Data Science & Analytics
-- Database : PostgreSQL
-- ============================================================


-- ============================================================
-- PART 1 — CREATING & ALTERING TABLES
-- ============================================================

-- Task 1: customers table
-- customer_id is the primary key.
-- email and phone_number must be unique — no two customers
-- can share either. Both are NOT NULL because a customer
-- record without contact details is not useful.

CREATE TABLE customers (
    customer_id   SERIAL        PRIMARY KEY,
    full_name     VARCHAR(100)  NOT NULL,
    email         VARCHAR(100)  NOT NULL UNIQUE,
    phone_number  CHAR(10)      NOT NULL UNIQUE,
    city          VARCHAR(50)
);

-- Task 2: products table
-- unit_price has a CHECK constraint — it must be greater than 0.
-- A product with a zero or negative price is a data entry error.
-- stock defaults to 0 so records can be created before stock arrives.

CREATE TABLE products (
    product_id    SERIAL          PRIMARY KEY,
    product_name  VARCHAR(100)    NOT NULL,
    category      VARCHAR(50),
    unit_price    NUMERIC(10,2)   NOT NULL CHECK (unit_price > 0),
    stock         INT             NOT NULL DEFAULT 0
);

-- Task 3: orders table
-- customer_id is a foreign key — an order cannot exist for
-- a customer who does not exist in the customers table.
-- status defaults to 'Pending' if not provided at insert time.

CREATE TABLE orders (
    order_id     SERIAL       PRIMARY KEY,
    customer_id  INT          NOT NULL REFERENCES customers(customer_id),
    order_date   DATE         NOT NULL,
    status       VARCHAR(20)  NOT NULL DEFAULT 'Pending'
);

-- Task 4: order_items table
-- This table has two foreign keys — one to orders, one to products.
-- An order item cannot exist without a valid order AND a valid product.
-- quantity must be greater than 0 — you cannot order zero or negative items.

CREATE TABLE order_items (
    order_item_id  SERIAL  PRIMARY KEY,
    order_id       INT     NOT NULL REFERENCES orders(order_id),
    product_id     INT     NOT NULL REFERENCES products(product_id),
    quantity       INT     NOT NULL CHECK (quantity > 0)
);

-- Task 5: rename stock column to stock_quantity
-- The business wants a more descriptive column name.

ALTER TABLE products
RENAME COLUMN stock TO stock_quantity;

-- Task 6: add loyalty_points column to customers
-- New loyalty programme — every existing and future customer
-- starts at 0 points by default.

ALTER TABLE customers
ADD COLUMN loyalty_points INT NOT NULL DEFAULT 0;

-- Task 7: expand product_name to VARCHAR(150)
-- Some product names are longer than the original 100 characters allowed.
-- Increasing the limit does not affect existing data.

ALTER TABLE products
ALTER COLUMN product_name TYPE VARCHAR(150);


-- ============================================================
-- PART 2 — INSERTING & CHANGING DATA
-- ============================================================

-- Insert order: customers and products have no foreign keys
-- so they go first. orders references customers, so it goes
-- after customers. order_items references both orders and
-- products, so it must go last.

-- Task 8: insert customers

INSERT INTO customers (customer_id, full_name, email, phone_number, city)
VALUES
    (1, 'Grace Wambui', 'grace.wambui@gmail.com', '0711223344', 'Nairobi'),
    (2, 'Kevin Mutiso',  'kevin.mutiso@gmail.com',  '0722334455', 'Nakuru'),
    (3, 'Faith Chebet',  'faith.chebet@gmail.com',  '0733445566', 'Eldoret'),
    (4, 'Ibrahim Noor',  'ibrahim.noor@gmail.com',  '0744556677', 'Mombasa');

-- Task 9: insert products

INSERT INTO products (product_id, product_name, category, unit_price, stock_quantity)
VALUES
    (1, 'Maize Flour 2kg', 'Groceries',  180.00,  50),
    (2, 'Cooking Oil 1L',  'Groceries',  320.00,  30),
    (3, 'Bathing Soap',    'Toiletries',  85.00, 100),
    (4, 'Notebook A4',     'Stationery',  60.00, 200);

-- Task 10: insert orders

INSERT INTO orders (order_id, customer_id, order_date, status)
VALUES
    (1, 1, '2024-03-01', 'Delivered'),
    (2, 2, '2024-03-02', 'Pending'),
    (3, 1, '2024-03-03', 'Delivered'),
    (4, 3, '2024-03-04', 'Cancelled');

-- Task 11: insert order_items
-- Note: order_id 4 (Faith's cancelled order) deliberately
-- has no matching rows here — that gap is used in the JOIN tasks.

INSERT INTO order_items (order_item_id, order_id, product_id, quantity)
VALUES
    (1, 1, 1, 2),
    (2, 1, 3, 1),
    (3, 2, 2, 1),
    (4, 3, 4, 5);

-- Task 12: update order_id 2 status to Delivered
-- Kevin's order has now been delivered.

UPDATE orders
SET status = 'Delivered'
WHERE order_id = 2;

-- Task 13: delete the cancelled order (order_id 4)
-- Faith's cancelled order (order_id 4) has NO rows in order_items
-- as noted in the project brief. This means we can delete directly
-- from orders without touching order_items first.
-- If it had order_items rows, we would need to delete those first
-- to avoid a foreign key constraint violation.

DELETE FROM orders
WHERE order_id = 4;


-- ============================================================
-- PART 3 — FILTERING & OPERATORS
-- ============================================================

-- Task 14: every product priced above 100

SELECT *
FROM products
WHERE unit_price > 100;

-- Task 15: every customer NOT based in Nairobi

SELECT *
FROM customers
WHERE city != 'Nairobi';

-- Task 16: every product priced between 60 and 200 inclusive
-- BETWEEN includes both endpoints — 60 and 200 will appear in results.

SELECT *
FROM products
WHERE unit_price BETWEEN 60 AND 200;

-- Task 17: customers in Nairobi, Nakuru, or Mombasa using IN
-- IN is cleaner than writing three separate OR conditions.

SELECT *
FROM customers
WHERE city IN ('Nairobi', 'Nakuru', 'Mombasa');

-- Task 18: products whose name contains the word 'Oil'
-- The % wildcards mean 'Oil' can appear anywhere in the name.

SELECT *
FROM products
WHERE product_name LIKE '%Oil%';

-- Task 19: Pending orders sorted by order_date earliest first

SELECT *
FROM orders
WHERE status = 'Pending'
ORDER BY order_date ASC;

-- Task 20: the 2 most expensive products
-- Sort by price descending so the most expensive comes first,
-- then LIMIT cuts the result to just the top 2.

SELECT *
FROM products
ORDER BY unit_price DESC
LIMIT 2;


-- ============================================================
-- PART 4 — GROUPING & AGGREGATES
-- ============================================================

-- Task 21: count of orders per customer_id

SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id;

-- Task 22: only customers who placed more than 1 order
-- HAVING filters after the GROUP BY has run — you cannot use
-- WHERE here because the count does not exist until after grouping.

SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- ============================================================
-- PART 5 — JOINS
-- ============================================================

-- Task 23: INNER JOIN customers with orders
-- Only customers who have at least one order will appear.
-- customer_id 4 (Ibrahim) has no orders so he will not show up.

SELECT
    c.full_name,
    o.order_id,
    o.status
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;

-- Task 24: LEFT JOIN orders with order_items
-- LEFT JOIN keeps ALL orders even if they have no matching items.
-- Before Task 13's DELETE, order_id 4 would have appeared here
-- with NULL in all order_items columns — proof that Faith's
-- cancelled order existed with no items attached.
-- After the DELETE, order_id 4 is gone from orders entirely
-- so this query reflects the cleaned state.

SELECT
    o.order_id,
    o.status,
    oi.order_item_id,
    oi.product_id,
    oi.quantity
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id;

-- Task 25: JOIN order_items with products
-- Shows what product was in each order item and how many were ordered.

SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    oi.quantity
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id;

-- Task 26: all four tables joined in one query
-- Chain: customers → orders → order_items → products
-- Each join moves one step along the relationship chain.
-- The result is one row per item ordered with full context.

SELECT
    c.full_name,
    o.order_id,
    p.product_name,
    oi.quantity
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id;

-- Task 27: total quantity ordered per product across all customers
-- Same four-table JOIN as Task 26, but GROUP BY product_name
-- and SUM quantity to aggregate across all orders.

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_ordered
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_ordered DESC;

