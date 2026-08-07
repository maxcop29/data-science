--DATA CLEANING
UPDATE blinkit_grocery_data
SET Item_Fat_Content = 
    CASE 
        WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END;

SELECT  DISTINCT item_fat_content
FROM blinkit_grocery_data;

--A.KPI's

SELECT * FROM blinkit_grocery_data;

-- Total Sales:
SELECT SUM(total_sales)  AS total_sales
FROM blinkit_grocery_data;

-- Average Sales:
SELECT ROUND(AVG(total_sales),2) AS avg_sales
FROM blinkit_grocery_data;

-- Number of Items:
SELECT COUNT(*) AS no_of_items
FROM blinkit_grocery_data;

-- Average Rating:
SELECT ROUND(AVG(rating),2) AS avg_rating
FROM blinkit_grocery_data;

--b.business requirements
-- Total Sales by Fat Content:
SELECT Item_fat_content,SUM(total_sales) AS total_sales
FROM blinkit_grocery_data
GROUP BY item_fat_content
ORDER BY total_sales DESC;

-- Total Sales by Item Type:
SELECT Item_type,SUM(total_sales) AS total_sales
FROM blinkit_grocery_data
GROUP BY item_type
ORDER BY total_sales DESC;

-- Total Sales by Outlet Establishment:
SELECT outlet_establishment_year,SUM(total_sales) AS total_sales
FROM blinkit_grocery_data
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year DESC;

-- Percentage of Sales by Outlet Size:
SELECT 
    outlet_Size,
    SUM(total_sales) AS Total_Sales,
    (SUM(total_sales) * 100.0 / (SELECT SUM(total_sales) FROM blinkit_grocery_data)) AS Percentage_Of_Sales
FROM blinkit_grocery_data
GROUP BY outlet_Size;

-- All Metrics by Outlet Type:
SELECT 
outlet_Type,
    SUM(total_sales) AS Total_Sales,
    AVG(total_sales) AS Average_Sales,
    COUNT(*) AS Number_of_Items,
    AVG(rating) AS Average_Rating
FROM blinkit_grocery_data
GROUP BY outlet_Type;

--Fat Content by Outlet for Total Sales
SELECT 
    Outlet_Location_Type,
    COALESCE(SUM(Total_Sales) FILTER (WHERE Item_Fat_Content = 'Low Fat'), 0)::DECIMAL(10, 2) AS Low_Fat,
    COALESCE(SUM(Total_Sales) FILTER (WHERE Item_Fat_Content = 'Regular'), 0)::DECIMAL(10, 2) AS Regular
FROM 
    blinkit_grocery_data
GROUP BY 
    Outlet_Location_Type
ORDER BY 
    Outlet_Location_Type;