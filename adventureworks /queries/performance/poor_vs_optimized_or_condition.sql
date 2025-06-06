/*
  Purpose     : Demonstrate performance difference between a query using OR vs. a UNION ALL strategy.
  Scenario    : Find orders where the customer is either 11000 or TotalDue is over 10,000.
*/

-- Poor Performance: OR condition prevents index seek on either column
-- This can lead to a full table scan, even if indexes exist on CustomerID or TotalDue
SELECT SalesOrderID,
       CustomerID,
       TotalDue,
       OrderDate
FROM   Sales.SalesOrderHeader
WHERE  CustomerID = 11000
   OR  TotalDue > 10000;  -- BAD: mixed conditions block index usage

-- Optimized Performance: UNION ALL allows both parts to use indexes
-- Breaks into two index-friendly queries that the engine can optimize independently
SELECT 
    SalesOrderID,
    CustomerID,
    TotalDue,
    OrderDate
FROM Sales.SalesOrderHeader
WHERE CustomerID = 11000

UNION ALL

SELECT 
    SalesOrderID,
    CustomerID,
    TotalDue,
    OrderDate
FROM Sales.SalesOrderHeader
WHERE TotalDue > 10000
  AND CustomerID <> 11000;  -- Avoid duplication from first query
