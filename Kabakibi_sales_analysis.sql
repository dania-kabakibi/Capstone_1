-- The sales territory is the state of Massachusetts, located in the Northeast region

USE sample_sales;

SELECT * FROM management WHERE SalesManager = 'Bo Heap';
-- # id, Region, RegionalDirector, State, SalesManager
-- 4, Northeast, Michael Jarvis, Massachusetts, Bo Heap
-- ==============================================

-- What is total revenue overall for sales in the assigned territory, plus 
-- the start date and end date that tell you what period the data covers?

WITH online_sales_cal AS (
	SELECT SUM(SalesTotal) AS 'online_total_revenue',
		MIN(Date) AS 'Start_date',
		MAX(Date) AS 'End_date'
	FROM online_sales
	WHERE ShiptoState = 'Massachusetts'),

store_sales_cal AS (
	SELECT SUM(ss.Sale_Amount) AS 'store_total_revenue',
		MIN(ss.Transaction_Date) AS 'Start_date',
		MAX(ss.Transaction_Date) AS 'End_date'
	FROM store_sales ss
	JOIN store_locations sl
	ON ss.Store_ID = sl.StoreId
	WHERE State = 'Massachusetts')

SELECT 
	(online_sales_cal.online_total_revenue + store_sales_cal.store_total_revenue) AS 'Total_revenue',
	LEAST(online_sales_cal.Start_date, store_sales_cal.Start_date) AS 'Start_date',
    GREATEST(online_sales_cal.End_date, store_sales_cal.End_date) AS 'End_date'
FROM online_sales_cal, store_sales_cal;

-- ==============================================

-- What is the month by month revenue breakdown for the sales territory?

SELECT revenue_month, SUM(monthly_revenue) AS 'total_monthly_revenue'
 FROM (
	 SELECT  
		DATE_FORMAT(Transaction_Date, '%Y-%m') AS 'revenue_month',
		SUM(Sale_Amount) AS 'monthly_revenue'
	FROM store_sales
	WHERE Store_ID IN (SELECT StoreId FROM store_locations WHERE State = 'Massachusetts')
	GROUP BY DATE_FORMAT(Transaction_Date, '%Y-%m')
    
    UNION ALL
    
    SELECT DATE_FORMAT(Date, '%Y-%m') AS 'revenue_month', 
		SUM(SalesTotal) AS 'monthly_revenue'
    FROM online_sales
    WHERE ShiptoState = 'Massachusetts'
    GROUP BY DATE_FORMAT(Date, '%Y-%m')
) AS combined_sales
GROUP BY revenue_month;

-- ==============================================

-- Provide a comparison of total revenue for the specific sales territory 
-- and the region it belongs to.

WITH massachusetts_sales_cal AS (
	SELECT (
		SELECT SUM(SalesTotal) AS 'online_state_total_revenue'
		FROM online_sales
		WHERE ShiptoState = 'Massachusetts') + 
		(
		SELECT SUM(ss.Sale_Amount) AS 'store_state_total_revenue'
		FROM store_sales ss
		JOIN store_locations sl
		ON ss.Store_ID = sl.StoreId
		WHERE State = 'Massachusetts')
	AS 'territory_total_revenue'
	),
northeast_region_cal AS (
	SELECT (
		SELECT SUM(SalesTotal) AS 'online_region_total_revenue'
		FROM online_sales
		WHERE ShiptoState IN (SELECT State FROM management WHERE Region = 'Northeast')) +
	( SELECT SUM(ss.Sale_Amount) AS 'store_region_total_revenue'
		FROM store_sales ss
		JOIN store_locations sl
		ON ss.Store_ID = sl.StoreId
		WHERE State IN (SELECT State FROM management WHERE Region = 'Northeast'))
	AS 'region_total_revenue'
	)
SELECT 
	massachusetts_sales_cal.territory_total_revenue AS 'Total_revenue_for_Massachusetts',
	northeast_region_cal.region_total_revenue AS 'northeast_region_total_revenue'
FROM massachusetts_sales_cal, northeast_region_cal;