# 04 — Joins, Subqueries & CTEs

Real data doesn't live in one table. A shop's customers, products, and orders — or a ride-hailing app's drivers, riders, and trips — are deliberately split apart so nothing gets duplicated. The trade-off is that answering almost any interesting question means pulling those tables back together. This file covers three ways to do that: joining tables side by side, nesting one query inside another, and naming a query so it can be reused within a bigger one.

## Why Split Data Across Tables At All?

Consider what would happen if every order row also repeated the full customer name, phone number, and location. Change a customer's phone number and you'd have to update it in every single order row they've ever placed — miss one, and now the data disagrees with itself. Splitting customers and orders into separate tables means each fact lives in exactly one place. `JOIN` is the cost of that decision: the price paid at query time for not paying it at storage time.

**Reference data used throughout this section** — `duka.duka_customers` (8 rows) and `duka.duka_products` (11 rows, same as file 02), connected through `duka.duka_orders` (11 rows):

| order_id | customer_id | product_id | quantity |
|---|---|---|---|
| 1 | 1 (Peter Mwangi) | 3 (Sukari) | 2 |
| 2 | 1 (Peter Mwangi) | 4 (Maziwa Fresh) | 1 |
| 3 | 2 (Grace Njoroge) | 7 (Soda) | 3 |
| 4 | 3 (John Otieno) | 1 (Unga wa ngano) | 1 |
| 5 | 3 (John Otieno) | 10 (Maharagwe) | 2 |
| 6 | 4 (Faith Wambui) | 8 (Sabuni ya kufulia) | 1 |
| 7 | 5 (Samuel Kiptoo) | 3 (Sukari) | 5 |
| 8 | 6 (Lucy Achieng) | 7 (Soda) | 2 |
| 9 | 7 (David Mutua) | 4 (Maziwa Fresh) | 3 |
| 10 | 1 (Peter Mwangi) | 10 (Maharagwe) | 1 |
| 11 | 2 (Grace Njoroge) | 3 (Sukari) | 1 |

Notice customer 8, Ann Wanjiku, never appears in this table at all — she exists in `duka_customers` but has placed zero orders. Keep her in mind; she matters a lot for the LEFT JOIN section below.

## INNER JOIN

### The Concept

Picture two lists side by side — customers on one, orders on the other — connected by `customer_id`. An `INNER JOIN` walks through both lists and keeps only the pairs that actually match on that shared column. If a customer has three orders, that customer's row gets repeated three times, once per matching order — because the "row" the query returns isn't a customer anymore or an order anymore, it's a customer-and-order-together. If a customer has zero orders, they don't appear in the result at all — there's nothing on the other list to pair them with, so `INNER JOIN` just leaves them out silently.

That silent dropping is the detail that catches people off guard. `INNER JOIN` isn't "all customers, with their orders attached" — it's "only the combinations where both sides have something to offer."

### Syntax

```sql
SELECT columns
FROM tableA a
JOIN tableB b ON a.shared_column = b.shared_column;
```

### In Practice

```sql
SELECT dc.name, d.product_id, d.quantity, p.product_name
FROM duka.duka_customers dc
INNER JOIN duka.duka_orders d ON dc.customer_id = d.customer_id
INNER JOIN duka.duka_products p ON p.product_id = d.product_id;
```

**Example output** (all 11 orders — every customer with at least one order shows up, Ann Wanjiku does not):

| name | product_id | quantity | product_name |
|---|---|---|---|
| Peter Mwangi | 3 | 2 | Sukari |
| Peter Mwangi | 4 | 1 | Maziwa Fresh |
| Grace Njoroge | 7 | 3 | Soda |
| John Otieno | 1 | 1 | Unga wa ngano |
| John Otieno | 10 | 2 | Maharagwe |
| Faith Wambui | 8 | 1 | Sabuni ya kufulia |
| Samuel Kiptoo | 3 | 5 | Sukari |
| Lucy Achieng | 7 | 2 | Soda |
| David Mutua | 4 | 3 | Maziwa Fresh |
| Peter Mwangi | 10 | 1 | Maharagwe |
| Grace Njoroge | 3 | 1 | Sukari |

Peter Mwangi appears three times — once per order he's placed — which is exactly the "row per matching pair" behavior described above, not a mistake or a duplicate.

This example also joins three tables, not two. That's not a special operation — it's just two `INNER JOIN`s stacked, each one connecting a fresh table onto the combined result of the join before it:

```sql
-- Filter applied after joining: customers who ordered anything priced above 100
SELECT dc.name, dp.product_name, dp.price
FROM duka.duka_customers dc
INNER JOIN duka.duka_orders t ON dc.customer_id = t.customer_id
INNER JOIN duka.duka_products dp ON t.product_id = dp.product_id
WHERE dp.price > 100;
```

**Example output:**

| name | product_name | price |
|---|---|---|
| Peter Mwangi | Sukari | 165.00 |
| Peter Mwangi | Maharagwe | 200.00 |
| John Otieno | Unga wa ngano | 180.00 |
| John Otieno | Maharagwe | 200.00 |
| Samuel Kiptoo | Sukari | 165.00 |
| Grace Njoroge | Sukari | 165.00 |

The `WHERE` clause runs after the three tables are already stitched together — it doesn't matter that `price` technically lives in `duka_products` while the query started from `duka_customers`; once joined, every column from every joined table is available to filter on as if it were one wide table.

## LEFT JOIN

### The Concept

`LEFT JOIN` starts from the same idea as `INNER JOIN` — match rows across two tables on a shared column — but changes one rule: every row from the *left* table (the one named right after `FROM`) survives no matter what, even if nothing on the right side matches it. Where a match is missing, the columns that would have come from the right table are filled with `NULL` instead of the row disappearing.

This is the tool for exactly the situation `INNER JOIN` can't handle: finding things that *aren't there*. Ann Wanjiku, who never placed an order, is invisible to an `INNER JOIN` between customers and orders — there's no order row for her to match. She's exactly who shows up with a `LEFT JOIN`.

### Syntax

```sql
SELECT columns
FROM tableA a          -- the left table: every row from here survives
LEFT JOIN tableB b ON a.shared_column = b.shared_column;
```

### In Practice

```sql
-- Which customers have never ordered anything?
SELECT dc.name
FROM duka.duka_customers dc
LEFT JOIN duka.duka_orders t ON dc.customer_id = t.customer_id
WHERE t.order_id IS NULL;
```

**Example output:**

| name |
|---|
| Ann Wanjiku |

The logic here is worth slowing down on: `LEFT JOIN` first keeps *every* customer, filling in `NULL` for the order columns wherever there's no matching order. Then `WHERE t.order_id IS NULL` filters that combined result down to only the rows where the fill-in actually happened — in other words, only the customers who had nothing to match. `IS NULL` here isn't checking whether a customer's data is missing; it's checking whether the *join* found nothing.

```sql
-- Order count for every product, including products never ordered at all
SELECT p.product_name, COUNT(o.order_id) AS order_count
FROM duka.duka_products p
LEFT JOIN duka.duka_orders o ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY order_count DESC;
```

**Example output** (11 products — note the zeros, which an `INNER JOIN` would have hidden entirely):

| product_name | order_count |
|---|---|
| Sukari | 3 |
| Maziwa Fresh | 2 |
| Soda | 2 |
| Maharagwe | 2 |
| Unga wa ngano | 1 |
| Sabuni ya kufulia | 1 |
| Mchele Pishori | 0 |
| Mtindi | 0 |
| Chai ya Majani | 0 |
| Mkate | 0 |
| Unga wa Dola | 0 |

Swap this same query to `INNER JOIN` and the five zero-order products vanish from the result completely — not shown as 0, just gone, because there's no order row to join against. That's the practical difference between the two join types in one example: `LEFT JOIN` can answer "what's missing," `INNER JOIN` never can.

### COUNT(*) vs. COUNT(column) — a trap specific to LEFT JOIN

`COUNT(*)` counts rows. `COUNT(some_column)` counts rows where `some_column` isn't `NULL`. Normally these give the same answer, since a plain row is a plain row either way — but after a `LEFT JOIN`, they can disagree, because the unmatched rows are exactly the ones full of `NULL`s.

```sql
-- Every rider's trip count, including riders with zero trips
SELECT r.rider_id, r.rider_name, COUNT(t.trip_id) AS total_trips
FROM safari.riders r
LEFT JOIN safari.trips t ON r.rider_id = t.rider_id
GROUP BY r.rider_id, r.rider_name
ORDER BY total_trips ASC;
```

**Example output** (top of the list — Amina Hassan is the only rider with zero trips out of all 12):

| rider_id | rider_name | total_trips |
|---|---|---|
| 1 | Amina Hassan | 0 |
| 5 | Esther Mwikali | 2 |
| 7 | Grace Wambui | 2 |
| *(9 more riders, 3+ trips each)* | | |

Had this query used `COUNT(*)` instead of `COUNT(t.trip_id)`, Amina's row would show `1`, not `0` — because `COUNT(*)` counts the row itself (which does exist, filled with `NULL`s from the unmatched join), while `COUNT(t.trip_id)` correctly skips it since `t.trip_id` is `NULL` for her. Whenever counting "how many matches" after a `LEFT JOIN`, count a specific column from the *right-hand* table, never `*`.

## Subqueries

### The Concept

A subquery is a query nested inside another query — parentheses around a complete `SELECT` statement, sitting inside a bigger one. The inner query always runs first, and its result becomes something the outer query can use, the same way you'd solve a smaller math problem first to get a number you plug into a bigger equation.

**Reference data** — `study_group.quiz_scores` (16 rows, 8 members × 2 quizzes each): scores range from 45 to 95, and the average across all 16 rows is exactly 73.5625.

### Syntax

```sql
SELECT columns FROM table
WHERE column > (
    SELECT something FROM table   -- this inner query runs first
);
```

A subquery can appear in a few different spots, and where it sits changes what it's allowed to do:

| Location | What it does |
|---|---|
| `WHERE` / `HAVING` | Filters using a value calculated on the fly |
| `FROM` | Treats the subquery's result as a temporary table to query further — must be given an alias |
| `SELECT` list | Pulls in a single computed value alongside each row |

### In Practice

```sql
-- Which quiz scores are above the group's overall average?
SELECT score_id, member_id, score
FROM study_group.quiz_scores
WHERE score > (SELECT AVG(score) FROM study_group.quiz_scores);
```

**Example output** (9 of the 16 scores clear the 73.5625 bar):

| score_id | member_id | score |
|---|---|---|
| 2 | 1 (Brian) | 85 |
| 3 | 2 (Grace) | 90 |
| 4 | 2 (Grace) | 88 |
| 7 | 4 (Amina) | 78 |
| 8 | 4 (Amina) | 82 |
| 9 | 5 (Felix) | 91 |
| 10 | 5 (Felix) | 95 |
| 13 | 7 (David) | 84 |
| 14 | 7 (David) | 79 |

The inner query `SELECT AVG(score) FROM study_group.quiz_scores` runs once, resolves to the single number 73.5625, and then the outer query behaves as if it had simply been written `WHERE score > 73.5625`. The database doesn't recompute the average once per row — it works the value out once, then filters against it.

## CTEs (Common Table Expressions)

### The Concept

A CTE does the same job as a subquery in the `FROM` clause — a named, temporary result set that exists just for the duration of one query — but written up front with a `WITH` clause instead of nested inline. The practical benefit shows up once a query needs more than one intermediate step: nested subqueries stack up and get hard to read from the inside out, while CTEs read top to bottom, each one building on what came before.

### Syntax

```sql
WITH cte_name AS (
    SELECT ...
)
SELECT ...
FROM cte_name;
```

### In Practice

The subquery example above, rewritten as a CTE — same result, different shape:

```sql
WITH group_avg AS (
    SELECT AVG(score) AS avg_score
    FROM study_group.quiz_scores
)
SELECT score_id, member_id, score
FROM study_group.quiz_scores
CROSS JOIN group_avg
WHERE score > avg_score;
```

Same 9-row output as before. The one new piece is `CROSS JOIN group_avg` — worth explaining, since it looks like it should multiply the row count but doesn't here. `CROSS JOIN` normally pairs every row on the left with every row on the right — 16 rows crossed with 3 rows would produce 48. But `group_avg` only ever has exactly **one** row (one average, one column). Crossing 16 rows with a 1-row table produces 16 rows — every original row just gets that single average value attached as an extra column, which is exactly what's needed to compare each row against it. This is a deliberate, common pattern for attaching one computed value to every row of a table without a correlated subquery.

A second CTE example — comparing each member's personal average against the whole group's average, which needs two separate aggregates computed at two different levels:

```sql
WITH member_avg AS (
    SELECT member_id, AVG(score) AS avg_score
    FROM study_group.quiz_scores
    GROUP BY member_id
),
group_avg AS (
    SELECT AVG(score) AS avg_score
    FROM study_group.quiz_scores
)
SELECT m.member_id, m.avg_score AS personal_avg, g.avg_score AS group_avg
FROM member_avg m
CROSS JOIN group_avg g
WHERE m.avg_score > g.avg_score;
```

**Example output** (5 of the 8 members beat the group average of 73.5625):

| member_id | personal_avg | group_avg |
|---|---|---|
| 1 (Brian) | 78.5 | 73.5625 |
| 2 (Grace) | 89.0 | 73.5625 |
| 4 (Amina) | 80.0 | 73.5625 |
| 5 (Felix) | 93.0 | 73.5625 |
| 7 (David) | 81.5 | 73.5625 |

Two CTEs, defined one after another separated by a comma, each doing its own aggregation at a different grain — one row per member in the first, one row overall in the second — then combined in the final query. This is the kind of multi-step question a single `GROUP BY` can't answer alone, because it needs both the group-level number and the member-level number available at the same time.

> ⚠️ **Mistake I made:** writing `COUNT() AS* totaltrips_` inside a CTE — `COUNT()` with nothing inside the parentheses isn't valid, it needs either `COUNT(*)` or a specific column, and the misplaced `*` after `AS` was a stray typo. It failed immediately with a syntax error. But there was a second bug layered under it: the CTE defined the column as `totaltrips_`, while the outer query referenced `dtc.total_trips_` — an extra underscore in a different spot, which PostgreSQL treats as a completely different name. Even after fixing the `COUNT()` syntax, that mismatch alone would have raised `column "total_trips_" does not exist`.
>
> **Fixed version**, finding the 3 busiest drivers by trip count:
> ```sql
> WITH driver_trip_counts AS (
>     SELECT driver_id, COUNT(*) AS total_trips
>     FROM safari.trips
>     GROUP BY driver_id
> )
> SELECT dtc.driver_id, d.driver_name, d.car_model, dtc.total_trips
> FROM driver_trip_counts dtc
> JOIN safari.drivers d ON d.driver_id = dtc.driver_id
> ORDER BY dtc.total_trips DESC
> LIMIT 3;
> ```
> | driver_id | driver_name | car_model | total_trips |
> |---|---|---|---|
> | 2 | Peter Otieno | Toyota Premio | 6 |
> | 5 | Grace Achieng | Toyota Fielder | 6 |
> | 8 | Brian Kamau | Toyota Axio | 6 |
>
> (All three actually tie at 6 trips each, out of 40 total trips across 10 drivers — a coincidence, not something the query engineered.) Lesson: a CTE's column alias has to be typed identically everywhere it's referenced afterward — SQL doesn't do fuzzy matching or infer that `totaltrips_` and `total_trips_` were meant to be the same thing.

## Subquery vs. CTE — When to Use Each

| | Subquery | CTE |
|---|---|---|
| Reused in the same query more than once | Has to be repeated / rewritten each time | Defined once, referenced by name as many times as needed |
| Readability with multiple steps | Nests inward, gets harder to read as steps stack | Reads top-to-bottom, one named step at a time |
| Best for | A single, simple, one-off calculation | Anything needing 2+ logical steps, or reused more than once |

## Quick Reference

| Task | Command |
|---|---|
| Only matching rows from both tables | `A INNER JOIN B ON A.key = B.key` |
| All rows from the left table, matched or not | `A LEFT JOIN B ON A.key = B.key` |
| Filter for "no match found" after a LEFT JOIN | `WHERE right_table.column IS NULL` |
| Count actual matches (not placeholder NULL rows) | `COUNT(right_table.column)`, not `COUNT(*)` |
| Query nested inside another query | `WHERE col > (SELECT ...)` |
| Named, reusable temporary result set | `WITH name AS (SELECT ...) SELECT ... FROM name;` |
| Attach a single computed value to every row | `CROSS JOIN` a 1-row CTE |
