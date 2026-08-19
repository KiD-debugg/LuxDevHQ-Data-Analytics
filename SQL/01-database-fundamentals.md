# 01 — Database Fundamentals: Schemas, Tables & Constraints

This is where the practice started: setting up a schema, defining tables with the right data types, and learning what actually enforces data integrity versus what just *looks* like it does. Every example below uses a small fictional bookstore database (`book_store`) — customers, books, and orders.

## Schemas

A schema is a namespace inside a database. It groups related tables together and keeps a large database from turning into a flat pile of tables with no structure.

```sql
CREATE SCHEMA book_store;
```

Once created, tables live inside it (`book_store.customers`, `book_store.books`), and you can either fully qualify the name every time or set a search path so PostgreSQL checks that schema first:

```sql
SET search_path TO book_store;
```

## Creating Tables

```sql
CREATE TABLE book_store.customers (
    customer_id  SERIAL PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    email        VARCHAR(100) UNIQUE,
    phone_number CHAR(10) UNIQUE
);
```

`SERIAL` auto-increments — PostgreSQL manages the numbering, so you never insert an ID by hand. The rest of the row's shape comes down to picking the right data type for what the column will actually hold:

| Data type | Use it for |
|---|---|
| `SERIAL` | Auto-incrementing primary keys |
| `VARCHAR(n)` | Text with a known max length (names, emails) |
| `CHAR(n)` | Fixed-length text (phone numbers, codes) |
| `INT` | Whole numbers |
| `NUMERIC` | Exact decimals — prices, money, anything where float rounding would be a problem |
| `DATE` | Calendar dates with no time component |

## Constraints

A constraint is a rule the database enforces on its own, so bad data never makes it into a table in the first place — you don't have to trust every INSERT to be careful.

| Constraint | What it does | Example |
|---|---|---|
| `PRIMARY KEY` | Uniquely identifies each row; can't be NULL | `customer_id SERIAL PRIMARY KEY` |
| `FOREIGN KEY` | Row must match a real row in another table | `customer_id INT REFERENCES customers(customer_id)` |
| `UNIQUE` | No two rows can share this value | `email VARCHAR(100) UNIQUE` |
| `NOT NULL` | Column can't be left empty | `first_name VARCHAR(50) NOT NULL` |

Constraints can be added or removed after a table already exists, using `ALTER TABLE`:

```sql
-- Add a unique constraint
ALTER TABLE book_store.books
ADD CONSTRAINT unique_title UNIQUE(title);

-- Remove it
ALTER TABLE book_store.books
DROP CONSTRAINT unique_title;

-- Add a foreign key
ALTER TABLE book_store.orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES book_store.customers(customer_id);
```

> ⚠️ **Mistake I made:** I wrote a foreign key constraint referencing `book_store.customer` — singular — when the actual table was named `customers`, plural. PostgreSQL doesn't guess what you meant; it just fails, and the error points at the table name, not at "you have a typo." It taught me to always double-check the exact table name a constraint references before running it, especially since a typo here fails silently in the sense that nothing about the SQL syntax itself is wrong — it's a naming mismatch, not a grammar mistake.

## Modifying Table Structure

`ALTER TABLE` is also how you change a table after data already exists in it, without dropping and recreating everything:

```sql
-- Rename a table
ALTER TABLE book_store.customers RENAME TO clients;

-- Add a column
ALTER TABLE book_store.orders ADD COLUMN quantity INT;

-- Remove a column
ALTER TABLE book_store.orders DROP COLUMN quantity;

-- Rename a column
ALTER TABLE book_store.customers RENAME COLUMN phone_number TO contacts;

-- Change a column's data type
ALTER TABLE book_store.customers ALTER COLUMN contacts TYPE VARCHAR(20);

-- Require a value going forward
ALTER TABLE book_store.customers ALTER COLUMN email SET NOT NULL;

-- Allow it to be empty again
ALTER TABLE book_store.customers ALTER COLUMN email DROP NOT NULL;
```

## Inserting, Updating, and Deleting Data

```sql
INSERT INTO book_store.customers (first_name, last_name, email, phone_number)
VALUES ('John', 'Doe', 'jd56@example.com', '0735472815');

SELECT * FROM book_store.customers;
```

**Example output:**

| customer_id | first_name | last_name | email | phone_number | city |
|---|---|---|---|---|---|
| 1 | John | Doe | jd56@example.com | 0735472815 | NULL |

`customer_id` fills itself in because it's `SERIAL`. `city` shows `NULL` since it wasn't part of the INSERT — this is what "optional" actually looks like at the row level, not just in the CREATE TABLE definition.

Updating one row is straightforward — `SET` the column, `WHERE` picks the row:

```sql
UPDATE book_store.customers
SET city = 'Nairobi'
WHERE customer_id = 1;
```

Updating several rows to different values in one statement is where `CASE WHEN` earns its keep, instead of writing a separate `UPDATE` per row:

```sql
UPDATE book_store.customers
SET city = CASE customer_id
    WHEN 1 THEN 'Nairobi'
    WHEN 2 THEN 'Nakuru'
    WHEN 3 THEN 'Mombasa'
    ELSE city
END;
```

The `ELSE city` matters — without it, every row that doesn't match one of the `WHEN` conditions gets set to `NULL` instead of being left alone.

**Example output** (assuming customers 1-3 already exist):

| customer_id | first_name | city |
|---|---|---|
| 1 | John | Nairobi |
| 2 | Mary | Nakuru |
| 3 | Peter | Mombasa |

```sql
DELETE FROM book_store.customers
WHERE customer_id = 1;

SELECT * FROM book_store.customers;
```

**Example output** (row 1 is gone, the rest are untouched):

| customer_id | first_name | city |
|---|---|---|
| 2 | Mary | Nakuru |
| 3 | Peter | Mombasa |

## TRUNCATE vs. DROP

These two get confused a lot because both "empty" a table, but they don't do the same thing:

| Command | Removes rows | Removes table structure | Typical use |
|---|---|---|---|
| `TRUNCATE TABLE` | Yes | No — table still exists, empty | Clearing a table to reload fresh data |
| `DROP TABLE` | Yes | Yes — table is gone entirely | Removing a table you no longer need at all |

```sql
TRUNCATE TABLE book_store.customers;   -- table stays, rows are gone
```

**After TRUNCATE** — `SELECT * FROM book_store.customers;` still works, it just returns nothing:

| customer_id | first_name | last_name | email | phone_number | city |
|---|---|---|---|---|---|
| *(0 rows)* | | | | | |

```sql
DROP TABLE book_store.customers;       -- table itself is gone
```

**After DROP** — the same `SELECT` now fails outright:

```
ERROR: relation "book_store.customers" does not exist
```

That error is the real difference between the two commands: TRUNCATE leaves you a usable, empty table; DROP leaves you nothing to query at all.

## Quick Reference

| Task | Command |
|---|---|
| Create a schema | `CREATE SCHEMA name;` |
| Create a table | `CREATE TABLE schema.table (...);` |
| Add a row | `INSERT INTO table (...) VALUES (...);` |
| Change a row | `UPDATE table SET col = value WHERE condition;` |
| Remove a row | `DELETE FROM table WHERE condition;` |
| Add/remove a column | `ALTER TABLE table ADD/DROP COLUMN col;` |
| Add/remove a constraint | `ALTER TABLE table ADD/DROP CONSTRAINT name ...;` |
| Empty a table, keep structure | `TRUNCATE TABLE table;` |
| Remove a table entirely | `DROP TABLE table;` |
