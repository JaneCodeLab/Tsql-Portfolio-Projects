/*
  Purpose     : Optimize queries that repeat aggregation logic by using CROSS APPLY.
  Scenario    : Retrieve customer info along with their total order amount.
*/

-- Poor Performance: Aggregation repeated in SELECT and ORDER BY
-- Problem:
--   - The subquery that calculates SUM(TotalDue) runs TWICE per row (once for SELECT, once for ORDER BY).
--   - SQL Server cannot reuse the result — it executes both independently.
--   - On large data sets, this causes unnecessary CPU usage, memory pressure, and slow execution.
SELECT 
    cstmr.CustomerID,
    cstmr.AccountNumber,
    (   
        SELECT SUM(sl_ord_hdr.TotalDue)
        FROM Sales.SalesOrderHeader AS sl_ord_hdr
        WHERE sl_ord_hdr.CustomerID = cstmr.CustomerID   )	AS TotalSpent  -- BAD: duplicated aggregation

FROM Sales.Customer AS cstmr

ORDER BY (
           SELECT SUM(sl_ord_hdr.TotalDue)
           FROM Sales.SalesOrderHeader AS sl_ord_hdr
           WHERE sl_ord_hdr.CustomerID = cstmr.CustomerID ) DESC;  -- BAD: same subquery repeated here




-- Optimized Performance: Use CROSS APPLY to compute once, reuse
-- Benefits:
--   - SUM(TotalDue) is calculated only once per row and stored in a reusable alias (TotalSpent).
--   - SQL Server can optimize this as a join-like operation, resulting in fewer reads and CPU cycles.
--   - Improves query plan efficiency, lowers memory grants, and enables better parallelism.
--   - Cleaner and more maintainable — easy to add more computed fields later.
SELECT 
    cstmr.CustomerID,
    cstmr.AccountNumber,
    calc_spend.TotalSpent

FROM Sales.Customer AS cstmr

CROSS APPLY (
              SELECT SUM(sl_ord_hdr.TotalDue) AS TotalSpent
              FROM   Sales.SalesOrderHeader AS sl_ord_hdr
              WHERE  sl_ord_hdr.CustomerID = cstmr.CustomerID ) AS calc_spend
			  
ORDER BY calc_spend.TotalSpent DESC;
