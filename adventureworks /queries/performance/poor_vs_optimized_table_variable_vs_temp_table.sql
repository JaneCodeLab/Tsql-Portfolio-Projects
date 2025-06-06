/*
  Purpose     : Compare performance and execution plan differences between table variables and temporary tables.
  Scenario    : Store and query recent high-value orders for analysis.
*/

-- Poor Performance: Table variable with moderate-to-large dataset
-- Problem:
--   - Table variables do not have statistics.
--   - SQL Server assumes 1 row unless forced otherwise.
--   - Often leads to bad plans (e.g., nested loops over hash join).
DECLARE @RecentOrders TABLE (
                              SalesOrderID INT,
                              CustomerID INT,
                              TotalDue MONEY,
                              OrderDate DATE);

INSERT INTO @RecentOrders
SELECT 
       SalesOrderID,
       CustomerID,
       TotalDue,
       OrderDate
FROM   Sales.SalesOrderHeader
WHERE  OrderDate >= '2013-01-01'
  AND  TotalDue > 1000;

-- Query on @table (may use poor plan due to underestimated row count)
SELECT 
          CustomerID,
          COUNT(*)      AS OrderCount,
          SUM(TotalDue) AS TotalSpent
FROM      @RecentOrders
GROUP  BY CustomerID;

-- Cleanup step:
-- No need to drop @RecentOrders — table variables are scoped to the batch or procedure and are deallocated automatically.
-- DROP TABLE @RecentOrders;  -- This would throw an error





-- Optimized Performance: Temporary table with statistics
-- Benefits:
--   - #TempTable supports statistics and row estimates.
--   - Better join and aggregation plans.
--   - Indexes can be added if needed (clustered or non-clustered).
CREATE TABLE #RecentOrders (
                             SalesOrderID INT,
                             CustomerID INT,
                             TotalDue MONEY,
                             OrderDate DATE);

INSERT INTO #RecentOrders
SELECT 
        SalesOrderID,
        CustomerID,
        TotalDue,
        OrderDate
FROM    Sales.SalesOrderHeader
WHERE   OrderDate >= '2013-01-01'
  AND   TotalDue > 1000;

-- Query on #temp (will usually generate much better plan)
SELECT 
         CustomerID,
         COUNT(*)      AS OrderCount,
         SUM(TotalDue) AS TotalSpent
FROM     #RecentOrders
GROUP BY CustomerID;


-- Cleanup step:
-- Always drop #temp tables explicitly to release tempdb resources
DROP TABLE #RecentOrders;
