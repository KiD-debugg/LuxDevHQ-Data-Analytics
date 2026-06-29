# Before Power BI Can Work Its Magic, Your Data Needs a Blueprint

*A practical guide to database schemas, joins, data modelling, and schema designs — and why they matter for every dashboard you will ever build*

---

Imagine you walk into a brand new supermarket. The shelves are fully stocked — thousands of products — but nothing is organised. Beverages are next to shoe polish. Rice is next to televisions. There are no labels, no sections, no logic. You could spend hours searching for a single item.

That is exactly what happens when you load messy, unstructured data into Power BI. The tool is powerful. The data is there. But without structure, the dashboard you build will be unreliable at best and misleading at worst.

This article is about the invisible architecture that sits beneath every great Power BI report — database schemas, joins, data modelling, and the different ways databases can be designed. These are not the flashiest topics. But understanding them is what separates an analyst who builds dashboards from one who builds dashboards that are actually trusted.

---

## First — What is Power BI?

Power BI is Microsoft's business intelligence platform. It connects to virtually any data source — Excel files, SQL databases, cloud services, APIs — and transforms that data into interactive reports and dashboards that anyone in an organisation can use to make decisions.

A sales manager in Nairobi can open a Power BI report on her phone and instantly see which product categories are underperforming. A CFO in London can filter a revenue dashboard by quarter, region, or salesperson in seconds. None of that is possible, though, if the data feeding those visuals is disorganised.

That is where schemas, joins, and data modelling come in.

---

## The Blueprint: Database Schemas

Before any data enters Power BI, it lives somewhere — in a database, a spreadsheet, or a cloud system. A **database schema** is the blueprint of how that data is organised. It defines the tables, the columns within those tables, the rules that govern the data, and how different tables relate to each other.

Think of it like the architectural drawing of a building. You do not start constructing walls before you have a plan. Similarly, you should not start building dashboards before understanding how your data is structured.

There are three levels of schema that every analyst should know:

**Conceptual** — the big picture. What are the main entities in this business? Customers, Products, Orders, Salespeople. This is the level where you ask business questions, not technical ones.

**Logical** — the structure. How do those entities relate? A Customer places many Orders. Each Order contains multiple Products. This level defines tables, columns, and relationships — independent of any specific software.

**Physical** — the implementation. This is the actual database: the SQL tables, the primary keys, the foreign keys, the constraints. This is what Power BI connects to.

When you open Power BI and click "Get Data," you are connecting to the physical layer. But the quality of your analysis depends entirely on how well the conceptual and logical layers were designed.

---

## The Connector: Joins

Data in the real world is never stored in a single table. A business database might have a `Customers` table, an `Orders` table, a `Products` table, and a `Salespeople` table — all separate, all connected by shared keys.

A **join** is how you combine those tables to answer a real business question.

Consider this scenario from a Kenyan electronics distributor: the Orders table holds transaction records, but it only stores a `CustomerID` — not the customer's name or location. The Customers table holds names and locations but not what they purchased. To answer the question *"Which region generates the most revenue?"* — you need both tables talking to each other. That is a join.

There are several types, and each serves a different purpose:

**Inner Join** — returns only rows where a match exists in both tables. Use this when you want clean, complete records. If a customer has never placed an order, they will not appear in the result. In Power BI, this is the most common join used in data modelling.

**Left Outer Join** — returns all rows from the left table, and matched rows from the right. If no match exists, the right-side columns return NULL. Use this when you want to see all records from your primary table, even if related data is missing — for example, all products including those with no sales yet.

**Right Outer Join** — the mirror of the left join. All rows from the right table, matched rows from the left.

**Full Outer Join** — returns everything from both tables, matched or not. Useful when auditing data completeness — finding customers with no orders, or orders with no matching customer record.

In Power BI, these relationships are managed visually in the **Model View**. You drag a line between two tables, Power BI asks you which columns to join on, and it handles the rest. But you need to understand what type of join makes sense for your analysis — the tool does not make that decision for you.

---

## The Foundation: Data Modelling

Data modelling is the process of deciding how all your tables connect and how your data is structured for analysis. It is the most critical step between raw data and a reliable dashboard.

There are three stages:

**Conceptual modelling** is where you define what exists. What are your entities — the main things your business cares about? For a retailer: Products, Customers, Orders, Regions. At this stage you are drawing boxes and arrows, not writing SQL.

**Logical modelling** is where you define how entities relate. A Customer places one or many Orders. An Order contains one or many Products. This stage produces a schema — the plan that developers and database administrators use to build the actual database.

**Physical modelling** is where you implement it. Tables get created, primary keys are assigned, foreign keys are set, and constraints are defined to protect data integrity.

---

## Choosing the Right Design: Six Database Schema Models

Not all databases are structured the same way. The design you choose depends on your data's complexity, how it will be used, and what tool will consume it. Here are the six main schema designs — what they are, how they work, and when to use each one.

---

### 1. Flat Model

**What it is:** The simplest possible structure — a single two-dimensional table, like a spreadsheet. Every row is a record, every column is a field.

**Real-world example:** A shopkeeper in Gikomba market tracking daily sales in a single Excel sheet — product name, quantity, price, date — all in one place.

**When to use it:** Small datasets, simple applications, quick personal tracking. It breaks down the moment your data gets complex or relationships between different types of data need to be tracked.

**Ease of use:** ⭐⭐⭐⭐⭐ — the easiest. No technical knowledge required.

**Power BI relevance:** You will often receive data in this format. The job of the analyst is to recognise its limitations and restructure it before building a model.

---

### 2. Hierarchical Model

**What it is:** Data organised in a tree structure — one parent, many children. Each record has exactly one parent, but can have multiple children beneath it.

**Real-world example:** An organisation chart. A CEO sits at the top. Below are Directors. Below each Director are Managers. Below each Manager are staff. Each person has only one direct boss — that is a hierarchical relationship.

**When to use it:** When your data has a clear, strict parent-child structure — organisational hierarchies, file systems, product category trees (Electronics → Phones → Smartphones).

**Limitation:** It only works for one-to-many relationships. The moment one child needs two parents — say, a project that belongs to both the Finance and Operations departments — the hierarchical model breaks.

**Ease of use:** ⭐⭐⭐ — straightforward to understand, but rigid in practice.

**Power BI relevance:** Power BI supports hierarchies natively — you can drill down from Year → Quarter → Month → Day in a chart. That drill-down functionality is a hierarchical model in action.

---

### 3. Network Model

**What it is:** Like the hierarchical model but with the rigidity removed. Instead of a strict tree, the network model allows many-to-many relationships — a child can have multiple parents, and a parent can connect to many children in multiple directions. Think of it as a web rather than a tree.

**Real-world example:** A university database where a Student can enrol in many Courses, and each Course can have many Students. No single parent-child rule applies — the relationships go in all directions.

**When to use it:** Complex systems where entities genuinely have many connections — supply chains, telecommunications networks, social networks.

**Limitation:** The flexibility that makes it powerful also makes it difficult to design and maintain. It is rarely used in modern business analytics.

**Ease of use:** ⭐⭐ — complex to design and navigate.

**Power BI relevance:** Low direct relevance. Power BI's model view works best with simpler, cleaner relationships. If your data looks like a network model, it usually needs restructuring before it is brought into Power BI.

---

### 4. Relational Model

**What it is:** The dominant model in modern databases. Data is stored in multiple separate tables, and tables are linked to each other through shared keys — a primary key in one table matches a foreign key in another. This is the foundation of SQL databases like MySQL, PostgreSQL, and SQL Server.

**Real-world example:** M-Pesa transaction records. One table stores Customer details (CustomerID, Name, Phone). Another stores Transactions (TransactionID, CustomerID, Amount, Date). The `CustomerID` field connects the two — that link is a foreign key relationship, and it is the heart of the relational model.

**When to use it:** Almost always, for business data. The relational model handles complex data efficiently, avoids duplication, and scales well. It is what most organisations use for their operational databases.

**Ease of use:** ⭐⭐⭐⭐ — requires understanding of keys and relationships, but tools like Power BI make it very manageable.

**Power BI relevance:** This is Power BI's native language. When you connect Power BI to a SQL database, you are connecting to a relational model. The Model View in Power BI is essentially a visual representation of relational table relationships.

---

### 5. Star Schema

**What it is:** A specialised design built specifically for analytics and reporting — not for storing live operational data, but for analysing historical data at speed. It has one central **fact table** containing measurable business events (sales, transactions, clicks), surrounded by multiple **dimension tables** containing descriptive information (who, what, where, when).

**Real-world example:** A supermarket analytics database. The fact table holds every sales transaction — date, product, store, quantity, price. The dimension tables describe: *which product?* (Product table), *which store?* (Store table), *which customer?* (Customer table), *when?* (Date table). The fact table sits in the middle like the centre of a star, with dimension tables radiating outward.

**When to use it:** Whenever you are building dashboards or analytical reports. It is fast, simple to query, and easy to understand. Most Power BI data models follow the star schema pattern.

**Ease of use:** ⭐⭐⭐⭐⭐ for analysts — this is the most intuitive structure for building reports.

**Power BI relevance:** This is the **recommended structure for Power BI**. Microsoft's own documentation advises building star schemas before loading data into Power BI. The reason is performance — Power BI's calculation engine (called DAX) runs significantly faster on a well-built star schema than on flat or unstructured data.

---

### 6. Snowflake Schema

**What it is:** A variation of the star schema. The difference is that in a snowflake schema, the dimension tables are further broken down into sub-tables — normalised, in database terminology. Instead of one flat Product dimension table, you might have a Product table linking to a Category table, which links to a Department table.

**Real-world example:** Continuing the supermarket example — in a star schema, the Product dimension might have columns for ProductName, Category, and Department all in one table. In a snowflake schema, Category and Department would each be separate tables, linked back to Product. The shape this creates looks like a snowflake — many branching connections rather than simple spokes.

**When to use it:** When storage efficiency matters and your dimension tables contain significant redundancy. Normalising reduces data duplication. It is more common in large enterprise data warehouses where storage costs are significant.

**Trade-off:** Snowflake schemas are more complex to query. Joining multiple tables to get a single answer takes more processing. For Power BI specifically, this extra complexity can slow report performance.

**Ease of use:** ⭐⭐⭐ — more complex than star schema. Requires more joins to retrieve the same information.

**Power BI relevance:** Power BI can work with snowflake schemas, but the general advice is to flatten them back toward a star schema before building your model. The performance gain from simplicity usually outweighs the storage savings from normalisation.

---

## Which Schema Should You Use and When?

Here is a simple decision guide:

| Situation | Recommended Schema |
|---|---|
| Quick personal tracking, small dataset | Flat Model |
| Strict parent-child data (org charts, categories) | Hierarchical Model |
| Complex many-to-many relationships | Network Model |
| Operational business database (live transactions) | Relational Model |
| Analytics, dashboards, Power BI reports | Star Schema |
| Large enterprise data warehouse, storage-sensitive | Snowflake Schema |

For the vast majority of analysts building Power BI dashboards — **start with the star schema**. It is the easiest to build, the fastest to query, and the most natural fit for how Power BI thinks about data.

If your data arrives as a flat model (a single Excel sheet), your job is to identify the entities and split them into a fact table and dimension tables. If it arrives as a relational model from a SQL database, restructure it into a star schema before building your Power BI model. If it is a snowflake, consider flattening it.

---

## Why This All Matters for Every Dashboard You Build

Here is the real-world connection.

During my own analysis of an electronics sales dataset — 632 transactions across 13 countries — the data came from multiple sources. Revenue figures lived in one table. Salesperson information in another. Product categories in a third. Without understanding joins and schemas, I could not have combined those sources to answer questions like:

- *Which salesperson generates the highest revenue per order?*
- *Do high-discount products attract more customer reviews?*
- *Which region is growing fastest month on month?*

Every single one of those questions required data from at least two tables. Every answer depended on a correctly defined relationship. The final Power BI model followed a star schema — a central Sales fact table surrounded by dimension tables for Products, Salespeople, Regions, and Dates. Every slicer, every chart, every KPI card on the dashboard was powered by that structure.

Power BI gives you the tools to build beautiful, interactive dashboards. But schemas give your data structure. Joins give your data breadth. Data modelling gives your analysis integrity. And choosing the right schema design gives your reports the speed and reliability that decision-makers depend on.

Get those right, and Power BI becomes genuinely powerful. Skip them, and you are building on sand.

---

*Published as part of my learning journey on the LuxDevHQ Data Science & Analytics Programme.*

Link: https://dev.to/benjamin_ogol_1af8e695c87/the-invisible-architecture-behind-every-great-power-bi-report-3cam
