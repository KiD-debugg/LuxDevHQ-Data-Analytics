# 🌾 Kenya Crops Analytics Dashboard (Power BI)

## Overview

This project was completed as part of a Power BI training program focused on data cleaning, transformation, modeling, visualization, and DAX calculations.

The project uses a **Kenya Crops Dataset** containing agricultural production, revenue, cost, and profitability information from farmers across different counties in Kenya.

The objective was to transform raw agricultural data into actionable insights using Power Query, DAX, and interactive Power BI dashboards.


# Project Objectives

The project focused on:

* Importing and profiling raw datasets
* Cleaning and transforming data using Power Query
* Creating calculated columns
* Developing DAX measures
* Building interactive dashboards
* Performing agricultural performance analysis
* Identifying profitable crops and regions
* Applying data storytelling techniques

---

# Dataset Description

The dataset contains information about farming activities across Kenya.

### Main Fields

| Category              | Fields                                                |
| --------------------- | ----------------------------------------------------- |
| Farmer Information    | Farmer Name, Farmer Contact                           |
| Geography             | County                                                |
| Crop Information      | Crop Type, Crop Variety                               |
| Farming Information   | Season, Soil Type, Irrigation Method                  |
| Production Metrics    | Planted Area (Acres), Yield (Kg)                      |
| Financial Metrics     | Revenue (KES), Cost of Production (KES), Profit (KES) |
| Market Information    | Market Price (KES/Kg)                                 |
| Environmental Factors | Weather Impact, Pest Control                          |
| Time Information      | Planting Date, Harvest Date                           |

---

# Part A – Data Cleaning with Power Query

Data cleaning was performed using Power Query Editor.

## Data Profiling

The following Power Query tools were used:

* Column Quality
* Column Distribution
* Column Profile

These tools helped identify:

* Missing values
* Data type issues
* Outliers
* Invalid records

---

## Text Cleaning

The following transformations were applied:

### Trim

Removed leading and trailing spaces.

### Clean

Removed non-printable characters.

### Capitalize Each Word

Applied to:

* County
* Crop Type
* Crop Variety
* Season
* Soil Type
* Irrigation Method
* Fertilizer Used
* Pest Control
* Weather Impact

---

## Missing Value Handling

Missing categorical values were replaced with meaningful labels such as:

```text
Unknown County
Unknown Crop
Unknown Variety
Not Specified
No Notes
```

Missing numerical values were retained as null values where appropriate.

---

## Data Type Conversion

### Text Fields

* Farmer Name
* County
* Crop Type
* Crop Variety
* Season
* Soil Type
* Irrigation Method
* Fertilizer Used
* Pest Control
* Weather Impact

### Numeric Fields

* Planted Area (Acres)
* Yield (Kg)
* Market Price (KES/Kg)
* Revenue (KES)
* Cost of Production (KES)
* Profit (KES)

### Date Fields

* Planting Date
* Harvest Date

---

## Date Transformations

Additional date attributes were created:

### Planting Year

Extracted from Planting Date.

### Planting Month

Extracted from Planting Date.

### Planting Quarter

Extracted from Planting Date.

### Days to Harvest

Calculated using:

```powerquery
[Harvest Date] - [Planting Date]
```

This metric was converted to total days.

---

# Part B – Feature Engineering

Several analytical columns were created.

## Yield per Acre

```powerquery
[Yield (Kg)] / [Planted Area (Acres)]
```

Measures crop productivity.

---

## Revenue per Acre

```powerquery
[Revenue (KES)] / [Planted Area (Acres)]
```

Measures revenue generation efficiency.

---

## Profit per Acre

```powerquery
[Profit (KES)] / [Planted Area (Acres)]
```

Measures profitability efficiency.

---

## Profit Margin

```powerquery
[Profit (KES)] / [Revenue (KES)]
```

Measures profit retained from revenue.

---

## Profit Status

Conditional column:

```text
Profit > 0 → Profitable
Profit ≤ 0 → Loss
```

---

## Weather Risk Classification

Conditional column:

```text
Severe → High Risk
Mild → Low Risk
```

Used to assess agricultural risk.

---

# Part C – DAX Measures

The project introduced Data Analysis Expressions (DAX) for dynamic calculations.

## Revenue Measures

### Total Revenue

```DAX
Total Revenue =
SUM('Kenya Crops'[Revenue (KES)])
```

---

### Total Revenue (Recalculated)

```DAX
Total Revenue SUMX =
SUMX(
    'Kenya Crops',
    'Kenya Crops'[Planted Area (Acres)] *
    'Kenya Crops'[Yield (Kg)] *
    'Kenya Crops'[Market Price (KES/Kg)]
)
```

---

## Profitability Measures

### Total Profit

```DAX
Total Profit =
SUM('Kenya Crops'[Profit (KES)])
```

### Average Profit

```DAX
Average Profit =
AVERAGE('Kenya Crops'[Profit (KES)])
```

### Profit Margin

```DAX
Profit Margin =
DIVIDE(
    SUM('Kenya Crops'[Profit (KES)]),
    SUM('Kenya Crops'[Revenue (KES)])
)
```

---

## Production Measures

### Average Yield

```DAX
Average Yield =
AVERAGE('Kenya Crops'[Yield (Kg)])
```

### Average Yield per Acre

```DAX
Average Yield per Acre =
AVERAGEX(
    'Kenya Crops',
    DIVIDE(
        'Kenya Crops'[Yield (Kg)],
        'Kenya Crops'[Planted Area (Acres)]
    )
)
```

---

## Counting Measures

### Total Records

```DAX
Total Records =
COUNTROWS('Kenya Crops')
```

### Number of Counties

```DAX
Number of Counties =
DISTINCTCOUNT('Kenya Crops'[County])
```

### Number of Farmers

```DAX
Number of Farmers =
DISTINCTCOUNT('Kenya Crops'[Farmer Name])
```

---

# Dashboard Features

The final dashboard includes:

## Executive KPIs

* Total Revenue
* Total Profit
* Average Profit
* Profit Margin
* Number of Farmers
* Number of Counties

---

## County Analysis

* Revenue by County
* Profit by County
* Yield by County

---

## Crop Analysis

* Revenue by Crop Type
* Profit by Crop Type
* Yield by Crop Variety

---

## Seasonal Analysis

* Production by Season
* Revenue by Season
* Profitability by Season

---

## Operational Analysis

* Days to Harvest
* Irrigation Performance
* Weather Impact Analysis

---

## Interactive Features

* Slicers
* Filters
* Drill-through
* Cross-filtering visuals

---

# Key Insights Generated

The dashboard helps answer questions such as:

* Which counties generate the highest revenue?
* Which crop varieties are most profitable?
* Which seasons provide the highest yields?
* How does weather impact profitability?
* What is the average yield per acre?
* Which farmers achieve the highest production efficiency?

---

# Tools Used

* Microsoft Power BI Desktop
* Power Query
* DAX (Data Analysis Expressions)
* Data Modeling
* Interactive Visualizations

---

# Repository Structure

```text
├── Kenya_Crops_Dataset.csv
├── Kenya_Crops_Dashboard.pbix
├── README.md
└── Screenshots/
    ├── executive-dashboard.png
    ├── county-analysis.png
    ├── crop-analysis.png
    └── profitability-analysis.png
```

---

# Skills Demonstrated

* Data Cleaning
* Data Transformation
* Power Query
* DAX Development
* Data Modeling
* Dashboard Design
* KPI Development
* Agricultural Data Analysis
* Business Intelligence
* Data Storytelling

---

## Author

**Benjamin Ochieng**

Civil & Structural Engineer | Data Analytics Enthusiast | Digital Engineering Advocate

This project demonstrates the application of Business Intelligence and Data Analytics techniques using Microsoft Power BI to transform raw agricultural data into actionable insights.
