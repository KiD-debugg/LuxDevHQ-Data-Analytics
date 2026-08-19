# 02 — Filtering & Sorting Data

Every query so far pulled back a whole table. This is where that changes: narrowing results down with `WHERE`, combining conditions, matching text patterns, and controlling row order. Most examples here use `duka.duka_products` — a small shop inventory table (product name, category, price, stock level, supplier).

**Reference data** (`duka.duka_products`, 11 rows):

| id | product_name | category | price | stock | supplier |
|---|---|---|---|---|---|
| 1 | Unga wa ngano | Grains & Cereals | 180.00 | 50 | Kenya Grain Millers |
| 2 | Mchele Pishori | Grains & Cereals | 235.00 | 60 | Kenya Grain Millers |
| 3 | Sukari | Grains & Cereals | 165.00 | 90 | Kenya Grain Millers |
| 4 | Maziwa Fresh | Dairy | 60.00 | 30 | Brookside Dairy |
| 5 | Mtindi | Dairy | 90.00 | 20 | Brookside Dairy |
| 6 | Chai ya Majani | Beverages | 250.00 | 25 | Kenya Beverages Ltd |
| 7 | Soda | Beverages | 70.00 | 45 | Kenya Beverages Ltd |
| 8 | Sabuni ya kufulia | Household | 55.00 | 35 | Metro Wholesalers |
| 9 | Mkate | Snacks & Bakery | 65.00 | 20 | Britania Ltd |
| 10 | Maharagwe | Grains & Cereals | 200.00 | 35 | Kenya Grain Millers |
| 11 | Unga wa Dola | Grains & Cereals | 195.00 | 45 | Kenya Grain Millers |

## WHERE and Comparison Operators

| Operator | Meaning |
|---|---|
| `=` | equal to |
| `>` / `<` | greater than / less than |
| `>=` / `<=` | greater than or equal / less than or equal |
| `<>` or `!=` | not equal to |

```sql
SELECT product_name, price
FROM duka.duka_products
WHERE price > 150;
```

**Example output:**

| product_name | price |
|---|---|
| Unga wa ngano | 180.00 |
| Mchele Pishori | 235.00 |
| Sukari | 165.00 |
| Chai ya Majani | 250.00 |
| Maharagwe | 200.00 |
| Unga wa Dola | 195.00 |

## Logical Operators: AND, OR, NOT

```sql
-- AND: both conditions must be true
SELECT product_name, category, price
FROM duka.duka_products
WHERE category = 'Dairy' AND price > 70;
```

**Example output:**

| product_name | category | price |
|---|---|---|
| Mtindi | Dairy | 90.00 |

> ⚠️ **Mistake I made:** mixing `AND` and `OR` in one `WHERE` clause without parentheses. SQL evaluates `AND` before `OR` — same rule as multiplication before addition in arithmetic — so the two operators don't just read left to right the way I assumed.
>
> **Wrong** — I wanted "Dairy products priced under 70, or anything over 85," but wrote:
> ```sql
> SELECT product_name, category, price
> FROM duka.duka_products
> WHERE category = 'Dairy' AND price < 70 OR price > 85;
> ```
> This is actually parsed as `(category = 'Dairy' AND price < 70) OR (price > 85)` — the second half ignores category completely:
>
> | product_name | category | price |
> |---|---|---|
> | Maziwa Fresh | Dairy | 60.00 |
> | Unga wa ngano | Grains & Cereals | 180.00 |
> | Mchele Pishori | Grains & Cereals | 235.00 |
> | Sukari | Grains & Cereals | 165.00 |
> | Mtindi | Dairy | 90.00 |
> | Chai ya Majani | Beverages | 250.00 |
> | Maharagwe | Grains & Cereals | 200.00 |
> | Unga wa Dola | Grains & Cereals | 195.00 |
>
> Eight rows, most of them not even Dairy — clearly wrong.
>
> **Fixed** — parentheses force the `OR` to be evaluated first, keeping both conditions scoped to Dairy:
> ```sql
> SELECT product_name, category, price
> FROM duka.duka_products
> WHERE category = 'Dairy' AND (price < 70 OR price > 85);
> ```
> | product_name | category | price |
> |---|---|---|
> | Maziwa Fresh | Dairy | 60.00 |
> | Mtindi | Dairy | 90.00 |
>
> Two rows, both correctly Dairy. Lesson: whenever `AND` and `OR` appear in the same `WHERE` clause, add parentheses even if the current result happens to look right — the ambiguity is a bug waiting to surface the next time the data changes.

## BETWEEN (Range Operator)

```sql
SELECT product_name, price
FROM duka.duka_products
WHERE price BETWEEN 60 AND 200
ORDER BY price;
```

**Example output:**

| product_name | price |
|---|---|
| Maziwa Fresh | 60.00 |
| Mkate | 65.00 |
| Soda | 70.00 |
| Mtindi | 90.00 |
| Sukari | 165.00 |
| Unga wa ngano | 180.00 |
| Unga wa Dola | 195.00 |
| Maharagwe | 200.00 |

`BETWEEN 60 AND 200` is inclusive on both ends — it's shorthand for `price >= 60 AND price <= 200`, not a substitute for a different comparison.

## IN and NOT IN (Membership Operators)

`IN` replaces a chain of `OR` conditions checking the same column:

```sql
-- Instead of: WHERE category = 'Dairy' OR category = 'Household'
SELECT product_name, category
FROM duka.duka_products
WHERE category IN ('Dairy', 'Household');
```

**Example output:**

| product_name | category |
|---|---|
| Maziwa Fresh | Dairy |
| Mtindi | Dairy |
| Sabuni ya kufulia | Household |

```sql
SELECT product_name, supplier
FROM duka.duka_products
WHERE supplier NOT IN ('Kenya Grain Millers', 'Brookside Dairy');
```

**Example output:**

| product_name | supplier |
|---|---|
| Chai ya Majani | Kenya Beverages Ltd |
| Soda | Kenya Beverages Ltd |
| Sabuni ya kufulia | Metro Wholesalers |
| Mkate | Britania Ltd |

## LIKE and ILIKE (Pattern Matching)

Two wildcards: `%` matches any number of characters (including zero), `_` matches exactly one character. `LIKE` is case-sensitive, `ILIKE` is not.

```sql
-- Names starting with 'M'
SELECT product_name
FROM duka.duka_products
WHERE product_name LIKE 'M%';
```

**Example output:**

| product_name |
|---|
| Mchele Pishori |
| Maziwa Fresh |
| Mtindi |
| Mkate |
| Maharagwe |

```sql
-- Exactly one character, then 'kate'
SELECT product_name
FROM duka.duka_products
WHERE product_name LIKE '_kate';
```

**Example output:**

| product_name |
|---|
| Mkate |

`_` matches one character exactly — `'_kate'` would not match a name like "Pancake" (too many characters before "kate"), only something exactly one character longer than "kate" itself.

## ORDER BY and LIMIT

```sql
SELECT title, price
FROM book_store.books
ORDER BY price DESC
LIMIT 3;
```

**Example output** (3 most expensive books):

| title | price |
|---|---|
| Data Science Basics | 2200.00 |
| Database Design Principles | 2200.00 |
| Python for Data Analysis | 1800.00 |

`ORDER BY` runs before `LIMIT` cuts the list down — sorting an unordered result and then taking the top 3 gives a very different answer than taking any random 3 rows.

## Query Writing Order vs. Execution Order

These are not the same thing, and mixing them up is a common source of confusion:

| You write it in this order | The database runs it in this order |
|---|---|
| SELECT | FROM |
| FROM | WHERE |
| WHERE | GROUP BY |
| GROUP BY | HAVING |
| HAVING | SELECT |
| ORDER BY | ORDER BY |
| LIMIT | LIMIT |

This is why you can't reference a `SELECT` column alias inside the same query's `WHERE` clause — `WHERE` runs before `SELECT` even exists yet.
