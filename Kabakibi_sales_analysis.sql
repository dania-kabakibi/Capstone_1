-- The sales territory is the state of Massachusetts, located in the Northeast region

USE sample_sales;

SELECT * FROM management WHERE SalesManager = 'Bo Heap';
-- # id, Region, RegionalDirector, State, SalesManager
-- 4, Northeast, Michael Jarvis, Massachusetts, Bo Heap
-- ==============================================

-- 1- What is total revenue overall for sales in the assigned territory, plus 
-- the start date and end date that tell you what period the data covers?

SELECT SUM(ss.Sale_Amount) AS 'Total_revenue',
	MIN(ss.Transaction_Date) AS 'Start_date',
	MAX(ss.Transaction_Date) AS 'End_date'
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Massachusetts';

-- ==============================================

-- 2- What is the month by month revenue breakdown for the sales territory?

SELECT  
	DATE_FORMAT(Transaction_Date, '%Y-%m') AS 'Date_YYYY-MM',
	SUM(Sale_Amount) AS 'monthly_revenue'
FROM store_sales
WHERE Store_ID IN (SELECT StoreId FROM store_locations WHERE State = 'Massachusetts')
GROUP BY DATE_FORMAT(Transaction_Date, '%Y-%m')
ORDER BY 'Date_YYYY-MM';

-- ==============================================

-- 3- Provide a comparison of total revenue for the specific sales territory 
-- and the region it belongs to.

WITH territory_total_revenue AS (
	SELECT SUM(ss.Sale_Amount) AS 'state_total_revenue'
	FROM store_sales ss
	JOIN store_locations sl
	ON ss.Store_ID = sl.StoreId
	WHERE State = 'Massachusetts'),
region_total_revenue AS (
	SELECT SUM(ss.Sale_Amount) AS 'region_total_revenue'
	FROM store_sales ss
	JOIN store_locations sl
	ON ss.Store_ID = sl.StoreId
	WHERE State IN (SELECT State FROM management WHERE Region = 'Northeast'))
SELECT territory_total_revenue.state_total_revenue, region_total_revenue.region_total_revenue
FROM territory_total_revenue, region_total_revenue;

-- ==============================================

-- 4- What is the number of transactions per month and average transaction size by product 
-- category for the sales territory?

SELECT 
	ic.Category,
	COUNT(ss.id) AS 'Num_of_transaction',
	DATE_FORMAT(ss.Transaction_Date, '%M') AS 'Month',
    AVG(ss.Sale_Amount) AS 'Average_transaction_size'
FROM store_sales ss
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
JOIN products p ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories ic ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'Massachusetts'
GROUP BY ic.Category, DATE_FORMAT(Transaction_Date, '%M');

-- ==============================================

-- 5- Can you provide a ranking of in-store sales performance by each store in the sales territory, 
-- or a ranking of online sales performance by state within an online sales territory?

-- Ranking in-store performance for Massachusetts
SELECT Store_ID,
	SUM(Sale_Amount) AS 'total_revenue',
	RANK() OVER (ORDER BY SUM(Sale_Amount) DESC) AS 'in-store_sales_rank'
FROM store_sales
WHERE Store_ID IN (SELECT StoreId FROM store_locations WHERE State = 'Massachusetts')
GROUP BY Store_ID;

-- ==============================================

-- What is your recommendation for where to focus sales attention in the next quarter?

/* 
Based on my SQL analysis, I observed the following key trends:
1. Growth & Impact: Monthly revenue in the Massachusetts territory increased gradually from 2022 to 2025. 
   Furthermore, comparing the state total revenue ($5,733,256.27) to the Northeast regional total 
   ($24,237,526.98) shows that Massachusetts is a significant contributor, accounting for 
   nearly 24% of the entire region's revenue.

2. Product Value: The 'Technology & Accessories' category maintains the highest average 
   transaction size across all months, followed closely by the 'Textbooks' category.

3. Store Performance Gap: There is a substantial performance gap within the territory. 
   Store 817 is the top performer ($602,183.44), while the second-highest, Store 807, 
   lags significantly behind ($338,009.10). 

Recommendation:
I recommend a dual-focus strategy for the next quarter. First, we should maximize high-value 
categories by prioritizing 'Technology & Accessories' sales across the state through 
targeted promotions. Second, we must bridge the performance gap between our top-tier 
and mid-tier locations. Specifically, I recommend using Store 817 as a training model 
and having the manager of Store 807 observe their sales techniques and floor layout 
to help increase overall territory revenue.
*/