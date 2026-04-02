-- Load raw data into the Bronze Layer table from CSV
-- NOTE: Update the file path below to match your local project directory
LOAD DATA LOCAL INFILE 'D:/Inventory_Analytics/dataset/inventory_forecasting.csv'
INTO TABLE inventory_bronze_layer.raw_inventory_data
FIELDS TERMINATED BY ','                      -- CSV column separator
ENCLOSED BY '"'                               -- Handle quoted strings
LINES TERMINATED BY '\n'                      -- Line ending style
IGNORE 1 LINES                                -- Skip the header row
(`Date`, `Store ID`, `Product ID`, `Category`, `Region`,
 `Inventory Level`, `Units Sold`, `Units Ordered`,
 `Demand Forecast`, `Price`, `Discount`, `Weather Condition`,
 `Holiday Promotion`, `Competitor Pricing`, `Seasonality`);


-- Define a stored procedure to load data from the Bronze Layer into the main transactional table in the analytics database
DELIMITER $$

USE inventory_analytics $$

DROP PROCEDURE IF EXISTS load_bronze_to_inventory $$

CREATE PROCEDURE load_bronze_to_inventory()
BEGIN
    -- This procedure moves data from the raw staging table
    -- into the cleaned inventory_transactions table
    INSERT INTO inventory_transactions (
        `Date`, `Store ID`, `Product ID`, `Inventory Level`, `Units Sold`, `Units Ordered`,
        `Demand Forecast`, `Price`, `Discount`, `Weather Condition`,
        `Holiday Promotion`, `Competitor Pricing`, `Seasonality`
    )
    SELECT
        `Date`, `Store ID`, `Product ID`, `Inventory Level`, `Units Sold`, `Units Ordered`,
        `Demand Forecast`, `Price`, `Discount`, `Weather Condition`,
        `Holiday Promotion`, `Competitor Pricing`, `Seasonality`
    FROM inventory_bronze_layer.raw_inventory_data;
END $$

-- After defining the procedure, we reset the delimiter back to ';'
-- so that normal SQL statements continue to work as expected.

DELIMITER ;

-- Execute the stored procedure to populate inventory_analytics.inventory_transactions
CALL load_bronze_to_inventory();
