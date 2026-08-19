# SQL Week 2 Assignment — Greenwood Academy Database

**Name:** Benjamin Ochieng
**Date:** July 2025
**Database:** PostgreSQL
**Programme:** LuxDevHQ Data Science & Analytics

---

## The Scenario

Greenwood Academy is a secondary school in Nairobi. They needed a database built from scratch — tables, data, and queries — and I was given the job of database administrator for the weekend.

That meant designing the schema, writing the DDL to build the tables, populating them with student and exam records, and then running queries to answer real questions about the data. By the end, the database could tell you which students were in Form 4, which exam results qualified for a Distinction, and which subjects belonged to the Sciences department.

It sounds straightforward. It mostly was. The interesting parts were the `CASE WHEN` logic for grading and understanding why `BETWEEN` behaves differently on dates versus numbers.

---

## What This Covers

- **Section A** — Building the Database (DDL: `CREATE`, `ALTER`, `DROP`)
- **Section B** — Filling the Database (DML: `INSERT`, `UPDATE`, `DELETE`)
- **Section C** — Querying the Data (Filtering with `WHERE`, `AND`, `OR`)
- **Section D** — Range, Membership & Search Operators (`BETWEEN`, `IN`, `NOT IN`, `LIKE`)
- **Section E** — Aggregation with `COUNT`
- **Section F** — Conditional Logic with `CASE WHEN`

---

## The Database Structure

Three tables, one schema.

```
greenwood_academy
├── students        — 10 students across Form 1 to Form 4
├── subjects        — 10 subjects across departments
└── exam_results    — 10 exam result records linking students to subjects
```

The `exam_results` table acts as the bridge between students and subjects — it holds the marks, exam dates, and foreign keys connecting back to both tables. Getting the foreign key relationships right before inserting data matters here. Insert data in the wrong order and PostgreSQL will reject it.

---

## File Structure

```
SQL/
└── Week-02-SQL/
    ├── README.md
    ├── section_a_building_the_database.sql
    ├── section_b_filling_the_database.sql
    ├── section_c_querying_the_data.sql
    ├── section_d_range_membership_search.sql
    ├── section_e_count.sql
    └── section_f_case_when.sql
```

Each `.sql` file contains the queries for that section, with comments above each one explaining what the query does and why.

---

## Section Summaries

### Section A — Building the Database

Created the `greenwood_academy` schema and three tables using DDL. Also used `ALTER TABLE` to add and then drop a `phone_number` column, and renamed `credits` to `credit_hours` in the subjects table. These are the kinds of changes that happen constantly in real databases — requirements change after the table already exists.

### Section B — Filling the Database

Inserted 10 students, 10 subjects, and 10 exam results. Then updated Esther Akinyi's city from Nakuru to Nairobi, corrected a marks entry error on result_id 5, and deleted the cancelled exam result with result_id 9.

The order of operations matters here — you cannot insert exam results before the students and subjects they reference exist.

### Section C — Querying the Data

Filtering queries using `WHERE`, `AND`, and `OR`. Found all Form 4 students, all Sciences subjects, all female students, all results with marks above 70, and combined conditions like Form 3 students from Nairobi specifically.

### Section D — Range, Membership & Search Operators

Used `BETWEEN` for marks ranges and date ranges, `IN` to filter students by city, `NOT IN` to exclude specific form groups, and `LIKE` to find students whose names start with particular letters or subjects containing a specific word.

### Section E — COUNT

Two aggregation queries: how many students are in Form 3, and how many exam results have a mark of 70 or above. Simple counts, but the foundation for more complex aggregations later.

### Section F — CASE WHEN

The most interesting section. Applied conditional logic to label exam results as Distinction, Merit, Pass, or Fail based on marks thresholds. Then separately labelled students as Senior (Form 3 or 4) or Junior (Form 1 or 2). `CASE WHEN` is SQL's way of making decisions inside a query — it shows up constantly in real reporting work.

---

## Key Things I Learned

`ALTER TABLE` is more common in real work than tutorials suggest. Schemas change after data already exists — knowing how to add, rename, and drop columns without losing everything else is a practical skill.

The order you insert data into related tables is not optional. PostgreSQL enforces foreign key constraints. If you try to insert an exam result before the student it references exists, the insert fails.

`BETWEEN` on dates includes both endpoints. `BETWEEN '2024-03-15' AND '2024-03-18'` catches everything from the start of the 15th to the end of the 18th. Worth knowing before you write a date range filter and wonder why you are getting more rows than expected.

`CASE WHEN` evaluates conditions top to bottom and stops at the first match. The order of your conditions matters — if you put `marks >= 40` before `marks >= 80`, everything above 40 gets labelled Pass before it ever reaches the Distinction check.

---

## Article Link

*Article coming soon — link will be updated after publishing.*

---

*Part of the LuxDevHQ Data Science & Analytics Programme — SQL Module.*
*Benjamin Ochieng | Nairobi, Kenya*
