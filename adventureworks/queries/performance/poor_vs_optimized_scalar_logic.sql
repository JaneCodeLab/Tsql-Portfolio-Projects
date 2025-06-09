/*
  Purpose     : Showing performance impact of scalar functions vs. set-based alternatives.
  Scenario    : Add computed tax amount to each sales order.
*/

-- Poor Performance: Scalar logic embedded in SELECT
-- This approach is evaluated row-by-row, and can be expensive in large result sets
-- This style is harder to maintain and clutters the SELECT block.
-- In more complex calculations, it becomes difficult to read or reuse.
SELECT 
       sl_ord_hdr.SalesOrderID,
       sl_ord_hdr.TotalDue,
       sl_ord_hdr.TaxAmt,
       CASE 
           WHEN sl_ord_hdr.TotalDue > 0 THEN sl_ord_hdr.TaxAmt / sl_ord_hdr.TotalDue
           ELSE 0
       END                    AS EstimatedTaxRate  -- BAD: logic inside SELECT per row
  
FROM   Sales.SalesOrderHeader AS sl_ord_hdr;



-- Optimized Performance: Set-based alternative using CROSS APPLY
-- Separates logic and allows more readable and potentially reusable computation
-- Keeps the SELECT block clean and focused
-- Improves readability and maintainability
-- Makes it easier to extend logic later (e.g., with multiple computed values)
-- Encourages a set-based mindset, which scales better in complex scenarios
SELECT 
       sl_ord_hdr.SalesOrderID,
       sl_ord_hdr.TotalDue,
       sl_ord_hdr.TaxAmt,
       calculated_tax.EstimatedTaxRate
  
FROM   Sales.SalesOrderHeader AS sl_ord_hdr
  
CROSS APPLY (
              SELECT 
                CASE 
                    WHEN sl_ord_hdr.TotalDue > 0 THEN sl_ord_hdr.TaxAmt / sl_ord_hdr.TotalDue
                    ELSE 0
                END                   AS EstimatedTaxRate
              )                       AS calculated_tax;
