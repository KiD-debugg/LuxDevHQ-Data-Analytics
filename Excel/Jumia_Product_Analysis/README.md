# 📊 Excel — Data Analysis Projects

This folder contains all Excel-based projects and assignments completed as part of the **LuxDevHQ Data Science & Analytics Programme**. Each subfolder represents a standalone project with its own dataset, analysis, and documentation.

---

## 🛠️ Excel Skills Demonstrated

| Skill | Applied In |
|---|---|
| Data Cleaning & Preparation | Jumia Product Analysis |
| Data Enrichment (calculated columns) | Jumia Product Analysis |
| Pivot Tables & Pivot Charts | Jumia Product Analysis |
| Interactive Dashboard Design | Jumia Product Analysis |
| Conditional Formatting | Jumia Product Analysis |
| Slicers & Filters | Jumia Product Analysis |
| IF, IFERROR, AVERAGE, LARGE, SMALL | Jumia Product Analysis |
| INDEX MATCH | Jumia Product Analysis |
| Data Documentation & Audit Trail | Jumia Product Analysis |

---

## 📁 Folder Structure

```
Excel/
│
├── Jumia_Product_Analysis/
│   ├── Excel_jumia_dataset.xlsx           # Cleaned dataset + interactive dashboard
│   ├── Jumia_Analysis_Documentation.docx  # Full data cleaning & analysis write-up
│   └── README.md                          # Project-specific details
│
└── Articles/
    └── How_Excel_Is_Used_In_Real_World_Data_Analysis.md
```

---

## 📂 Projects

### 🛒 Jumia Product Performance Dashboard
> **Folder:** `Jumia_Product_Analysis/`

A full end-to-end data analysis project on a real-world Jumia e-commerce dataset. The project covers the complete analytics workflow — from raw data cleaning through to an interactive Excel dashboard with business insights.

**Dataset:** 165 product listings from Jumia Kenya, including product names, current prices, old prices, discount percentages, customer reviews, and ratings.

**What was done:**

- **Data Cleaning** — identified and removed exact duplicate records, standardised price and rating columns to numeric format, handled ranged price values using midpoint averaging, and classified blank ratings as N/A
- **Data Enrichment** — calculated absolute discount amounts (Old Price − Current Price), created a Rating Category column (Poor / Average / Excellent) and a Discount Category column (Low / Medium / High) using nested IF formulas
- **Descriptive Statistics** — computed averages across price, discount, and rating; identified most and least expensive products
- **Trend Analysis** — explored the relationship between discount percentage and number of reviews, and between product rating and number of reviews using Pivot Tables
- **Product Performance** — ranked Top 10 products by discount and by reviews; compared performance across discount categories
- **Dashboard** — built an interactive dashboard using Pivot Charts, slicers, and conditional formatting

**Key Finding:** Medium discount products (20–40%) attracted the highest average customer reviews (15.3 per product), outperforming both high discount (11.1) and low discount (9.5) products. This suggests that aggressive discounting alone does not drive customer engagement on the Jumia platform.

**Tools used:** Microsoft Excel

---

### 📝 Article — How Excel Is Used in Real-World Data Analysis
> **Folder:** `Articles/`

A published article written as a personal reflection on how Excel is applied in real-world professional settings — covering financial reporting, HR data management, and project timeline tracking.

🔗 [Read the article on DEV.to](#) *(update this link after publishing)*

---

## 💡 Key Lessons from This Topic

- Raw data is rarely clean — always audit before analysing
- The difference between `blank` and `zero` matters in data analysis
- Average is more meaningful than Sum when comparing groups of different sizes
- Documenting every cleaning decision is as important as the cleaning itself
- A dashboard is only as good as the data feeding it

---

> *More Excel projects will be added as the programme progresses.*
