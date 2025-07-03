-- Create Database
CREATE DATABASE IF NOT EXISTS grocery_db;

USE grocery_db;

-- Create Tables
CREATE TABLE grocery_inventory (
    product_name VARCHAR(100),
    category VARCHAR(50),
    supplier_name VARCHAR(50),
    status VARCHAR(50),
    product_id INT,
    supplier_id INT,
    date_received DATE,
    stock_count INT,
    reorder_count INT,
    reorder_qty INT,
    unit_price DECIMAL(10,2),
    sales_volume INT,
    turnover_rate INT
);

-- Verify import data
SELECT * FROM grocery_db.grocery_inventory LIMIT 10 ;

-- Rename column typo from Excel
ALTER TABLE grocery_inventory RENAME COLUMN Catagory TO category;

-- Exploratory Data Analysis
SELECT COUNT(*) AS total_records FROM grocery_inventory;
SELECT DISTINCT COUNT(product_id) FROM grocery_inventory;
SELECT DISTINCT COUNT(supplier_id) FROM grocery_inventory;

-- Check for null or missing values
SELECT 
  SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS missing_product_name,
  SUM(CASE WHEN Unit_Price IS NULL THEN 1 ELSE 0 END) AS missing_price,
  SUM(CASE WHEN Stock_Quantity IS NULL THEN 1 ELSE 0 END) AS missing_stock,
  SUM(CASE WHEN Reorder_Level IS NULL THEN 1 ELSE 0 END) AS missing_level,
  SUM(CASE WHEN Reorder_Quantity IS NULL THEN 1 ELSE 0 END) AS missing_reorder,
  SUM(CASE WHEN Sales_Volume IS NULL THEN 1 ELSE 0 END) AS missing_volume,
  SUM(CASE WHEN Inventory_Turnover_Rate IS NULL THEN 1 ELSE 0 END) AS missing_turnover,
  SUM(CASE WHEN percentage IS NULL THEN 1 ELSE 0 END) AS missing_percentage
FROM grocery_inventory;

-- Distinct Categories
SELECT DISTINCT Category FROM grocery_inventory;

-- Average unit price per category
SELECT 
  category, 
  ROUND(AVG(Unit_Price), 2) AS avg_price
FROM grocery_inventory
GROUP BY category
ORDER BY avg_price DESC;

-- Top Selling Items
SELECT 
  product_name, 
  SUM(sales_volume) AS total_sold
FROM grocery_inventory
GROUP BY product_name
ORDER BY total_sold DESC
LIMIT 10;

-- Monthly Inventory
SELECT 
  DATE_FORMAT(date_received, '%Y-%m') AS month,
  COUNT(*) AS items_received,
  SUM(stock_quantity) AS total_quantity
FROM grocery_inventory
GROUP BY month
ORDER BY month;

-- Price elasticity
SELECT 
  category, 
  ROUND(AVG(unit_price), 2) AS avg_price,
  ROUND(AVG(stock_quantity), 0) AS avg_quantity
FROM grocery_inventory
GROUP BY category
ORDER BY avg_quantity DESC;

-- Category Price Month over Month
WITH monthly_prices AS (
  SELECT
    category,
    DATE_FORMAT(Date_Received, '%Y-%m') AS month,
    ROUND(AVG(Unit_Price), 2) AS avg_price
  FROM Grocery_Inventory
  GROUP BY category, DATE_FORMAT(Date_Received, '%Y-%m')
),
price_changes AS (
  SELECT
    category,
    month,
    avg_price,
    LAG(avg_price) OVER (PARTITION BY category ORDER BY month) AS prev_price
  FROM monthly_prices
)
SELECT
  category,
  month,
  avg_price,
  prev_price,
  ROUND(avg_price - prev_price, 2) AS price_change,
  ROUND((avg_price - prev_price) / prev_price * 100, 2) AS percent_change
FROM price_changes
WHERE prev_price IS NOT NULL
ORDER BY category, month;

-- Flag items below reorder level
SELECT 
  Product_Name,
  category,
  Stock_Quantity,
  Reorder_Level,
  Reorder_Quantity
FROM Grocery_Inventory
WHERE Stock_Quantity < Reorder_Level
ORDER BY Stock_Quantity ASC;

-- Identify items at risk for overstock
SELECT 
  Product_Name,
  category,
  Stock_Quantity,
  Inventory_Turnover_Rate,
  Unit_Price
FROM Grocery_Inventory
WHERE Inventory_Turnover_Rate < 30 AND Stock_Quantity > 50
ORDER BY Stock_Quantity DESC;




