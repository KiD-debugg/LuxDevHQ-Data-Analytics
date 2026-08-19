# 03 — Aggregation & Grouping

Filtering narrows down which rows you see. Aggregation answers a different kind of question: not "which rows," but "what does this whole set of rows add up to." This file covers the five core aggregate functions, then `GROUP BY` to run those functions per category instead of over an entire table, then `HAVING` to filter the groups themselves.

## Aggregate Functions

| Function | Returns |
|---|---|
| `COUNT(*)` | number of rows |
| `SUM(column)` | total of a numeric column |
| `AVG(column)` | average of a numeric column |
| `MAX(column)` | highest value in a column |
| `MIN(column)` | lowest value in a column |

Run without `GROUP BY`, an aggregate collapses the *entire table* into a single row:

```sql
SELECT COUNT(*) FROM safari.drivers;
SELECT COUNT(*) FROM safari.riders;
SELECT COUNT(*) FROM safari.trips;
```

**Example output:**

| Query | Result |
|---|---|
| `COUNT(*) FROM safari.drivers` | 10 |
| `COUNT(*) FROM safari.riders` | 12 |
| `COUNT(*) FROM safari.trips` | 40 |

```sql
SELECT MAX(score), MIN(score), ROUND(AVG(score), 2) AS avg_score
FROM study_group.quiz_scores;
```

**Example output** (16 quiz scores on file):

| max | min | avg_score |
|---|---|---|
| 95 | 45 | 73.56 |

That's one row back, no matter how many rows the table has — every aggregate function on its own works this way until `GROUP BY` gets involved.

## GROUP BY

### The Concept

Picture sorting a pile of receipts into envelopes — one envelope per category — before adding up what's in each one. That's what `GROUP BY` does to a table. It doesn't calculate anything by itself; it just decides how to sort the rows into piles. The aggregate function you put next to it (`COUNT`, `SUM`, `AVG`, and so on) is what actually adds up each pile.

Take a small slice of the shop inventory — just the category column:

| product_name | category |
|---|---|
| Maziwa Fresh | Dairy |
| Mtindi | Dairy |
| Soda | Beverages |
| Chai ya Majani | Beverages |
| Mkate | Snacks & Bakery |

Without `GROUP BY`, a query just sees five separate rows. Add `GROUP BY category`, and the database mentally sorts them into piles first:

```
Dairy pile:            Maziwa Fresh, Mtindi
Beverages pile:        Soda, Chai ya Majani
Snacks & Bakery pile:  Mkate
```

*Then* whatever aggregate function sits in the `SELECT` list runs once per pile, not once for the whole table. `COUNT(*)` on the Dairy pile returns 2. On the Snacks & Bakery pile, it returns 1. The result is one output row per pile, not one per original row — this is the part that trips people up at first, since the number of rows coming out is usually much smaller than the number of rows going in.

The one strict rule: every plain column in the `SELECT` list (anything not wrapped in an aggregate function) has to also appear in `GROUP BY`. The database needs to know, for a pile that might contain several original rows, which single value to display for that column — and it can only guarantee that for the column(s) it grouped by.

### In Practice

```sql
SELECT product_category, COUNT(*) AS num_products, ROUND(AVG(price), 2) AS avg_price
FROM duka.duka_products
GROUP BY product_category;
```

**Example output:**

| product_category | num_products | avg_price |
|---|---|---|
| Grains & Cereals | 5 | 195.00 |
| Dairy | 2 | 75.00 |
| Beverages | 2 | 160.00 |
| Household | 1 | 55.00 |
| Snacks & Bakery | 1 | 65.00 |

### Same Idea, Different Column

Grouping by author instead of category works the exact same way — same "sort into piles, then aggregate" process, just a different column decides the piles:

```sql
SELECT author, COUNT(*) AS num_books, SUM(price) AS total_value
FROM book_store.books
GROUP BY author;
```

**Example output** (14 authors, 15 books — showing the one author with more than one book plus a couple of single-book rows for contrast):

| author | num_books | total_value |
|---|---|---|
| John Kimani | 2 | 3000.00 |
| Sarah Mwangi | 1 | 2200.00 |
| Robert C. Martin | 1 | 4800.00 |
| *(11 more authors, each 1 book)* | | |

Every column in the `SELECT` list that isn't wrapped in an aggregate function has to appear in the `GROUP BY` clause — the database needs to know exactly what defines each bucket.

## HAVING vs. WHERE

Both filter rows, but at different stages, which is why they can't be swapped for each other:

| | Filters | Runs |
|---|---|---|
| `WHERE` | individual rows | before grouping happens |
| `HAVING` | groups, after aggregation | after `GROUP BY` has already collapsed rows |

```sql
SELECT author, COUNT(*) AS num_books
FROM book_store.books
GROUP BY author
HAVING COUNT(*) > 1;
```

**Example output:**

| author | num_books |
|---|---|
| John Kimani | 2 |

Only one row survives — John Kimani is the only author in the table with more than one book. `WHERE` couldn't have done this filtering, because at the point `WHERE` runs, `COUNT(*)` doesn't exist yet — the rows haven't been grouped or counted.

```sql
SELECT product_category, COUNT(*) AS num_products
FROM duka.duka_products
GROUP BY product_category
HAVING COUNT(*) > 1;
```

**Example output:**

| product_category | num_products |
|---|---|
| Grains & Cereals | 5 |
| Dairy | 2 |
| Beverages | 2 |

Household and Snacks & Bakery drop out — both have only one product, so `HAVING COUNT(*) > 1` filters them out after the grouping already happened.

> ⚠️ **Common pitfall:** trying to write `WHERE COUNT(*) > 1` instead of `HAVING COUNT(*) > 1`. It fails, because `WHERE` executes before `GROUP BY` in the query's actual execution order (see the table in file 02) — at that point in the process, there's no `COUNT(*)` to compare against yet, only individual ungrouped rows. Any time a condition needs to check an aggregate result, it belongs in `HAVING`, not `WHERE`.

## Quick Reference

| Task | Command |
|---|---|
| Count all rows | `SELECT COUNT(*) FROM table;` |
| Total a numeric column | `SELECT SUM(column) FROM table;` |
| Group rows by a column's value | `... GROUP BY column;` |
| Filter individual rows (before grouping) | `WHERE condition` |
| Filter groups (after aggregation) | `HAVING condition` |
