# 📊 Sales Operations & Analytics Dashboard (Excel Mastery Assignment)

## Overview

This project was completed as part of an **Excel Mastery Assignment: Sales Operations & Analytics**. The objective was to clean, enrich, analyze, and visualize transactional sales data for a multi-regional electronics distributor using Microsoft Excel.

The dataset contained **632 transactional records** with intentional data quality issues, requiring data cleaning, transformation, business analysis, and dashboard development.

---

## Dashboard Preview

> ![alt text](image.png)


## Project Objectives

The assignment focused on:

* Data cleaning and preparation
* Creation of calculated business metrics
* Sales and profitability analysis
* Operational performance assessment
* Product and customer insights
* Scenario and what-if analysis
* Executive dashboard development
* Business storytelling and recommendations

---

## Dataset Description

The dataset contains transactional sales information across multiple regions and countries, including:

* Order information
* Product information
* Customer segments
* Sales channels
* Sales personnel
* Revenue and cost data
* Delivery performance metrics
* Pricing and discount information

### Key Fields

| Category              | Fields                                      |
| --------------------- | ------------------------------------------- |
| Order Information     | OrderID, OrderDate, RequiredDate            |
| Geography             | Region, Country, City                       |
| Sales Information     | Channel, Salesperson                        |
| Product Information   | ProductCategory, SKU                        |
| Financial Information | Unit Cost, Unit Price, Discount %, Quantity |
| Performance Metrics   | Revenue, Profit, Margin                     |
| Operations            | Lead Time, On-Time Delivery                 |

---

# Part A – Data Cleaning & Preparation

## Data Quality Issues Addressed

### 1. Missing City Values

**Approach**

* Reviewed Region and Country information.
* Missing values that could not be confidently identified were labeled:

```text
Unknown
```

### 2. Missing Salesperson Values

**Approach**

* Replaced blank values with:

```text
Unassigned
```

This ensured transactions remained available for analysis without assigning ownership incorrectly.

### 3. Missing Channel Values

**Approach**

* Filled using the most common channel for similar Region/Product Category combinations.
* Remaining unresolved records were labeled:

```text
Unknown
```

---

## Invalid Required Dates

Some orders contained Required Dates earlier than Order Dates.

### Solution

Created:

* Date_Check
* CleanedRequiredDates

Logic:

```excel
=IF(RequiredDate<OrderDate,"Invalid RequiredDate","Valid")
```

Invalid dates were corrected using the median lead time.

---

## Suspicious Pricing

Some products contained negative or unrealistic selling prices.

### Solution

Created:

* UnitPrice_Tag
* Clean Unit Price

Logic:

```excel
=IF(UnitPrice<0,"Invalid Price","Valid")
```

Invalid prices were replaced using average prices within the same product category.

---

## Excessive Discounts

Discounts greater than 30% were identified as outliers.

### Solution

Created:

* Discount_Tag
* Clean_DiscountPct

Logic:

```excel
=IF(DiscountPct>30%,"High Discount","Valid")
```

Discounts were capped at 30%.

---

# Part B – Data Enrichment

Several analytical fields were added to improve reporting capabilities.

## Time Intelligence

### Order Month

```excel
=TEXT(OrderDate,"mmm-yyyy")
```

### Order Quarter

```excel
="Q"&ROUNDUP(MONTH(OrderDate)/3,0)&"-"&YEAR(OrderDate)
```

---

## Geographic Hierarchy

Created a drill-down hierarchy:

```text
Region → Country → City
```

---

## Country First Sales Month

Created a field showing the first sales period for country tracking.

Example:

```text
Kenya-2024-03
```

---

## Price Band Classification

Products were categorized into:

* Low
* Medium
* High

based on cleaned unit prices.

---

## Operational Metrics

### Lead Time

Calculated using:

```text
Required Date - Order Date
```

### On-Time Delivery Indicator

```excel
=IF(LeadTimeDays<=7,1,0)
```

---

## Discount Compliance Indicator

```excel
=IF(Clean_DiscountPct>20%,1,0)
```

Used for monitoring pricing discipline.

---

# Part C – Business Metrics

The following KPIs were calculated:

## Gross Revenue

```excel
Revenue = Unit Price × Quantity × (1 - Discount)
```

---

## Cost of Goods

```excel
Cost = Unit Cost × Quantity
```

---

## Gross Profit

```excel
Profit = Revenue - Cost
```

---

## Margin Percentage

```excel
Margin = Profit / Revenue
```

---

# Part D – Analytical Reporting

Several pivot tables and analyses were created.

## 1. Revenue Analysis

Analyzed revenue by:

* Region
* Country
* Month
* Product
* Salesperson

---

## 2. Gross Profit Analysis

Evaluated profitability by:

* Region
* Sales Channel
* Salesperson

---

## 3. Product Performance

Identified:

* Best-performing SKUs
* Revenue contribution by product
* Product concentration risks

---

## 4. Salesperson Performance

Measured:

* Revenue generated
* Gross profit generated
* Orders handled
* Revenue per order

---

## 5. Channel Mix Analysis

Compared revenue contribution from:

* Direct
* Distributor
* Marketplace
* Online
* Retail

This helped identify channel dependency and possible cannibalization.

---

## 6. Service Level Proxy

Used the On-Time Delivery metric to estimate operational performance.

Evaluated:

* Regional performance
* Product category performance
* Delivery consistency

---

## 7. Price Compliance Analysis

Monitored discount behavior and categorized risk levels:

| Risk Level | Criteria      |
| ---------- | ------------- |
| Low        | ≤ 15%         |
| Medium     | >15% and ≤30% |
| High       | >30%          |

---

## 8. ABC Product Classification

Products were categorized according to cumulative revenue contribution:

### Category A

Top revenue-generating products.

### Category B

Moderate revenue contributors.

### Category C

Low revenue contributors.

This supports inventory prioritization and product strategy decisions.

---

# Part E – What-If Analysis

A scenario control panel was created to evaluate business outcomes under changing conditions.

## User-Controlled Inputs

| Parameter           | Purpose                          |
| ------------------- | -------------------------------- |
| Global Discount Cap | Restrict discount levels         |
| Unit Cost Inflation | Simulate supplier cost increases |
| Quantity Uplift     | Simulate sales growth            |

---

## Scenario Outputs

The model dynamically recalculates:

* Scenario Revenue
* Scenario Profit

allowing management to test different business strategies.

---

# Dashboard Features

The final dashboard consolidates all key insights into an interactive management view.

## Dashboard Components

### Executive KPIs

* Total Revenue
* Total Gross Profit
* Average Margin
* Order Count

### Revenue Trends

* Monthly sales performance
* Seasonal trends

### Regional Performance

* Revenue by region
* Profitability comparison

### Product Insights

* Top-performing SKUs
* Product contribution analysis

### Salesperson Performance

* Revenue ranking
* Profit ranking

### Channel Analysis

* Revenue by sales channel
* Channel effectiveness

### Operational Performance

* On-Time Delivery Rate
* Service Level Proxy

### Scenario Analysis

* Impact of pricing and cost assumptions

---

## Dashboard Screenshots

You can also include larger screenshots later in the README with brief explanations.

### Interactive Dashboard

### Revenue by Region

### Salesperson Performance

---

# Key Business Insights

## Regional Performance

* Europe generated the strongest overall profitability relative to sales volume.
* The Americas contributed the largest share of gross profit across channels.
* Asia showed moderate performance with opportunities for channel expansion.
* Africa recorded the lowest profitability, indicating potential growth opportunities.

---

## Product Portfolio

* Revenue is concentrated among a small number of high-performing SKUs.
* A limited group of products drives a large portion of overall sales.

---

## Pricing Strategy

* Discount levels vary significantly across products.
* Certain products receive aggressive discounts that may negatively affect profitability.

---

## Sales Channels

* Direct and Online channels generate a substantial share of profit.
* Channel mix analysis highlights opportunities for optimization and growth.

---

# Tools Used

* Microsoft Excel
* Pivot Tables
* Pivot Charts
* Slicers
* Excel Formulas
* What-If Analysis
* Dashboard Design Techniques

---

# Repository Structure

```text
├── Sales and Operations analytics.xlsx
├── README.md
└── Dashboard Screenshots/
    ├── dashboard-overview.png
    ├── revenue-analysis.png
    ├── product-performance.png
    ├── scenario-analysis.png
    ├── revenue-by-region.png
    └── salesperson-performance.png
```

---

# Learning Outcomes

This project demonstrates practical skills in:

* Data Cleaning
* Data Validation
* Business Analytics
* Financial Analysis
* KPI Development
* Dashboard Design
* Scenario Modeling
* Executive Reporting
* Data Storytelling

---

## Author

**Benjamin Ochieng**

Civil & Structural Engineer | Data Analytics Enthusiast | Digital Engineering Advocate

Focused on applying data-driven decision-making, analytics, and technology to engineering and business problems.
