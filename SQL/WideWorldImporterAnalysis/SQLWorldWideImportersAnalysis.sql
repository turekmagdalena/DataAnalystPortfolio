/*** DATA PREPARATION ***/

/*** Check if there are any orders that were not picked ***/

/***

WITH Orders_CTE
AS
(SELECT o.[OrderID], o.[CustomerID], o.[OrderDate], ol.[StockItemID], ol.[Quantity], ol.[UnitPrice], ol.[TaxRate], ol.PickingCompletedWhen
FROM [WideWorldImporters].[Sales].[Orders] AS o
JOIN [WideWorldImporters].[Sales].[OrderLines] AS ol
ON o.[OrderID] = ol.[OrderID]
)
SELECT * FROM Orders_CTE

WHERE PickingCompletedWhen IS NULL

ORDER BY OrderID

***/

--- Let's skip these orders in further analysis.


/*** Calculate order line cost (this is a scenario where I don't have the access to invoices' data) ***/

/***
WITH Orders_CTE
AS
(SELECT o.[OrderID], o.[CustomerID], o.[OrderDate], ol.[StockItemID], ol.UnitPrice, (ol.Quantity * ol.UnitPrice) * (1 + ol.TaxRate/100) AS OrderLineCost
FROM [WideWorldImporters].[Sales].[Orders] AS o
JOIN [WideWorldImporters].[Sales].[OrderLines] AS ol
ON o.[OrderID] = ol.[OrderID]
WHERE ol.PickingCompletedWhen IS NOT NULL
)
SELECT * FROM Orders_CTE

WHERE OrderID < 10

ORDER BY OrderID
***/

/*** DATA ANALYSIS ***/

/*** For each month - check amount of orders and their income.
	Purpose: check if the results significantly change depending on the month.***/

/***
--First check amount of orders

SELECT YEAR(OrderDate) as OrderYear, MONTH(OrderDate) as OrderMonth, COUNT(OrderID) as AmountOfOrders
FROM WideWorldImporters.Sales.Orders 
WHERE PickingCompletedWhen IS NOT NULL

GROUP BY YEAR(OrderDate), MONTH(OrderDate)

ORDER BY COUNT(OrderID) DESC;

--Check how much income orders generate

WITH Orders_CTE
AS
(SELECT o.[OrderID], o.[CustomerID], o.[OrderDate], ol.[StockItemID], ol.UnitPrice, (ol.Quantity * ol.UnitPrice) * (1 + ol.TaxRate/100) AS OrderLineCost
FROM [WideWorldImporters].[Sales].[Orders] AS o
JOIN [WideWorldImporters].[Sales].[OrderLines] AS ol
ON o.[OrderID] = ol.[OrderID]
WHERE ol.PickingCompletedWhen IS NOT NULL
)

SELECT YEAR(OrderDate) as OrderYear, MONTH(OrderDate) as OrderMonth, SUM(OrderLineCost) as OrdersIncomePerMonth
FROM Orders_CTE

GROUP BY YEAR(OrderDate), MONTH(OrderDate) 

ORDER BY SUM(OrderLineCost) DESC

***/


/*** For each month - check which Stock Items are the most popular.
	Purpose: check if the results significantly change depending on the month. ***/

/***
WITH Orders_CTE
AS
(SELECT o.[OrderDate], ol.[StockItemID]
FROM [WideWorldImporters].[Sales].[Orders] AS o
JOIN [WideWorldImporters].[Sales].[OrderLines] AS ol
ON o.[OrderID] = ol.[OrderID]
WHERE ol.PickingCompletedWhen IS NOT NULL
),
MonhtlyOrders_CTE 
AS
(SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) as OrderMonth, StockItemID,
COUNT(StockItemID) AS StockItemAmount,
RANK() OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate) ORDER BY COUNT(StockItemID) DESC) AS Rank
FROM Orders_CTE
GROUP BY YEAR(OrderDate), MONTH(OrderDate), StockItemID
)

SELECT * FROM MonhtlyOrders_CTE
WHERE Rank <= 3
ORDER BY OrderYear, OrderMonth, Rank

***/


/*** Which customers spend the most money - by sum and average? 
	Purpose: identify customers who spend a lot of money on a fewer transactions, or the ones that buy a lot cheaper products etc. 
	to be able to propose individually tailored promotional campaigns. ***/

/***
WITH Orders_CTE
AS
(SELECT o.[CustomerID], (ol.Quantity * ol.UnitPrice) * (1 + ol.TaxRate/100) AS OrderLineCost
FROM [WideWorldImporters].[Sales].[Orders] AS o
JOIN [WideWorldImporters].[Sales].[OrderLines] AS ol
ON o.[OrderID] = ol.[OrderID]
WHERE ol.PickingCompletedWhen IS NOT NULL
)
SELECT CustomerID, 
	SUM(OrderLineCost) as SumOfOrders, 
	AVG(OrderLineCost) as AverageSpent,
	RANK() OVER (ORDER BY SUM(OrderLineCost) DESC) AS SumRank,
	RANK() OVER (ORDER BY AVG(OrderLineCost) DESC) AS AvgRank
FROM Orders_CTE
GROUP BY CustomerID
ORDER BY SumRank 

***/

/*** Which is more profitable - selling a lot of cheap products or a few expensive ones? ***/ 

-- First I need to verify what are differences between prices
/***
SELECT DISTINCT(UnitPrice) 
FROM [WideWorldImporters].[Sales].[OrderLines]
ORDER BY UnitPrice
***/

-- As a 'cheap item' I will treat the ones with price below 10, and 'expensive' above 100 (or more)

/***
SELECT 
    SUM(CASE WHEN UnitPrice < 10 THEN Quantity * UnitPrice ELSE 0 END) AS SummedOrders_LessThan10,
    SUM(CASE WHEN UnitPrice > 100 THEN Quantity * UnitPrice ELSE 0 END) AS SummedOrders_MoreThan100,
	SUM(CASE WHEN UnitPrice > 200 THEN Quantity * UnitPrice ELSE 0 END) AS SummedOrders_MoreThan200
FROM 
    [WideWorldImporters].[Sales].[OrderLines]
WHERE 
    UnitPrice < 10 OR UnitPrice > 100;

***/