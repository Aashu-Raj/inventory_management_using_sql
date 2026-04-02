-- ============================================================
-- MySQL Local Session Setup
-- Run this file once before executing any project scripts.
-- It configures the session and documents the execution order.
-- ============================================================

-- Allow loading local CSV files via LOAD DATA LOCAL INFILE
SET GLOBAL local_infile = 1;

-- Use UTF-8 encoding for the session
SET NAMES utf8mb4;

-- ============================================================
-- Script Execution Order
-- Run scripts in the following sequence:
--
-- 1. Scripts/bronze/bronze_ddl.sql
--    Creates inventory_bronze_layer and inventory_analytics databases
--    with their respective tables.
--
-- 2. Scripts/bronze/load_data_bronze.sql
--    Loads CSV data into inventory_bronze_layer.raw_inventory_data,
--    then defines and calls the stored procedure to populate
--    inventory_analytics.inventory_transactions.
--
-- 3. Scripts/silver/silver_ddl.sql
--    Creates the normalized inventory_silver_layer database
--    (Stores, Products, Inventory, Sales, Orders, Weather, Forecasts).
--
-- 4. Scripts/silver/load_data_silver.sql
--    Transforms and loads data from the bronze layer into the
--    normalized silver layer tables.
--
-- 5. Scripts/analysis/*.sql (run in any order)
--    KPI_summary.sql     - Stockout rate, avg inventory, inventory age
--    stock_summary.sql   - Total/regional/store-level stock counts
--    turnover_ratio.sql  - Monthly inventory turnover ratios
--    reorder_point.sql   - Reorder point estimation per product/store
--    low_inventory.sql   - Flags items below reorder threshold
-- ============================================================
