# 05 — Window Functions

This topic wasn't in the original coursework — I added it deliberately, since it's the line between "can write a SELECT" and "can do real analytical work" on a recruiter's checklist. Everything below is built fresh, using the same `safari` and `study_group` datasets from file 04, computed by hand rather than borrowed from a tutorial's generic example table.

## Why Window Functions Exist

`GROUP BY` has one hard limitation: it collapses rows. Ask for the average score per quiz, and you get one row per quiz — the individual scores that made up that average are gone from the result. Most of the time that's fine. But sometimes you want both things at once: each individual row, *and* some aggregate calculated across a group it belongs to, sitting right next to it in the same row. That's what a window function does. It doesn't collapse anything. Every original row survives, with an extra column showing a calculation performed over a "window" of related rows.

## The OVER() Clause

```sql
SELECT column1,
       window_function(column2) OVER (
           [PARTITION BY column3]
           [ORDER BY column4]
       ) AS new_column
FROM table_name;
```

`OVER()` is what turns an ordinary aggregate function into a window function. Write `AVG(score)` alone in a `SELECT` list next to non-aggregated columns and PostgreSQL will complain — it doesn't know how to reconcile one row's worth of detail with a function that wants to summarize many rows. Add `OVER()` after it, even empty, and the rule changes: now the function runs over some window of rows (by default, the entire result set) without forcing everything else to collapse down to match it.

## PARTITION BY: Resetting the Window Per Group

`PARTITION BY` splits the window into separate sections, the same way `GROUP BY` splits a table into groups — except here, nothing collapses. The aggregate just resets and recalculates for each partition.

**Reference data** — `study_group.quiz_scores`, 16 rows, 8 members across two quizzes:

```sql
SELECT member_id, quiz_number, score,
       ROUND(AVG(score) OVER (PARTITION BY quiz_number), 2) AS quiz_avg
FROM study_group.quiz_scores
ORDER BY quiz_number, member_id;
```

**Example output** (partial — showing both quiz groups):

| member_id | quiz_number | score | quiz_avg |
|---|---|---|---|
| 1 | 1 | 72 | 71.88 |
| 2 | 1 | 90 | 71.88 |
| 3 | 1 | 55 | 71.88 |
| ... | 1 | ... | 71.88 |
| 1 | 2 | 85 | 75.25 |
| 2 | 2 | 88 | 75.25 |
| 3 | 2 | 63 | 75.25 |
| ... | 2 | ... | 75.25 |

Every quiz-1 row carries 71.88 (the quiz-1 average across all 8 members), and every quiz-2 row carries 75.25. Sixteen rows go in, sixteen rows come out — nothing merged, nothing lost. Compare that to what `GROUP BY quiz_number` would have returned here: just two rows, one per quiz, with no individual scores left at all. Same underlying arithmetic, genuinely different shape of result.

## Aggregate Window Functions

`SUM()`, `AVG()`, `COUNT()`, `MAX()`, and `MIN()` all work as window functions once `OVER()` is attached — same functions from file 03, new behavior.

The clearest use case for this is a **running total**, something `GROUP BY` genuinely cannot produce on its own. Take driver Grace Achieng's six trips, ordered by date:

```sql
SELECT trip_date, fare,
       SUM(fare) OVER (ORDER BY trip_date, trip_id) AS running_total
FROM safari.trips
WHERE driver_id = 5
ORDER BY trip_date, trip_id;
```

**Example output:**

| trip_date | fare | running_total |
|---|---|---|
| 2024-01-14 | 1046.00 | 1046.00 |
| 2024-01-20 | 1056.00 | 2102.00 |
| 2024-01-20 | 517.00 | 2619.00 |
| 2024-02-12 | 657.00 | 3276.00 |
| 2024-02-15 | 1376.00 | 4652.00 |
| 2024-02-20 | 618.00 | 5270.00 |

Each row's `running_total` is the sum of every fare up to and including that row, in date order. This only works because of the `ORDER BY` inside `OVER()` — it tells the window "for this row, only sum what came before and including it," rather than summing the whole set every time. Drop the `ORDER BY` from inside `OVER()`, and every row would show the same number: the full six-trip total, 5270.00, repeated six times, because with nothing to order by, the entire partition counts as the window for every single row.

## Ranking Window Functions

Four functions exist specifically to assign a rank or position to each row: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, and `PERCENT_RANK()`. They differ only in how they handle ties, and the differences genuinely matter — using the wrong one silently produces a misleading result.

**Reference data** — average rider rating per driver, computed from all 40 trips in `safari.trips`:

```sql
WITH driver_avg_rating AS (
    SELECT driver_id, ROUND(AVG(rider_rating), 2) AS avg_rating
    FROM safari.trips
    GROUP BY driver_id
)
SELECT d.driver_name, dar.avg_rating,
       ROW_NUMBER() OVER (ORDER BY dar.avg_rating DESC) AS row_num,
       RANK()       OVER (ORDER BY dar.avg_rating DESC) AS rank_,
       DENSE_RANK() OVER (ORDER BY dar.avg_rating DESC) AS dense_rank_
FROM driver_avg_rating dar
JOIN safari.drivers d ON d.driver_id = dar.driver_id
ORDER BY dar.avg_rating DESC;
```

**Example output** (real ties, not staged for the example):

| driver_name | avg_rating | row_num | rank_ | dense_rank_ |
|---|---|---|---|---|
| Grace Achieng | 3.50 | 1 | 1 | 1 |
| Mercy Njeri | 3.50 | 2 | 1 | 1 |
| James Mwangi | 3.00 | 3 | 3 | 2 |
| Susan Wambui | 3.00 | 4 | 3 | 2 |
| David Kiptoo | 3.00 | 5 | 3 | 2 |
| Faith Wanjiru | 2.75 | 6 | 6 | 3 |
| Kevin Mutua | 2.60 | 7 | 7 | 4 |
| Hassan Ali | 2.50 | 8 | 8 | 5 |
| Brian Kamau | 2.50 | 9 | 8 | 5 |
| Peter Otieno | 2.33 | 10 | 10 | 6 |

Grace Achieng and Mercy Njeri are genuinely tied at 3.50 — that's a real result from the trip data, not a constructed example. Look at what each function does with it:

- **`ROW_NUMBER()`** never ties. Grace gets 1, Mercy gets 2, purely because a decision has to be made about who comes first, even when the underlying values are identical. Useful for "give me exactly one row per group," dangerous if you need the ranking itself to mean something, since it invents a distinction the data doesn't actually support.
- **`RANK()`** lets the tie stand — both Grace and Mercy get rank 1 — but then skips rank 2 entirely. The next driver down gets rank 3, because two drivers already occupy the ranks above.
- **`DENSE_RANK()`** also lets the tie stand at 1, but doesn't skip anything afterward — the next distinct value gets rank 2. This is usually the one people actually want when they say "rank," since "1st, 1st, 3rd" tends to read as a bug to anyone unfamiliar with `RANK()`'s specific behavior.

```sql
SELECT d.driver_name, dar.avg_rating,
       ROUND(PERCENT_RANK() OVER (ORDER BY dar.avg_rating DESC), 3) AS percent_rank
FROM driver_avg_rating dar
JOIN safari.drivers d ON d.driver_id = dar.driver_id
ORDER BY dar.avg_rating DESC;
```

**Example output:**

| driver_name | avg_rating | percent_rank |
|---|---|---|
| Grace Achieng | 3.50 | 0.000 |
| Mercy Njeri | 3.50 | 0.000 |
| James Mwangi | 3.00 | 0.222 |
| Susan Wambui | 3.00 | 0.222 |
| David Kiptoo | 3.00 | 0.222 |
| Faith Wanjiru | 2.75 | 0.556 |
| Kevin Mutua | 2.60 | 0.667 |
| Hassan Ali | 2.50 | 0.778 |
| Brian Kamau | 2.50 | 0.778 |
| Peter Otieno | 2.33 | 1.000 |

`PERCENT_RANK()` answers a slightly different question than the others: not "what position is this row in," but "what fraction of the group ranks at or below this row." The formula is `(rank - 1) / (total rows - 1)` — the top row always lands at 0.000, the bottom row always lands at 1.000, and everything else falls somewhere in between based on its `RANK()` position. It's built for the moment someone asks "is this driver in the top 20%?" rather than "what number is this driver."

## LAG and LEAD: Comparing a Row to Its Neighbor

`LAG()` pulls in a value from a previous row. `LEAD()` pulls in a value from a row ahead. Both are built for exactly one kind of question: "how does this row compare to the one before or after it," which is otherwise awkward to answer without joining a table to itself.

```sql
SELECT trip_date, fare,
       LAG(fare) OVER (ORDER BY trip_date, trip_id) AS previous_fare,
       fare - LAG(fare) OVER (ORDER BY trip_date, trip_id) AS fare_change
FROM safari.trips
WHERE driver_id = 5
ORDER BY trip_date, trip_id;
```

**Example output** (Grace Achieng's six trips again, same order as the running-total example):

| trip_date | fare | previous_fare | fare_change |
|---|---|---|---|
| 2024-01-14 | 1046.00 | NULL | NULL |
| 2024-01-20 | 1056.00 | 1046.00 | 10.00 |
| 2024-01-20 | 517.00 | 1056.00 | -539.00 |
| 2024-02-12 | 657.00 | 517.00 | 140.00 |
| 2024-02-15 | 1376.00 | 657.00 | 719.00 |
| 2024-02-20 | 618.00 | 1376.00 | -758.00 |

The first row's `previous_fare` is `NULL` — there's nothing before it to look back at, and `LAG()` doesn't invent a value, it just returns nothing. `LEAD()` works the same way in reverse, pulling the *next* row's value instead, with the last row landing on `NULL` since nothing comes after it.

## Frame Clauses: Controlling the Window's Exact Size

Everything so far has used one of two implicit windows: the whole partition, or — once `ORDER BY` gets involved — everything from the start up through the current row. A frame clause makes that boundary explicit, and it's what makes something like a moving average possible.

```sql
SELECT trip_date, fare,
       ROUND(AVG(fare) OVER (
           ORDER BY trip_date, trip_id
           ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
       ), 2) AS moving_avg_2trip
FROM safari.trips
WHERE driver_id = 5
ORDER BY trip_date, trip_id;
```

**Example output:**

| trip_date | fare | moving_avg_2trip |
|---|---|---|
| 2024-01-14 | 1046.00 | 1046.00 |
| 2024-01-20 | 1056.00 | 1051.00 |
| 2024-01-20 | 517.00 | 786.50 |
| 2024-02-12 | 657.00 | 587.00 |
| 2024-02-15 | 1376.00 | 1016.50 |
| 2024-02-20 | 618.00 | 997.00 |

`ROWS BETWEEN 1 PRECEDING AND CURRENT ROW` tells the window "only look at the row right before this one, plus this one" — a 2-row moving average. The first row has no prior row to include, so it falls back to just itself. Change `1 PRECEDING` to `2 PRECEDING` and it becomes a 3-row moving average instead; the frame clause is what tunes that width.

## FIRST_VALUE and LAST_VALUE

These pull a specific row's value from within the window — the first row or the last row, by whatever `ORDER BY` defines "first" and "last" to mean.

```sql
SELECT trip_date, fare,
       FIRST_VALUE(fare) OVER (ORDER BY trip_date, trip_id) AS earliest_fare,
       LAST_VALUE(fare) OVER (
           ORDER BY trip_date, trip_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS latest_fare
FROM safari.trips
WHERE driver_id = 5
ORDER BY trip_date, trip_id;
```

**Example output:**

| trip_date | fare | earliest_fare | latest_fare |
|---|---|---|---|
| 2024-01-14 | 1046.00 | 1046.00 | 618.00 |
| 2024-01-20 | 1056.00 | 1046.00 | 618.00 |
| 2024-01-20 | 517.00 | 1046.00 | 618.00 |
| 2024-02-12 | 657.00 | 1046.00 | 618.00 |
| 2024-02-15 | 1376.00 | 1046.00 | 618.00 |
| 2024-02-20 | 618.00 | 1046.00 | 618.00 |

That explicit `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` on `LAST_VALUE` isn't decoration — it's load-bearing. Without it, `LAST_VALUE` inherits the same default frame as everything else once `ORDER BY` is present: "start of partition through current row." Which means, without that explicit frame, `LAST_VALUE` doesn't return the last row's fare at all — it returns the *current* row's own fare every time, since as far as the default frame is concerned, the current row always is the last row it's allowed to see. This is one of the more common window-function bugs, because the query runs fine and returns a plausible-looking column full of numbers — it just quietly isn't the number anyone meant to compute.

## NTILE: Splitting Rows into Buckets

`NTILE(n)` divides the ordered rows into `n` roughly equal groups and labels each row with which group it landed in — built for tasks like "split customers into quartiles" or "top third / middle third / bottom third."

```sql
WITH driver_avg_rating AS (
    SELECT driver_id, ROUND(AVG(rider_rating), 2) AS avg_rating
    FROM safari.trips
    GROUP BY driver_id
)
SELECT d.driver_name, dar.avg_rating,
       NTILE(4) OVER (ORDER BY dar.avg_rating DESC) AS rating_tier
FROM driver_avg_rating dar
JOIN safari.drivers d ON d.driver_id = dar.driver_id
ORDER BY dar.avg_rating DESC;
```

**Example output** (10 drivers split into 4 tiers):

| driver_name | avg_rating | rating_tier |
|---|---|---|
| Grace Achieng | 3.50 | 1 |
| Mercy Njeri | 3.50 | 1 |
| James Mwangi | 3.00 | 1 |
| Susan Wambui | 3.00 | 2 |
| David Kiptoo | 3.00 | 2 |
| Faith Wanjiru | 2.75 | 2 |
| Kevin Mutua | 2.60 | 3 |
| Hassan Ali | 2.50 | 3 |
| Brian Kamau | 2.50 | 4 |
| Peter Otieno | 2.33 | 4 |

Ten rows split across four tiers can't come out perfectly even — `NTILE()` puts the extra rows into the earlier tiers rather than the later ones, which is why tier 1 and tier 2 got 3 rows each here while tier 3 and tier 4 got 2 each. Worth knowing that going in, since "roughly equal" sometimes means a difference of one row per group, not a guarantee of an exact split.

## The WHERE Gotcha

A window function's result can't be filtered with `WHERE` in the same query it's calculated in:

```sql
-- This fails
SELECT driver_id, RANK() OVER (ORDER BY avg_rating DESC) AS rank_
FROM driver_avg_rating
WHERE rank_ = 1;
```

That fails because of the execution order covered back in file 02 — `WHERE` runs before `SELECT`, and a window function's result is only computed as part of `SELECT`. At the point `WHERE` executes, `rank_` doesn't exist yet to filter on, the same underlying reason `HAVING` exists separately from `WHERE` for aggregates. The fix is the same pattern used throughout file 04 — wrap it in a CTE, then filter the outer query:

```sql
WITH ranked_drivers AS (
    SELECT driver_id, RANK() OVER (ORDER BY avg_rating DESC) AS rank_
    FROM driver_avg_rating
)
SELECT * FROM ranked_drivers WHERE rank_ = 1;
```

## Window Functions vs. GROUP BY

| | `GROUP BY` | Window function (`OVER()`) |
|---|---|---|
| Row count in the result | One row per group | Same as the original — nothing collapses |
| Access to individual row detail | Lost once grouped | Kept — the aggregate is just an extra column |
| Can produce a running total | No, not directly | Yes — this is one of its main use cases |
| Can rank individual rows | No | Yes — that's the entire point of the ranking functions |

## Common Pitfalls

- **Forgetting `PARTITION BY` entirely.** Without it, the whole result set counts as a single window — an average that was meant to be "per quiz" quietly becomes "across everyone," and nothing in the syntax warns about it.
- **Forgetting `ORDER BY` inside a running total.** As shown above, `SUM() OVER (PARTITION BY x)` with no `ORDER BY` gives every row in the partition the same full total, not a running one. The `ORDER BY` inside `OVER()` is what makes "running" mean anything.
- **Using `LAST_VALUE()` without an explicit frame.** Covered in detail above — without `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`, it silently returns the current row's own value instead of the partition's actual last value.
- **Trying to filter a window function's result with `WHERE` in the same query.** It isn't computed yet at that point in execution order — filter it from an outer query wrapped around a CTE instead.
- **Reaching for `RANK()` out of habit when `DENSE_RANK()` is what the question actually needs**, or vice versa. Worth pausing before writing either one and asking whether skipped rank numbers after a tie are actually the intended behavior, or just what the function happens to default to.

## Quick Reference

| Task | Function |
|---|---|
| Attach a group aggregate without collapsing rows | `AVG(col) OVER (PARTITION BY group_col)` |
| Running total, ordered | `SUM(col) OVER (ORDER BY sort_col)` |
| Moving average over a fixed window | `AVG(col) OVER (ORDER BY sort_col ROWS BETWEEN n PRECEDING AND CURRENT ROW)` |
| Compare to the previous row | `LAG(col) OVER (ORDER BY sort_col)` |
| Compare to the next row | `LEAD(col) OVER (ORDER BY sort_col)` |
| First value in the window | `FIRST_VALUE(col) OVER (ORDER BY sort_col)` |
| Last value in the window (needs explicit frame) | `LAST_VALUE(col) OVER (ORDER BY sort_col ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)` |
| Split rows into n roughly equal buckets | `NTILE(n) OVER (ORDER BY sort_col)` |
| Unique sequential number per row, ties broken arbitrarily | `ROW_NUMBER() OVER (ORDER BY col)` |
| Rank with gaps after ties | `RANK() OVER (ORDER BY col)` |
| Rank with no gaps after ties | `DENSE_RANK() OVER (ORDER BY col)` |
| Relative position as a percentage | `PERCENT_RANK() OVER (ORDER BY col)` |
| Filter on a window function's result | Wrap in a CTE, filter the outer query |
