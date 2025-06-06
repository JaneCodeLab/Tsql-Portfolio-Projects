/*
  Purpose     : Compare the filtering performance of IN vs EXISTS on a realistic condition.
  Scenario    : Return customers who have used a specific ShipMethodID (e.g., 'Express Shipping' = 5).
*/

-- Poor Performance: IN with subquery
-- Problem:
--   - The subquery returns a potentially large set of CustomerIDs.
--   - SQL Server must materialize the full list and scan it for each row in the outer query.
--   - Duplicate elimination may occur depending on the execution plan.
SELECT 
       cstmr.CustomerID,
       cstmr.AccountNumber

FROM   Sales.Customer AS cstmr
WHERE  cstmr.CustomerID IN (
                            SELECT sl_ord_hdr.CustomerID
                            FROM Sales.SalesOrderHeader AS sl_ord_hdr
                            WHERE sl_ord_hdr.ShipMethodID = 5);  -- BAD: subquery must be fully evaluated, no short-circuiting




-- Optimized Performance: EXISTS with correlation
-- Benefits:
--   - SQL Server stops evaluating as soon as it finds the first qualifying match per customer.
--   - Works better with appropriate indexes (e.g., on CustomerID, ShipMethodID).
--   - Scales better when the number of matching rows is small relative to the outer query.
SELECT 
       cstmr.CustomerID,
       cstmr.AccountNumber
  
FROM   Sales.Customer AS cstmr
WHERE EXISTS (
              SELECT 1
              FROM   Sales.SalesOrderHeader AS soh
              WHERE  soh.CustomerID = cstmr.CustomerID
                AND  soh.ShipMethodID = 5);  -- GOOD: short-circuit behavior, index-aware filtering
