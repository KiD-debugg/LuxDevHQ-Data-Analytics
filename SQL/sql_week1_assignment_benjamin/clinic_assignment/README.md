# SQL Practice — Afya Bora Clinic: CASE WHEN Deep Dive

**Name:** Benjamin Ochieng
**Date:** July 2025
**Database:** PostgreSQL
**Programme:** LuxDevHQ Data Science & Analytics

---

## The Scenario

Afya Bora Clinic is a fictional healthcare facility with patients ranging from a 5-year-old to an 81-year-old, bills ranging from Ksh 800 to Ksh 7,500, and a team of six doctors across specialties from Pediatrics to Neurology.

The assignment was not about building the database — that was already done. It was about learning to make SQL *think*. Specifically, how to use `CASE WHEN` to classify, label, count conditionally, and catch the kind of logic bug that looks correct until you look at the output and realise every single row is wrong.

---

## What This Covers

- **Exercise 1** — Simple Minor/Adult classification using `CASE WHEN`
- **Exercise 2** — Multi-bracket age labelling (Child, Teen, Adult, Senior)
- **Exercise 3** — Bill amount tiering (Affordable, Standard, Expensive)
- **Exercise 4** — Department code lookup using Simple `CASE`
- **Exercise 5** — Intentional bug: predicting broken `CASE WHEN` output before running it
- **Exercise 6** — Fixing the broken query from Exercise 5
- **Exercise 7** — Conditional counting by age group using `SUM(CASE...)`
- **Exercise 8** — Conditional counting by appointment status using `SUM(CASE...)`
- **Exercise 9** — `CASE WHEN` combined with `LEFT JOIN` and `GROUP BY` for patient visit classification

---

## The Database Structure

Three tables, one schema.

```
clinic
├── afya_patients       — 11 patients with age and bill amount
├── afya_doctors        — 6 doctors across medical specialties
└── afya_appointments   — 10 appointment records with status
```

The `afya_appointments` table links patients to doctors via foreign keys and carries a status of `Completed`, `Cancelled`, or `Pending`. Exercise 9 uses a `LEFT JOIN` specifically because patients with zero appointments would disappear from an inner join — and a patient with no appointments is still a patient worth knowing about.

---

## File Structure

```
Clinic-CASE-WHEN-Practice/
├── README.md
└── sql/
```

---

## Exercise Summaries

### Exercise 1 — Minor or Adult

Classified every patient as `Minor` (under 18) or `Adult` (18 and above) using a two-condition `CASE WHEN`. Straightforward, but it establishes the syntax pattern that every subsequent exercise builds on.

### Exercise 2 — Age Bracket

Extended the classification to four groups: `Child` (under 12), `Teen` (12–19), `Adult` (20–59), `Senior` (60+). The dataset has patients across all four brackets — from 5-year-old Faith Nyambura to 81-year-old John Mutua — so all four labels appear in the output.

### Exercise 3 — Bill Tier

Labelled every patient's bill as `Affordable` (under 2,000), `Standard` (2,000–5,000), or `Expensive` (over 5,000). The boundary conditions matter here — a bill of exactly 2,000 should not fall into Affordable, and exactly 5,000 should not fall into Expensive.

### Exercise 4 — Department Code

Used Simple `CASE` (matching on a fixed value rather than a condition) to give each doctor a short department code based on their specialty. `Pediatrics → PED`, `Cardiology → CARD`, `General Medicine → GM`, `Orthopedics → ORTH`, `Dermatology → DERM`, `Neurology → NEUR`.

Simple `CASE` and Searched `CASE` look similar but behave differently. Simple `CASE` checks equality. Searched `CASE` evaluates a condition. Knowing which to use depends on the problem.

### Exercise 5 — The Order-of-WHEN Bug

This is the most instructive exercise in the set. The broken query puts `bill_amount > 1000` before `bill_amount < 2000`. Since every bill in the dataset is above 1,000, every single row gets labelled `Not Affordable` — the second and third conditions never fire because the first one catches everything first.

`CASE WHEN` stops at the first condition that is true. It does not find the *best* match. It finds the *first* match. That distinction catches people out constantly.

### Exercise 6 — Fix It

Rewrote the broken query with correct thresholds and correct ordering: `Affordable` (under 1,000) first, `Standard` (1,000–5,000) second, `Expensive` (over 5,000) last. Now each condition only fires for the rows it should.

### Exercise 7 — Conditional Counting by Age Group

Used `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` four times in a single query to count how many patients fall into each age bracket — all returned in one row with four columns. This is the pattern that shows up in dashboards and reports constantly. It is much faster than running four separate `COUNT` queries.

### Exercise 8 — Conditional Counting by Appointment Status

Same technique, different dimension. Counted `Completed`, `Cancelled`, and `Pending` appointments across the entire `afya_appointments` table — three numbers, one query, one row.

### Exercise 9 — CASE + LEFT JOIN + GROUP BY

The most complex exercise. For every patient, counted their total appointment records using a `LEFT JOIN` from `afya_patients` to `afya_appointments`. Then classified the count using `CASE WHEN`:

```
0 appointments  → New Patient
1–2 appointments → Regular
3+ appointments  → Frequent
```

The `LEFT JOIN` is not optional here. Peter Kamau has three appointments and Faith Nyambura has none — an inner join would drop Faith entirely. The `LEFT JOIN` keeps all patients, returning `NULL` for appointment columns where no record exists. `COUNT(appointment_id)` on a `NULL` returns 0, which correctly classifies her as a New Patient.

---

## Key Things I Learned

`CASE WHEN` evaluates conditions top to bottom and stops at the first match. This is not a bug — it is by design. But it means your most specific conditions must come first, and your broadest conditions must come last.

`SUM(CASE WHEN ... THEN 1 ELSE 0 END)` is one of the most useful patterns in SQL reporting. One query, one pass through the data, multiple conditional counts in separate columns. Once you see it, you use it everywhere.

`LEFT JOIN` is not just a JOIN type — it is a deliberate statement about which records matter. If you want all patients regardless of whether they have appointments, `LEFT JOIN` is the only join that guarantees that.

The difference between Simple `CASE` and Searched `CASE` is subtle but important. When you are matching one column against a list of fixed values, Simple `CASE` is cleaner. When you are evaluating conditions with operators like `>`, `<`, or `BETWEEN`, Searched `CASE` is the right tool.

---

*Part of the LuxDevHQ Data Science & Analytics Programme — SQL Module.*
*Benjamin Ochieng | Nairobi, Kenya*
