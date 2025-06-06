/*
  Purpose     : Compare a non-SARGable date filter with an optimized, index-friendly version.
  Scenario    : Retrieve all orders placed in 2013 from Sales.SalesOrderHeader.
*/

-- Poor Performance: Non-SARGable (prevents index usage)
-- Applying a function to the OrderDate column disables index seeks
SELECT SalesOrderID,
       OrderDate,
       TotalDue
FROM   Sales.SalesOrderHeader
WHERE  YEAR(OrderDate) = 2013;  -- BAD: function on column causes table scan



-- Optimized Performance: SARGable (enables index usage)
-- Uses a date range to filter without applying a function on the column
SELECT SalesOrderID,
       OrderDate,
       TotalDue
FROM   Sales.SalesOrderHeader
WHERE  OrderDate >= '2013-01-01'
  AND  OrderDate <  '2014-01-01';  -- GOOD: index seek supported
