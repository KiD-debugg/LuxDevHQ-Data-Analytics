# SQL Practice Project — Sunrise Supermarket

**Name:** Benjamin Ochieng
**Date:** July 2025
**Database:** PostgreSQL
**Programme:** LuxDevHQ Data Science & Analytics

---

## The Scenario

Harun had a problem. Sunrise Supermarket was running their customer, product, and order records without a proper database — and he needed someone to build one from scratch. Not just the tables. Everything: the schema design, the constraints, the data, and the queries to answer real business questions.

This project is that build. Four tables, linked together through foreign keys, populated with real records, and queried from basic filtering all the way through to a four-table JOIN that produces one clean row per item ordered.

---

## What This Covers

- **Part 1** — Creating and altering tables (DDL: `CREATE TABLE`, `ALTER TABLE`)
- **Part 2** — Inserting, updating, and deleting data (DML: `INSERT`, `UPDATE`, `DELETE`)
- **Part 3** — Filtering and operators (`WHERE`, `BETWEEN`, `IN`, `LIKE`, `ORDER BY`, `LIMIT`)
- **Part 4** — Grouping and aggregates (`GROUP BY`, `COUNT`, `HAVING`)
- **Part 5** — Joins (`INNER JOIN`, `LEFT JOIN`, four-table chain join)

---

## The Database Structure

Four tables. One schema.

```
customers
│
└── orders  (customer_id → customers)
        │
        └── order_items  (order_id → orders)
                │
                └── products  (product_id → products)
```

`order_items` is the bridge table connecting orders to products. It is the last table created and the last populated — foreign key constraints enforce this order. Attempting to insert into `order_items` before `orders` and `products` exist will fail.

---

## File Structure

```
SQL/
└── Sunrise-Supermarket/
    ├── README.md
    └── benjamin_ochieng_sunrise_supermarket.sql
```

The `.sql` file contains every task in order — table creation, data insertion, and all queries — each with a comment explaining what it does and why.

---

## Part Summaries

### Part 1 — Creating & Altering Tables

Designed all four tables with appropriate constraints chosen deliberately:

- `customers` — `email` and `phone_number` carry `UNIQUE` constraints. No two customers can share either.
- `products` — `unit_price` has a `CHECK (unit_price > 0)` constraint. A price of zero is not valid data.
- `orders` — `customer_id` is a foreign key. An order cannot exist for a customer who does not exist.
- `order_items` — carries two foreign keys, one to `orders` and one to `products`. `quantity` has `CHECK (quantity > 0)`.

Three `ALTER TABLE` operations were also applied: renaming the `stock` column to `stock_quantity`, adding a `loyalty_points` column defaulting to 0, and expanding `product_name` to `VARCHAR(150)`.

### Part 2 — Inserting & Changing Data

Data was inserted in dependency order — `customers` and `products` first (no foreign keys), then `orders`, then `order_items` last. Inserting in any other order would violate foreign key constraints and fail.

One deliberate detail in the dataset: order_id 4 (Faith's cancelled order) had no matching rows in `order_items`. This made the `DELETE` in Task 13 straightforward — no child records needed clearing first. If it had had order items, those would have needed deleting before the parent order could be removed.

### Part 3 — Filtering & Operators

Seven queries covering the full range of `WHERE` clause tools: comparison operators, `BETWEEN` for inclusive ranges, `IN` for membership lists, `LIKE` with `%` wildcards for pattern matching, and `ORDER BY` combined with `LIMIT` for ranked results.

### Part 4 — Grouping & Aggregates

Two queries — one counting orders per customer using `GROUP BY`, one adding `HAVING` to filter only customers with more than one order. The distinction between `WHERE` (filters rows before grouping) and `HAVING` (filters groups after aggregation) is what makes the second query work correctly.

### Part 5 — Joins

Four join tasks building progressively in complexity:

- Two-table `INNER JOIN` — customers with their orders
- `LEFT JOIN` — all orders including those with no items, exposing Faith's cancelled order with `NULL` in the order_items columns
- Two-table join on order_items and products
- Four-table chain join: `customers → orders → order_items → products`, producing one row per item ordered with full customer and product context
- The same four-table join extended with `GROUP BY` to show total quantity ordered per product across all customers

---

## Key Things Learned

Insert order is not optional when foreign keys are involved. PostgreSQL enforces referential integrity at the point of insert — the parent row must exist before the child row that references it can be created.

`LEFT JOIN` and `INNER JOIN` give different answers for a reason. An `INNER JOIN` between orders and order_items would have silently hidden Faith's cancelled order. The `LEFT JOIN` kept it visible with `NULL` values, which is exactly what the task needed.

`HAVING` is not interchangeable with `WHERE`. `WHERE` runs before rows are grouped. `HAVING` runs after. Trying to filter on a `COUNT()` result using `WHERE` fails because the count does not exist yet at that point in the execution order.

Constraint design happens before data arrives. A `CHECK` constraint on `unit_price` or `quantity` cannot retroactively fix bad data already in the table — it only prevents future bad inserts. Getting the constraints right at the `CREATE TABLE` stage protects the database going forward.


---

*Part of the LuxDevHQ Data Science & Analytics Programme — SQL Module.*
*Benjamin Ochieng | Nairobi, Kenya*
