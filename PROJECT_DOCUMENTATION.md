# Inventory Analytics - End-to-End Data Engineering & Analysis Project

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Business Problem](#2-business-problem)
3. [Objectives](#3-objectives)
4. [Tech Stack](#4-tech-stack)
5. [Dataset Description](#5-dataset-description)
6. [Architecture - Medallion Pattern](#6-architecture---medallion-pattern)
7. [Database Design](#7-database-design)
8. [ETL Pipeline - Step-by-Step](#8-etl-pipeline---step-by-step)
9. [Analytical Queries & KPIs](#9-analytical-queries--kpis)
10. [Key Results & Business Insights](#10-key-results--business-insights)
11. [Power BI Dashboard](#11-power-bi-dashboard)
12. [Project Structure](#12-project-structure)
13. [How to Run](#13-how-to-run)
14. [Future Enhancements](#14-future-enhancements)

---

## 1. Project Overview

This project implements a complete **data engineering and analytics pipeline** for retail inventory management. It ingests raw CSV data, transforms it through a structured **Medallion Architecture (Bronze/Silver)**, normalizes it into a relational schema, and produces actionable business insights through SQL-based analytical queries and a Power BI dashboard.

The pipeline is designed to answer critical supply chain questions: *Which products are at risk of stockout? When should we reorder? How efficiently is inventory turning over across stores and regions?*

---

## 2. Business Problem

Retail businesses deal with thousands of SKUs across multiple stores and regions. Without a structured analytics system, they face:

- **Stockouts**: Products go out of stock, causing lost revenue and customer dissatisfaction.
- **Overstocking**: Excess inventory ties up capital, increases storage costs, and leads to waste (especially for perishable goods).
- **Blind Reordering**: Without data-driven reorder points, purchasing decisions rely on guesswork rather than actual demand patterns.
- **No Visibility**: Management lacks a consolidated view of inventory health across stores and regions.

This project addresses all of these problems by building a data pipeline that transforms raw transactional data into structured, queryable analytics.

---

## 3. Objectives

| # | Objective | Approach |
|---|-----------|----------|
| 1 | Build a scalable ETL pipeline | Medallion Architecture with Bronze and Silver layers in MySQL |
| 2 | Normalize raw data into a relational model | 3NF schema with 7 tables, foreign keys, and composite keys |
| 3 | Calculate inventory KPIs | SQL-based analytics: stockout rate, turnover ratio, inventory age |
| 4 | Estimate reorder points | Demand-based formula: `ROP = Avg Daily Sales x Lead Time` |
| 5 | Detect low inventory items | Compare current stock levels against calculated reorder thresholds |
| 6 | Visualize insights | Interactive Power BI dashboard connected to the silver layer |

---

## 4. Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Database | MySQL 8.0 | Data storage, ETL, and analytical queries |
| IDE | JetBrains DataGrip | SQL development and database management |
| Visualization | Microsoft Power BI | Interactive dashboard for stakeholders |
| Version Control | Git | Source code management |
| Data Format | CSV (8.76 MB) | Raw data source |
| Architecture | Medallion (Bronze/Silver) | Layered data processing pattern |

---

## 5. Dataset Description

**File**: `dataset/inventory_forecasting.csv`
**Size**: ~8.76 MB | **Rows**: 109,500 | **Time Period**: January 1, 2022 - December 31, 2023 (2 full years)

### 5.1 Column Definitions

| Column | Data Type | Description | Example Values |
|--------|-----------|-------------|----------------|
| Date | DATE | Transaction date | 2022-01-01 to 2023-12-31 |
| Store ID | VARCHAR | Unique store identifier | S001, S002, S003, S004, S005 |
| Product ID | VARCHAR | Unique product identifier | P0016, P0031, P0046, ..., P0187 |
| Category | VARCHAR | Product category | Clothing, Electronics, Furniture, Groceries, Toys |
| Region | VARCHAR | Geographic region | North, South, East, West |
| Inventory Level | INT | Units in stock on that date | 28 - 339 |
| Units Sold | INT | Units sold on that date | 5 - 298 |
| Units Ordered | INT | Units ordered/restocked | 20 - 298 |
| Demand Forecast | FLOAT | Predicted demand (units) | 6.63 - 271.94 |
| Price | DECIMAL | Product selling price ($) | 10.03 - 99.97 |
| Discount | INT | Discount percentage applied | 0, 5, 10, 15, 20 |
| Weather Condition | VARCHAR | Weather on that date | Sunny, Rainy, Cloudy, Snowy |
| Holiday/Promotion | BOOLEAN | Whether a promotion was active | 0 (No), 1 (Yes) |
| Competitor Pricing | DECIMAL | Competitor's price ($) | 9.88 - 109.30 |
| Seasonality | VARCHAR | Season of the year | Winter, Spring, Summer, Fall |

### 5.2 Data Scale

| Dimension | Count |
|-----------|-------|
| Stores | 5 |
| Products | 30 |
| Categories | 5 |
| Regions | 4 |
| Days Covered | 730 (2 years) |
| Weather Types | 4 |
| Seasons | 4 |
| Total Records | 109,500 |

The dataset structure follows: `730 days x 5 stores x 30 products = 109,500 rows`, providing daily granularity for every product-store combination.

---

## 6. Architecture - Medallion Pattern

This project follows the **Medallion Architecture**, a layered data design pattern widely used in modern data engineering (popularized by Databricks for data lakehouses). Each layer incrementally improves data quality.

```
+-------------------+        +------------------------+        +---------------------+
|   RAW CSV FILE    |  --->  |    BRONZE LAYER        |  --->  |   SILVER LAYER      |
|                   |        |                        |        |                     |
| inventory_        |  LOAD  | inventory_bronze_layer |  ETL   | inventory_silver_   |
| forecasting.csv   |  DATA  | .raw_inventory_data    |        | layer               |
|                   |        |                        |        | (7 normalized       |
| (109,500 rows,    |        | (1 flat table,         |        |  tables with FKs)   |
|  15 columns)      |        |  109,500 rows)         |        |                     |
+-------------------+        +------------------------+        +---------------------+
                                       |                                  |
                                       v                                  v
                             +------------------------+        +---------------------+
                             | inventory_analytics    |        |  ANALYSIS LAYER     |
                             | .inventory_transactions|        |  (5 SQL scripts)    |
                             | (via stored procedure) |        |  + Power BI         |
                             +------------------------+        +---------------------+
```

### Why Medallion Architecture?

| Benefit | Explanation |
|---------|-------------|
| **Data Traceability** | Raw data is preserved in the Bronze layer; you can always trace back to the original source |
| **Separation of Concerns** | Ingestion (Bronze) is decoupled from transformation (Silver) and analysis |
| **Reprocessing** | If transformation logic changes, Silver can be rebuilt from Bronze without re-ingesting |
| **Data Quality** | Each layer adds validation, deduplication, and normalization |
| **Scalability** | New analysis scripts can be added without modifying the ETL pipeline |

---

## 7. Database Design

The project uses **3 MySQL databases**, each serving a distinct purpose:

### 7.1 Database Overview

| Database | Layer | Tables | Purpose |
|----------|-------|--------|---------|
| `inventory_bronze_layer` | Bronze | 1 | Raw staging - exact mirror of CSV |
| `inventory_analytics` | Bronze | 1 | Cleaned transactional copy (via stored procedure) |
| `inventory_silver_layer` | Silver | 7 | Normalized relational model for analytics |

### 7.2 Bronze Layer Schema

**`raw_inventory_data`** - A single flat table that mirrors the CSV structure exactly. All 15 columns are loaded as-is with no transformation. This preserves the original data for auditability.

**`inventory_transactions`** - A cleaned copy with an auto-increment `transaction_id` primary key. The `Category` and `Region` columns are excluded here since they are dimensional attributes (handled in the Silver layer).

### 7.3 Silver Layer Schema (Normalized - 7 Tables)

The Silver layer decomposes the flat Bronze data into a **normalized relational model** following 3NF principles:

```
                        +------------+
                        |   Stores   |
                        | PK: (store_id, region) |
                        +------+-----+
                               |
          +----------+---------+--------+-----------+
          |          |         |        |           |
    +-----v----+ +--v---+ +---v--+ +---v----+ +----v-----+
    | Inventory| | Sales| |Orders| |Weather | |Forecasts |
    +-----+----+ +--+---+ +---+--+ +--------+ +----+-----+
          |         |         |                      |
          +----+----+---------+----------------------+
               |
         +-----v-----+
         |  Products  |
         | PK: product_id |
         +-----------+
```

| Table | Primary Key | Foreign Keys | Rows | Purpose |
|-------|-------------|--------------|------|---------|
| **Stores** | (store_id, region) | - | 20 | Store master data with composite key |
| **Products** | product_id | - | 30 | Product catalog with category, price, seasonality |
| **Inventory** | inventory_id (auto) | store_id+region, product_id | 109,500 | Daily inventory levels per product-store |
| **Sales** | sale_id (auto) | store_id+region, product_id | 109,500 | Daily sales with discount and promotion data |
| **Orders** | order_id (auto) | store_id+region, product_id | 109,500 | Daily restocking orders |
| **Weather** | (store_id, region, date) | store_id+region | ~14,600 | Daily weather conditions (deduplicated) |
| **Forecasts** | forecast_id (auto) | store_id+region, product_id | 109,500 | Demand forecast values per product-store-day |

### 7.4 Key Design Decisions

1. **Composite Primary Key on Stores**: `(store_id, region)` is used because the same store can operate across multiple regions in this dataset. All child tables carry both `store_id` and `region` as foreign keys.

2. **Deduplication with ROW_NUMBER()**: The `Products` table uses `ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY date)` to pick only the first occurrence of each product, avoiding duplicate inserts. The same technique is used for the `Weather` table.

3. **BOOLEAN Handling**: The `Holiday/Promotion` column is stored as MySQL `BOOLEAN` (TINYINT(1)). The Silver layer ETL uses an explicit `CASE WHEN = 1 THEN 1 ELSE 0 END` to ensure clean boolean mapping.

4. **Referential Integrity**: All fact tables (Inventory, Sales, Orders, Forecasts) enforce foreign key constraints to both Stores and Products, ensuring no orphan records exist.

---

## 8. ETL Pipeline - Step-by-Step

The ETL (Extract, Transform, Load) pipeline is executed as a sequence of SQL scripts:

### Step 0: Session Configuration
**Script**: `MySQL_Local_Session.sql`
- Enables `local_infile` for CSV loading via `SET GLOBAL local_infile = 1`
- Sets UTF-8 encoding with `SET NAMES utf8mb4`
- Documents the full execution order for reproducibility

### Step 1: Bronze DDL (Create Databases & Tables)
**Script**: `Scripts/bronze/bronze_ddl.sql`
- Creates `inventory_bronze_layer` database with `raw_inventory_data` table
- Creates `inventory_analytics` database with `inventory_transactions` table
- Uses `DROP TABLE IF EXISTS` for idempotent reruns

### Step 2: Bronze Data Load
**Script**: `Scripts/bronze/load_data_bronze.sql`
- **Extract**: Loads 109,500 rows from CSV into `raw_inventory_data` using `LOAD DATA LOCAL INFILE`
- **Transform**: Creates stored procedure `load_bronze_to_inventory()` that copies data (minus Category/Region) into `inventory_transactions` with auto-generated transaction IDs
- **Execute**: Calls the stored procedure to populate the analytics table

### Step 3: Silver DDL (Create Normalized Schema)
**Script**: `Scripts/silver/silver_ddl.sql`
- Creates `inventory_silver_layer` database
- Drops tables in correct dependency order (child tables first) to handle foreign key constraints
- Creates 7 normalized tables with proper primary keys, foreign keys, and data types

### Step 4: Silver Data Load (Transform & Normalize)
**Script**: `Scripts/silver/load_data_silver.sql`
- **Products**: Extracts 30 unique products using `ROW_NUMBER()` window function for deduplication
- **Stores**: Extracts unique (store_id, region) pairs using `SELECT DISTINCT`
- **Inventory/Sales/Orders/Forecasts**: Inserts all 109,500 rows with `TRIM()` applied to IDs for data cleanliness
- **Weather**: Deduplicates to one weather record per store-region-date using `ROW_NUMBER()`
- **Boolean Mapping**: Converts `Holiday Promotion` field using explicit `CASE WHEN = 1` logic

### Data Flow Summary

```
CSV File (109,500 rows)
    |
    | LOAD DATA LOCAL INFILE
    v
Bronze: raw_inventory_data (109,500 rows, 15 columns)
    |
    | Stored Procedure: load_bronze_to_inventory()
    v
Bronze: inventory_transactions (109,500 rows, 14 columns + transaction_id)
    |
    | INSERT...SELECT with TRIM, DISTINCT, ROW_NUMBER, CASE
    v
Silver: 7 normalized tables (Stores=20, Products=30, Weather=~14,600, rest=109,500 each)
    |
    | Analytical SQL queries
    v
Analysis: 5 KPI scripts --> Power BI Dashboard
```

---

## 9. Analytical Queries & KPIs

Five analytical SQL scripts produce key business metrics from the Silver layer:

### 9.1 KPI Summary (`Scripts/analysis/KPI_summary.sql`)

**Purpose**: Provides a consolidated view of inventory health per product-store-region.

**Method**:
- Uses 3 CTEs (Common Table Expressions):
  - `InventoryStatus`: Counts total tracked days and days where `inventory_level = 0` (stockouts)
  - `AvgInventory`: Calculates mean inventory level
  - `InventoryAge`: Measures the date span (first to last record) and average level over that span
- Joins all 3 CTEs with the Products table for the final output

**KPIs Produced**:

| KPI | Formula | What It Tells You |
|-----|---------|-------------------|
| Stockout Rate (%) | `(stockout_days / total_days) x 100` | Percentage of days a product was out of stock |
| Avg Inventory Level | `AVG(inventory_level)` | Typical stock quantity held |
| Inventory Days Tracked | `DATEDIFF(MAX(date), MIN(date))` | Total observation window in days |
| Avg Inventory Age | `AVG(inventory_level)` over tracked span | Average holding level across the tracking period |

### 9.2 Stock Summary (`Scripts/analysis/stock_summary.sql`)

**Purpose**: Multi-level inventory aggregation for management reporting.

**Method**: Three progressively detailed queries:

| Query | Granularity | Aggregation |
|-------|-------------|-------------|
| Query 1 | Product-level | `SUM(inventory_level)` across all stores and dates |
| Query 2 | Product + Region | `SUM(inventory_level)` grouped by region |
| Query 3 | Store + Product + Date | Raw detail view, ordered by date descending |

**Use Case**: Executives use Query 1 for high-level view, regional managers use Query 2, and store managers use Query 3.

### 9.3 Inventory Turnover Ratio (`Scripts/analysis/turnover_ratio.sql`)

**Purpose**: Measures how efficiently inventory is being sold and replaced.

**Method**:
- Aggregates monthly sales (`SUM(units_sold)`) and monthly average inventory (`AVG(inventory_level)`) using CTEs
- Calculates turnover ratio: **Units Sold / Average Inventory**
- Handles division-by-zero with `CASE WHEN avg_inventory > 0`
- Classifies each product-store-month into a rating:

| Turnover Ratio | Rating | Interpretation |
|----------------|--------|----------------|
| >= 8 | **High** | Fast-moving product; inventory sells quickly |
| >= 4 and < 8 | **Moderate** | Healthy turnover; balanced supply and demand |
| < 4 | **Low** | Slow-moving; risk of overstocking or obsolescence |
| NULL | **N/A** | No inventory data (avg = 0) |

**Business Value**: High turnover means capital is being used efficiently. Low turnover signals overstocking or declining demand.

### 9.4 Reorder Point Estimation (`Scripts/analysis/reorder_point.sql`)

**Purpose**: Calculates when each product-store should trigger a new purchase order.

**Method**:
- **Step 1**: Identifies the last 30 days of sales data as the demand window
- **Step 2**: Computes average daily sales per product-store-region over that window
- **Step 3**: Applies the Reorder Point formula:

```
Reorder Point (ROP) = Average Daily Sales x Lead Time (7 days)
Reorder Point with Safety Stock = ROP + 10 units
```

**Assumptions**:
| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Lead Time | 7 days | Standard procurement cycle |
| Safety Stock | 10 units | Buffer against demand variability |
| Demand Window | Last 30 days | Recent demand is most representative |

**Business Value**: Tells procurement teams exactly when to reorder each product to avoid stockouts while minimizing excess inventory.

### 9.5 Low Inventory Detection (`Scripts/analysis/low_inventory.sql`)

**Purpose**: Flags products where current stock is below the calculated reorder point - an immediate action alert.

**Method**:
- **Step 1**: Gets the most recent inventory level per product-store using `ROW_NUMBER() ... ORDER BY date DESC`
- **Step 2-4**: Recomputes the reorder point (same logic as 9.4)
- **Step 5**: Filters with `WHERE inventory_level < reorder_point`

**Output**: A ranked list of at-risk items sorted by inventory level ascending (most critical first).

**Business Value**: This is the operational alert script. It directly answers: *"What do we need to order right now?"*

---

## 10. Key Results & Business Insights

The analytical layer produces the following categories of actionable insights:

### 10.1 Stockout Analysis
- Identifies which product-store-region combinations experience the highest stockout rates
- Products with stockout rates above 5% signal chronic supply issues requiring procurement review
- Enables prioritization: fix the highest-impact stockouts first

### 10.2 Inventory Efficiency
- Monthly turnover ratios reveal seasonal patterns (e.g., Toys may have high turnover in Q4/holiday season, low in Q1)
- Low-turnover products across all stores may indicate products that should be discontinued or discounted
- High-turnover products may need larger safety stock buffers

### 10.3 Reorder Intelligence
- Data-driven reorder points replace guesswork-based purchasing
- The 7-day lead time assumption can be adjusted per supplier
- Safety stock of +10 units provides a buffer; this can be made dynamic based on demand variability (standard deviation)

### 10.4 Regional Performance
- Stock summaries by region reveal geographic demand imbalances
- A product overstocked in the North but understocked in the South suggests inter-store transfer opportunities
- Regional analysis supports strategic inventory redistribution

### 10.5 Multi-Dimensional Analysis
- The normalized Silver layer enables cross-cutting analysis: *How do weather conditions affect sales? Do promotions increase turnover? How does competitor pricing correlate with our demand?*
- These dimensions (Weather, Promotions, Competitor Pricing, Seasonality) are preserved in the schema for future advanced analytics

---

## 11. Power BI Dashboard

**File**: `inventory_analytics_dashboard.pbit` (Power BI Template)

The dashboard provides an interactive visualization layer connected to the `inventory_silver_layer` database, enabling stakeholders to:

- View KPI cards for stockout rate, average inventory, and turnover ratio
- Filter by store, region, product category, and time period
- Drill down from regional summaries to individual store-product detail
- Identify low-inventory items visually with conditional formatting
- Track monthly trends for sales, inventory levels, and demand forecasts

**EER Diagram**: `EER_Diagram.pdf` documents the entity-relationship structure of the Silver layer schema.

---

## 12. Project Structure

```
inventory_analytics/
|
|-- MySQL_Local_Session.sql              # Session setup + execution order guide
|-- EER_Diagram.pdf                      # Entity-Relationship Diagram (Silver layer)
|-- inventory_analytics_dashboard.pbit   # Power BI dashboard template
|-- PROJECT_DOCUMENTATION.md             # This document
|-- .gitignore                           # Excludes .idea/ and dataset/ from Git
|
|-- dataset/
|   |-- inventory_forecasting.csv        # Raw data (109,500 rows, ~8.76 MB)
|
|-- Scripts/
|   |-- bronze/
|   |   |-- bronze_ddl.sql              # Creates Bronze databases and tables
|   |   |-- load_data_bronze.sql        # Loads CSV + stored procedure for analytics
|   |
|   |-- silver/
|   |   |-- silver_ddl.sql             # Creates normalized Silver schema (7 tables)
|   |   |-- load_data_silver.sql       # Transforms Bronze data into Silver tables
|   |
|   |-- analysis/
|       |-- KPI_summary.sql            # Stockout rate, avg inventory, inventory age
|       |-- stock_summary.sql          # Multi-level stock aggregation
|       |-- turnover_ratio.sql         # Monthly inventory turnover with ratings
|       |-- reorder_point.sql          # Reorder point estimation (ROP formula)
|       |-- low_inventory.sql          # Low inventory alert/detection
```

---

## 13. How to Run

### Prerequisites
- MySQL 8.0+ installed and running
- JetBrains DataGrip (recommended) or any MySQL client
- Power BI Desktop (for dashboard)

### Execution Steps

```
Step 0:  Run MySQL_Local_Session.sql          (configure session)
Step 1:  Run Scripts/bronze/bronze_ddl.sql    (create Bronze databases + tables)
Step 2:  Run Scripts/bronze/load_data_bronze.sql  (load CSV + execute stored procedure)
            NOTE: Update the CSV file path on line 3 to your local directory
Step 3:  Run Scripts/silver/silver_ddl.sql    (create Silver normalized schema)
Step 4:  Run Scripts/silver/load_data_silver.sql  (transform Bronze -> Silver)
Step 5:  Run any script in Scripts/analysis/  (in any order)
Step 6:  Open inventory_analytics_dashboard.pbit in Power BI Desktop
```

### Important Notes
- Scripts must be run in the order above (Steps 0-4 are sequential; Step 5 scripts are independent)
- The CSV path in `load_data_bronze.sql` (line 3) must be updated to match your local project directory
- `SET GLOBAL local_infile = 1` requires MySQL SUPER or SYSTEM_VARIABLES_ADMIN privilege

---

## 14. Future Enhancements

| Enhancement | Description |
|-------------|-------------|
| **Gold Layer** | Add a Gold layer with pre-aggregated materialized views for dashboard performance |
| **Dynamic Safety Stock** | Replace the fixed +10 safety stock with a formula based on demand standard deviation |
| **Automated Alerts** | Create MySQL Events or triggers to flag low inventory in real-time |
| **Demand Forecasting** | Integrate Python (scikit-learn or Prophet) for ML-based demand prediction |
| **Supplier Lead Time** | Replace the assumed 7-day lead time with actual per-supplier lead time data |
| **ABC Classification** | Implement ABC analysis to categorize products by revenue contribution |
| **Cost Analysis** | Add holding cost, ordering cost, and Economic Order Quantity (EOQ) calculations |
| **Weather Correlation** | Analyze how weather patterns impact sales to improve seasonal forecasting |

---

*Built with MySQL 8.0 | Medallion Architecture | Power BI*
