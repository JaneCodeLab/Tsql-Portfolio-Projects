/*
  Purpose  : Assigning a rank to active employees within each department based on most recent salary.
*/


SELECT
    dep.Name                                        AS DepartmentName,
    emp.BusinessEntityID                            AS EmployeeID,
    CONCAT(prsn.FirstName, ' ', prsn.LastName)      AS FullName,
    emp_pay.Rate * 2080                             AS AnnualSalary,         -- Assuming 40 hrs/week × 52 weeks
    ROW_NUMBER() OVER (
        PARTITION BY dep.DepartmentID
        ORDER BY emp_pay.Rate DESC
    )                                              AS SalaryRank            -- Rank within department by salary descending

FROM HumanResources.Employee AS emp
    INNER JOIN HumanResources.EmployeeDepartmentHistory AS emp_dep_hist
        ON emp.BusinessEntityID = emp_dep_hist.BusinessEntityID

    INNER JOIN HumanResources.Department AS dep
        ON emp_dep_hist.DepartmentID = dep.DepartmentID

    INNER JOIN Person.Person AS prsn
        ON emp.BusinessEntityID = prsn.BusinessEntityID

    -- Get latest pay rate per employee
    INNER JOIN (
                 SELECT emp_pay_hst.BusinessEntityID,
                        emp_pay_hst.Rate
                 FROM   HumanResources.EmployeePayHistory AS emp_pay_hst
                 WHERE  emp_pay_hst.RateChangeDate = (
                                                   SELECT MAX(emp_mx_pay_hst.RateChangeDate)
                                                   FROM   HumanResources.EmployeePayHistory AS emp_mx_pay_hst
                                                   WHERE  emp_mx_pay_hst.BusinessEntityID = emp_pay_hst.BusinessEntityID)
				) AS emp_pay
        ON emp.BusinessEntityID = emp_pay.BusinessEntityID

WHERE emp_dep_hist.EndDate IS NULL   -- Only currently assigned employees
ORDER BY DepartmentName, SalaryRank;
