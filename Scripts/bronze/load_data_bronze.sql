-- STEP 1: Load raw data into the Bronze Layer table from CSV

-- ============================================================
-- IMPORTANT: MySQL Configuration Required Before Running
-- ============================================================
-- 1. Enable local_infile:
--    SET GLOBAL local_infile = 1;
--
-- 2. Check secure_file_priv variable:
--    SHOW VARIABLES LIKE 'secure_file_priv';
--    - If empty: You can load from any path
--    - If set to a directory: Place your CSV file there
--    - If NULL: File loading is disabled (edit my.cnf/my.ini)
--
-- 3. Update the file path below with your actual CSV location:
--    Windows example: 'C:/data/inventory_forecasting_clean.csv'
--    Linux/Mac example: '/home/user/data/inventory_forecasting_clean.csv'
-- ============================================================

LOAD DATA INFILE '/path/to/your/inventory_forecasting_clean.csv'
INTO TABLE inventory_bronze_layer.raw_inventory_data
FIELDS TERMINATED BY ','                      -- CSV column separator
ENCLOSED BY '"'                               -- Handle quoted strings
LINES TERMINATED BY '\n'                      -- Line ending style
IGNORE 1 LINES                                -- Skip the header row
(Date, Store ID, Product ID, Category, Region,
 Inventory Level, Units Sold, Units Ordered,
 Demand Forecast, Price, Discount, Weather Condition,
 Holiday Promotion, Competitor Pricing, Seasonality);


-- STEP 2: Define a stored procedure to load data from the Bronze Layer
--         into the main transactional table in the analytics database

-- Since the procedure contains multiple SQL statements, we must change
-- the default statement delimiter (which is ';') to something else.
-- We use '$$' temporarily so MySQL can parse the full procedure properly.

DELIMITER $$

USE inventory_analytics_urbanco $$

DROP PROCEDURE IF EXISTS load_bronze_to_inventory $$

CREATE PROCEDURE load_bronze_to_inventory()
BEGIN
    -- This procedure moves data from the raw staging table
    -- into the cleaned inventory_transactions table
    INSERT INTO inventory_transactions (
        Date, Store_ID, Product_ID, Inventory_Level, Units_Sold, Units_Ordered,
        Demand_Forecast, Price, Discount, Weather_Condition,
        Holiday_Promotion, Competitor_Pricing, Seasonality
    )
    SELECT
        Date, Store_ID, Product_ID, Inventory_Level, Units_Sold, Units_Ordered,
        Demand_Forecast, Price, Discount, Weather_Condition,
        Holiday_Promotion, Competitor_Pricing, Seasonality
    FROM inventory_bronze_layer.raw_inventory_data;
END $$

-- After defining the procedure, we reset the delimiter back to ';'
-- so that normal SQL statements continue to work as expected.

DELIMITER ;
