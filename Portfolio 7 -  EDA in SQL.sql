---------------------------------------------------------------------------------------------------------------------------------
      -- PORTFOLIO PROJECT - KAGGLE GLOBAL SUPERSTORE DATA - (SQL EXPLORATORY DATA ANALYSIS --> TABLEAU SALES DASHBOARD) --
---------------------------------------------------------------------------------------------------------------------------------

-- Checking for how many rows of data we are working with

SELECT COUNT(*)
FROM GlobalSuperstoreSales..Orders


---------------------------------------------------------------------------------------------------------------------------------
-- CHECKING FOR PRIMARY KEY (UNIQUE ROW IDENTIFIER)

-- Can Order ID be primary key? (NO)

SELECT [Order ID], COUNT([Order ID])
FROM GlobalSuperstoreSales..Orders
GROUP BY [Order ID]
HAVING COUNT([Order ID]) > 1

SELECT *
FROM GlobalSuperstoreSales..Orders
WHERE [Order ID] = 'AG-2013-8490'

-- Can Row ID and Order ID be composite primary key? (YES)

SELECT [Row ID], [Order ID], COUNT(*)
FROM GlobalSuperstoreSales..Orders
GROUP BY [Row ID], [Order ID]
HAVING COUNT(*) > 1


---------------------------------------------------------------------------------------------------------------------------------
-- CHECKING FOR POTENTIAL INCORRECT ROWS / DATA

-- Any rows where ship date is incorrectly before order date? (NO)

SELECT *
FROM GlobalSuperstoreSales..Orders
WHERE [Ship Date] < [Order Date]


---------------------------------------------------------------------------------------------------------------------------------
-- DETERMINING WHAT EACH SHIP MODE'S SHIPPING TIME IN DAYS IS BY USING DATEDIFF FUNCTION AND A SUBQUERY

-- Checking for different types of ship modes (4)

SELECT DISTINCT [Ship Mode]
FROM GlobalSuperstoreSales..Orders

-- Same day (0-1)

SELECT min(a.ShippingTimeInDays), max(a.ShippingTimeInDays)
FROM
(SELECT DATEDIFF(DAY, [Order Date], [Ship Date]) AS ShippingTimeInDays, *
FROM GlobalSuperstoreSales..Orders
WHERE[Ship Mode] = 'Same Day' ) a

-- First class (1-3)

SELECT min(a.ShippingTimeInDays), max(a.ShippingTimeInDays)
FROM
(SELECT DATEDIFF(DAY, [Order Date], [Ship Date]) AS ShippingTimeInDays, *
FROM GlobalSuperstoreSales..Orders
WHERE[Ship Mode] = 'First Class' ) a

-- Second class (2-5)

SELECT min(a.ShippingTimeInDays), max(a.ShippingTimeInDays)
FROM
(SELECT DATEDIFF(DAY, [Order Date], [Ship Date]) AS ShippingTimeInDays, *
FROM GlobalSuperstoreSales..Orders
WHERE[Ship Mode] = 'Second Class' ) a

-- Standard class (4-7)

SELECT min(a.ShippingTimeInDays), max(a.ShippingTimeInDays)
FROM
(SELECT DATEDIFF(DAY, [Order Date], [Ship Date]) AS ShippingTimeInDays, *
FROM GlobalSuperstoreSales..Orders
WHERE[Ship Mode] = 'Standard Class' ) a


---------------------------------------------------------------------------------------------------------------------------------
-- ANALYZING CUSTOMER AND ORDER DATA

SELECT [Customer ID], [Order ID], COUNT(*) AS NumItemsOrdered
FROM GlobalSuperstoreSales..Orders
GROUP BY [Customer ID], [Order ID]
ORDER BY [Customer ID]

-- Analyzing a specific order more detailed

SELECT *
FROM GlobalSuperstoreSales..Orders
WHERE [Order ID] = 'CA-2011-128055'
