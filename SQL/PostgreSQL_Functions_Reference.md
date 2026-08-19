# PostgreSQL Functions Reference

*String, number, and date & time functions — with syntax and examples.*

---

## String Functions

| Function | Purpose | Syntax | Example |
|---|---|---|---|
| `LENGTH` | Character count | `LENGTH(str)` | `LENGTH('hello')` → `5` |
| `LOWER` / `UPPER` | Case conversion | `LOWER(str)` / `UPPER(str)` | `LOWER('HI')` → `'hi'` |
| `CONCAT` / `\|\|` | Join strings | `CONCAT(a, b, ...)` or `a \|\| b` | `'Hi' \|\| ' there'` → `'Hi there'` |
| `SUBSTRING` | Extract part of a string | `SUBSTRING(str FROM n FOR m)` | `SUBSTRING('hello' FROM 2 FOR 3)` → `'ell'` |
| `TRIM` | Remove chars or whitespace | `TRIM([LEADING\|TRAILING\|BOTH] chars FROM str)` | `TRIM('  hi  ')` → `'hi'` |
| `REPLACE` | Replace substring | `REPLACE(str, from, to)` | `REPLACE('foo bar', 'bar', 'baz')` → `'foo baz'` |
| `LPAD` / `RPAD` | Pad a string | `LPAD(str, len, pad)` | `LPAD('5', 3, '0')` → `'005'` |
| `POSITION` | Find substring index | `POSITION(sub IN str)` | `POSITION('l' IN 'hello')` → `3` |
| `SPLIT_PART` | Split and grab nth part | `SPLIT_PART(str, delim, n)` | `SPLIT_PART('a,b,c', ',', 2)` → `'b'` |
| `INITCAP` | Capitalise each word | `INITCAP(str)` | `INITCAP('hello world')` → `'Hello World'` |
| `LEFT` / `RIGHT` | First / last n characters | `LEFT(str, n)` / `RIGHT(str, n)` | `LEFT('hello', 2)` → `'he'` |

### Quick Notes

`SUBSTRING` indexing starts at 1, not 0. `SUBSTRING('hello' FROM 1 FOR 3)` gives `'hel'`.

`TRIM` removes whitespace by default. To remove a specific character, pass it explicitly: `TRIM('x' FROM 'xxhelloxx')` → `'hello'`.

`SPLIT_PART` is particularly useful for cleaning messy data — splitting email addresses, extracting parts of a formatted code, or breaking apart concatenated values.

---

## Number Functions

| Function | Purpose | Syntax | Example |
|---|---|---|---|
| `ROUND` | Round to d decimals | `ROUND(n, d)` | `ROUND(3.14159, 2)` → `3.14` |
| `CEIL` / `FLOOR` | Round up / down | `CEIL(n)` / `FLOOR(n)` | `CEIL(4.2)` → `5` |
| `ABS` | Absolute value | `ABS(n)` | `ABS(-7)` → `7` |
| `POWER` | Exponent | `POWER(a, b)` | `POWER(2, 3)` → `8` |
| `SQRT` | Square root | `SQRT(n)` | `SQRT(16)` → `4` |
| `MOD` | Remainder | `MOD(a, b)` | `MOD(10, 3)` → `1` |
| `TRUNC` | Truncate, no rounding | `TRUNC(n, d)` | `TRUNC(3.789, 1)` → `3.7` |
| `SIGN` | Returns -1, 0, or 1 | `SIGN(n)` | `SIGN(-5)` → `-1` |
| `RANDOM` | Random float between 0 and 1 | `RANDOM()` | `RANDOM()` → `0.583...` |
| `GREATEST` / `LEAST` | Max / min of values | `GREATEST(a, b, ...)` / `LEAST(...)` | `GREATEST(3, 7, 2)` → `7` |

### Quick Notes

`ROUND` vs `TRUNC` — both deal with decimal places, but `ROUND` follows normal rounding rules while `TRUNC` just cuts. `TRUNC(3.789, 1)` gives `3.7`, not `3.8`.

`SIGN` is useful when you need to know the direction of a value without caring about its magnitude — useful for flagging negative amounts during data cleaning.

`GREATEST` / `LEAST` work across multiple values in the same row, unlike `MAX` / `MIN` which aggregate across rows in a column.

---

## Date & Time Functions

| Task | Function | Example |
|---|---|---|
| Today's date | `CURRENT_DATE` | `SELECT CURRENT_DATE;` |
| Date + time + timezone | `NOW()` | `SELECT NOW();` |
| Date + time (no timezone) | `CURRENT_TIMESTAMP` | `SELECT CURRENT_TIMESTAMP;` |
| Extract year | `EXTRACT(YEAR FROM col)` | `EXTRACT(YEAR FROM exam_date)` |
| Extract month | `EXTRACT(MONTH FROM col)` | `EXTRACT(MONTH FROM exam_date)` |
| Extract day | `EXTRACT(DAY FROM col)` | `EXTRACT(DAY FROM exam_date)` |
| Days between two dates | `date1 - date2` | `CURRENT_DATE - exam_date` |
| Full age (yr/mon/day) | `AGE(date1, date2)` | `AGE(CURRENT_DATE, date_of_birth)` |
| Age in years only | `EXTRACT(YEAR FROM AGE(dob))` | `EXTRACT(YEAR FROM AGE(date_of_birth))` |
| Add time to a date | `date + INTERVAL 'n unit'` | `exam_date + INTERVAL '14 days'` |
| Subtract time from date | `date - INTERVAL 'n unit'` | `exam_date - INTERVAL '1 month'` |
| Format date as text | `TO_CHAR(col, 'format')` | `TO_CHAR(exam_date, 'DD Month YYYY')` |
| Truncate to period | `DATE_TRUNC('unit', col)` | `DATE_TRUNC('month', exam_date)` |
| Day name | `TO_CHAR(col, 'Day')` | `TO_CHAR(exam_date, 'Day')` |

### Quick Notes

`NOW()` and `CURRENT_TIMESTAMP` return the same thing in most cases — both include the timezone. Use `CURRENT_DATE` when you only need the date with no time component.

`DATE_TRUNC('month', exam_date)` sets everything below the month to its lowest value — so `2024-03-15` becomes `2024-03-01`. This is the standard way to group records by month in a `GROUP BY`.

`AGE()` returns an interval type. If you want just the number of years, wrap it in `EXTRACT(YEAR FROM AGE(...))`.

`INTERVAL` units include `days`, `weeks`, `months`, `years`, `hours`, `minutes`, `seconds`. You can combine them: `INTERVAL '1 year 3 months'`.

---

## TO_CHAR Format Codes

Used with `TO_CHAR(col, 'format')` to convert dates into readable text.

| Code | What it gives you | Example output | MySQL equivalent |
|---|---|---|---|
| `YYYY` | 4-digit year | `2024` | `%Y` |
| `YY` | 2-digit year | `24` | `%y` |
| `Month` | Full month name (padded) | `March` | `%M` |
| `Mon` | Short month name | `Mar` | `%b` |
| `MM` | Month number 01–12 | `03` | `%m` |
| `DD` | Day number 01–31 | `15` | `%d` |
| `DDth` | Day with ordinal suffix | `15th` | `%D` |
| `Day` | Full day name (padded) | `Friday` | `%W` |
| `Dy` | Short day name | `Fri` | `%a` |
| `HH24` | Hour 0–23 | `14` | `%H` |
| `MI` | Minutes | `35` | `%i` |
| `SS` | Seconds | `22` | `%S` |

### Common TO_CHAR Patterns

```sql
-- Full readable date
TO_CHAR(exam_date, 'DD Month YYYY')         -- '15 March 2024'

-- Compact date
TO_CHAR(exam_date, 'DD/MM/YYYY')            -- '15/03/2024'

-- Month and year only
TO_CHAR(exam_date, 'Month YYYY')            -- 'March 2024'

-- Day name
TO_CHAR(exam_date, 'Day')                   -- 'Friday   ' (padded)
TRIM(TO_CHAR(exam_date, 'Day'))             -- 'Friday'   (trimmed)

-- Date with ordinal day
TO_CHAR(exam_date, 'DDth Month YYYY')       -- '15th March 2024'

-- Full timestamp
TO_CHAR(NOW(), 'DD Mon YYYY HH24:MI:SS')    -- '15 Mar 2024 14:35:22'
```

> `Month` and `Day` format codes pad the output with trailing spaces to a fixed width. Wrap with `TRIM()` when using the result as a label or in a report.

---

*Part of the LuxDevHQ Data Science & Analytics Programme — SQL Module.*
*Benjamin Ochieng | Nairobi, Kenya*
