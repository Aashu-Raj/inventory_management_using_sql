# Create Database(inventory_bronze_layer)
CREATE DATABASE IF NOT EXISTS inventory_bronze_layer;
USE inventory_bronze_layer;

# Create Raw Data Table(raw_inventory_data) (Same Structure as CSV)
DROP TABLE IF EXISTS raw_inventory_data;
CREATE TABLE raw_inventory_data (
  `Date` DATE,
  `Store ID` VARCHAR(10),
  `Product ID` VARCHAR(15),
  `Category` VARCHAR(50),
  `Region` VARCHAR(50),
  `Inventory Level` INT,
  `Units Sold` INT,
  `Units Ordered` INT,
  `Demand Forecast` FLOAT,
  `Price` DECIMAL(10,2),
  `Discount` DECIMAL(5,2),
  `Weather Condition` VARCHAR(50),
  `Holiday Promotion` BOOLEAN,
  `Competitor Pricing` DECIMAL(10,2),
  `Seasonality` VARCHAR(50)
);

# Create Database(inventory_analytics_urbanco)
CREATE DATABASE IF NOT EXISTS inventory_analytics_urbanco;
USE inventory_analytics_urbanco;

#Create table(inventory_transactions)
DROP TABLE IF EXISTS inventory_transactions;

CREATE TABLE inventory_transactions (
    `transaction_id` INT AUTO_INCREMENT PRIMARY KEY,
    `Date` DATE,
    `Store ID` VARCHAR(10),
    `Product ID` VARCHAR(15),
    `Inventory Level` INT,
    `Units Sold` INT,
    `Units Ordered` INT,
    `Demand Forecast` FLOAT,
    `Price` DECIMAL(10,2),
    `Discount` DECIMAL(5,2),
    `Weather Condition` VARCHAR(50),
    `Holiday Promotion` BOOLEAN,
    `Competitor Pricing` DECIMAL(10,2),
    `Seasonality` VARCHAR(50)
);

