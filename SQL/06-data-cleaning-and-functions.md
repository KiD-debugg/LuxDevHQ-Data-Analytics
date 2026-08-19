# 06 — Data Cleaning & Functions

Everything up to this point assumed clean data — tables where every value was already exactly what it claimed to be. Real data is rarely that polite. This file works through a single case study: a messy HR import from a fictional company, Zawadi Corp, and the string, number, and date functions used to clean it into something trustworthy.

## The Raw Data

```sql
CREATE TABLE zawadi.new_employees_import(
    import_id      SERIAL PRIMARY KEY,
    raw_name       VARCHAR(100),
    raw_email      VARCHAR(100),
    raw_phone      VARCHAR(30),
    raw_department VARCHAR(30),
    job_title      VARCHAR(50),
    salary         NUMERIC(10,2),
    hire_date      DATE
);
```

| import_id | raw_name | raw_phone | raw_department |
|---|---|---|---|
| 1 | `  JAMES OMONDI  ` | `0733-000-013` | `sales` |
| 2 | `faith wanjala` | `0733 000 014` | `IT ` |
| 3 | `Peter   Ndungu` | `N/A` | ` Finance` |
| 4 | `Grace Akinyi` | `0733000015` | `hr` |
| 5 | `James Omondi` | `0733-000-013` | `Sales` |
| 6 | `David Kimani` | `unknown` | `IT` |
| 7 | `Susan  Wafula` | `0733 000 017` | `Finance ` |
| 8 | `JAMES OMONDI` | `0733000013` | `SALES` |
| 9 | `Esther Njoki` | *(empty)* | ` HR` |
| 10 | `Michael Owino` | `0733-000-020` | `sales ` |

Look closely at rows 1, 5, and 8. Different spacing, different casing, different phone formats — but they're the same person, and even the phone number confirms it once the punctuation is stripped out. That's the real reason this section exists: an import like this one hides duplicates behind formatting until someone cleans it.

## String Functions

### TRIM — and What It Doesn't Fix

`TRIM()` removes leading and trailing whitespace. It does not touch anything in the middle of a string, which surprises people the first time they hit it.

```sql
SELECT import_id, raw_name, LENGTH(raw_name) AS len,
       TRIM(raw_name) AS trimmed_name, LENGTH(TRIM(raw_name)) AS trimmed_len
FROM zawadi.new_employees_import
WHERE import_id IN (1, 3, 7);
```

**Example output:**

| import_id | raw_name | len | trimmed_name | trimmed_len |
|---|---|---|---|---|
| 1 | `  JAMES OMONDI  ` | 16 | `JAMES OMONDI` | 12 |
| 3 | `Peter   Ndungu` | 14 | `Peter   Ndungu` | 14 |
| 7 | `Susan  Wafula` | 13 | `Susan  Wafula` | 13 |

Row 1 loses 4 characters — 2 leading spaces, 2 trailing. Rows 3 and 7 lose nothing at all, because their extra spacing sits *between* words, not at the edges — `TRIM()` has nothing to remove there. Catching those requires a different tool:

```sql
-- Find rows with 2+ consecutive spaces anywhere in the name
SELECT import_id, raw_name
FROM zawadi.new_employees_import
WHERE raw_name LIKE '%  %';
```

**Example output** (checked after the TRIM update already ran, so row 1's edge-spacing is gone — this only catches what TRIM couldn't):

| import_id | raw_name |
|---|---|
| 3 | `Peter   Ndungu` |
| 7 | `Susan  Wafula` |

### UPPER, LOWER, and INITCAP — Standardizing Case

```sql
SELECT import_id, raw_email, LOWER(TRIM(raw_email)) AS clean_email
FROM zawadi.new_employees_import
WHERE import_id IN (1, 4);
```

**Example output:**

| import_id | raw_email | clean_email |
|---|---|---|
| 1 | `  JAMES.OMONDI@ZAWADICORP.COM  ` | `james.omondi@zawadicorp.com` |
| 4 | `GRACE.AKINYI@zawadicorp.com` | `grace.akinyi@zawadicorp.com` |

`INITCAP()` capitalizes the first letter of every word — useful for names, since it doesn't matter whether the source data arrived in ALL CAPS or all lowercase:

```sql
SELECT import_id, raw_name, INITCAP(TRIM(raw_name)) AS clean_name
FROM zawadi.new_employees_import
WHERE import_id IN (1, 2, 8);
```

**Example output:**

| import_id | raw_name | clean_name |
|---|---|---|
| 1 | `  JAMES OMONDI  ` | `James Omondi` |
| 2 | `faith wanjala` | `Faith Wanjala` |
| 8 | `JAMES OMONDI` | `James Omondi` |

Rows 1 and 8 now produce the exact same cleaned name — which is precisely the point. Before cleaning, three different strings; after, one clear duplicate.

> ⚠️ **A pitfall worth knowing:** `INITCAP()` treats every word the same way, which breaks for acronyms.
> ```sql
> SELECT raw_department, INITCAP(TRIM(raw_department)) AS clean_dept
> FROM zawadi.new_employees_import
> WHERE import_id IN (4, 9);
> ```
> | raw_department | clean_dept |
> |---|---|
> | `hr` | `Hr` |
> | ` HR` | `Hr` |
>
> `HR` should stay `HR`, not become `Hr` — `INITCAP()` has no concept of "this word is an abbreviation." Columns like department codes usually need an explicit `CASE WHEN` mapping instead of a blind case-conversion function, exactly like the aisle-mapping example back in file 03.

### REGEXP_REPLACE — Stripping Everything Except Digits

Phone numbers arrived in at least four different formats. `REGEXP_REPLACE(text, pattern, replacement, 'g')` matches a pattern and replaces every occurrence (the `'g'` flag means "globally," not just the first hit) — here, the pattern `[^0-9]` means "anything that is *not* a digit."

```sql
SELECT import_id, raw_phone, REGEXP_REPLACE(raw_phone, '[^0-9]', '', 'g') AS clean_phone
FROM zawadi.new_employees_import;
```

**Example output** (all 10 rows):

| import_id | raw_phone | clean_phone |
|---|---|---|
| 1 | `0733-000-013` | `0733000013` |
| 2 | `0733 000 014` | `0733000014` |
| 3 | `N/A` | *(empty string)* |
| 4 | `0733000015` | `0733000015` |
| 5 | `0733-000-013` | `0733000013` |
| 6 | `unknown` | *(empty string)* |
| 7 | `0733 000 017` | `0733000017` |
| 8 | `0733000013` | `0733000013` |
| 9 | *(empty)* | *(empty string)* |
| 10 | `0733-000-020` | `0733000020` |

Rows 1, 5, and 8 all clean down to the identical number `0733000013` — the phone data confirms what the name cleanup already suggested: these three rows are one person.

> ⚠️ **A second pitfall in the same result:** `'N/A'` and `'unknown'` both clean down to an empty string, same as a genuinely blank entry. `REGEXP_REPLACE()` doesn't know the difference between "this field had no digits because it was never filled in" and "this field had no digits because someone typed a word instead of leaving it blank" — both just vanish. An empty string isn't the same as `NULL`, either; a column can be full of empty strings and still pass a `WHERE column IS NOT NULL` check. Whether that matters depends on what happens next — usually, this is exactly the moment to run the result through `COALESCE()` or a follow-up `UPDATE ... SET clean_phone = NULL WHERE clean_phone = ''`, so "no phone number" is represented one consistent way instead of several.

## Number Functions

`ROUND()`, `CEIL()`, and `FLOOR()` all take a decimal number and produce a whole or fixed-precision number — the difference is in which direction they round.

```sql
SELECT raw_name, salary,
       ROUND(salary / 21.0, 2) AS est_daily_rate,
       CEIL(salary / 21.0) AS daily_rate_ceil,
       FLOOR(salary / 21.0) AS daily_rate_floor
FROM zawadi.new_employees_import
WHERE import_id IN (1, 2, 3);
```

**Example output** (estimated daily pay, assuming a 21 working-day month):

| raw_name | salary | est_daily_rate | daily_rate_ceil | daily_rate_floor |
|---|---|---|---|---|
| JAMES OMONDI | 66000.00 | 3142.86 | 3143 | 3142 |
| faith wanjala | 96000.00 | 4571.43 | 4572 | 4571 |
| Peter Ndungu | 79000.00 | 3761.90 | 3762 | 3761 |

`ROUND()` rounds to the nearest value at whatever precision is asked for — 2 decimal places here. `CEIL()` always rounds up regardless of how close the decimal is to the lower whole number; `FLOOR()` always rounds down regardless of how close it is to the upper one. They're not "smarter" or "safer" versions of `ROUND()` — they're deliberately one-directional, which matters when the direction itself is the point (rounding *up* when estimating a cost, for instance, so the estimate never comes in short).

## NULL Handling: COALESCE

`COALESCE(a, b, c, ..., default)` returns the first value in the list that isn't `NULL`, checked left to right. It's built for exactly the situation where several columns could hold the answer, in a preferred order.

**Reference data** — `greenwood_academy.customers`, a small table with three separate phone columns:

| customer_id | mobile_phone | work_phone | home_phone |
|---|---|---|---|
| 1 | 555-0101 | 555-0201 | 555-0301 |
| 2 | NULL | 555-0201 | 555-0301 |
| 3 | NULL | NULL | 555-0303 |
| 4 | NULL | NULL | NULL |

```sql
SELECT customer_id,
       COALESCE(mobile_phone, work_phone, home_phone, 'No phone on file') AS contact_number
FROM greenwood_academy.customers;
```

**Example output:**

| customer_id | contact_number |
|---|---|
| 1 | 555-0101 |
| 2 | 555-0201 |
| 3 | 555-0303 |
| 4 | No phone on file |

Customer 1 has all three numbers, so the first one wins. Customer 2's mobile is missing, so it falls through to work. Customer 4 has nothing at all, so every column falls through and the final fallback — a literal string, not a column — catches it. That final argument doesn't have to be a plain string; it's just as valid to fall back to another column, or to `NULL` itself if no fallback text is wanted.

## Date and Time Functions

```sql
SELECT CURRENT_DATE;                    -- today's date, no time component
SELECT NOW();                           -- today's date and time
SELECT AGE(CURRENT_DATE, hire_date) AS tenure
FROM zawadi.new_employees_import
WHERE import_id IN (1, 2, 10);
```

**Example output** (computed as of the date this document was written, August 19, 2026 — `AGE()` is relative to *today*, so this table's numbers shift every day the query actually runs):

| import_id | hire_date | tenure (as of 2026-08-19) |
|---|---|---|
| 1 | 2024-01-10 | 2 years 7 mons 9 days |
| 2 | 2024-02-05 | 2 years 6 mons 14 days |
| 10 | 2024-04-01 | 2 years 4 mons 18 days |

```sql
SELECT import_id, hire_date, EXTRACT(YEAR FROM hire_date) AS hire_year
FROM zawadi.new_employees_import
WHERE import_id IN (1, 2, 10);
```

**Example output:**

| import_id | hire_date | hire_year |
|---|---|---|
| 1 | 2024-01-10 | 2024 |
| 2 | 2024-02-05 | 2024 |
| 10 | 2024-04-01 | 2024 |

`AGE()` returns a readable interval — years, months, and days, already broken apart. `EXTRACT()` pulls out exactly one named piece of a date (`YEAR`, `MONTH`, `DAY`, and so on) as a plain number, which is what's needed when the goal is filtering or grouping by that piece rather than displaying a human-readable span.

> ⚠️ **Mistake I made:** trying to backfill a `guardian_phone` value onto rows that already existed, using `INSERT INTO students (student_id, guardian_phone) VALUES (1, '...'), (2, '...')`. It failed immediately — `student_id` 1 and 2 already existed as rows, and `student_id` is the primary key, so `INSERT` tried to create brand-new rows with IDs that were already taken. `INSERT` only ever adds new rows; it can't reach into a row that already exists and fill in one more column. The actual fix was switching to `UPDATE`, which is built for changing existing rows rather than creating new ones:
> ```sql
> UPDATE greenwood_academy.students
> SET guardian_phone = '07' || (20000000 + student_id)
> WHERE student_id IN (1, 2, 3, 4, 5, 6, 7, 8);
> ```
> Lesson: if a row already exists, changing it is always `UPDATE`, never `INSERT` — `INSERT` colliding with an existing primary key is a data integrity error, not a formatting one, and no amount of adjusting the `VALUES` syntax would have fixed it.

## Quick Reference

| Task | Function |
|---|---|
| Remove leading/trailing whitespace only | `TRIM(text)` |
| Convert case | `UPPER(text)`, `LOWER(text)`, `INITCAP(text)` |
| Count characters | `LENGTH(text)` |
| Extract part of a string | `SUBSTRING(text, start, length)` |
| Join strings together | `CONCAT(a, b, ...)` or `a \|\| b` |
| Swap one substring for another | `REPLACE(text, find, replacement)` |
| Pattern-based find-and-replace | `REGEXP_REPLACE(text, pattern, replacement, 'g')` |
| Round to n decimal places | `ROUND(number, n)` |
| Always round up / down | `CEIL(number)` / `FLOOR(number)` |
| First non-NULL value from a list | `COALESCE(a, b, ..., default)` |
| Today's date / date and time | `CURRENT_DATE` / `NOW()` |
| Readable span between two dates | `AGE(date1, date2)` |
| One specific piece of a date | `EXTRACT(field FROM date)` |
| Add a value to an existing row | `UPDATE`, never `INSERT` |
