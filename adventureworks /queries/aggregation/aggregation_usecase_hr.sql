/*
  Purpose     : Calculating aggregated salary statistics by department for active employees.
  Scenario    : Analyze departmental compensation using COUNT, AVG, and SUM.
*/



SELECT 
    dep.Name                               AS DepartmentName,
    COUNT(emp_pay.BusinessEntityID)        AS NumberOfEmployees,     -- Count the number of active employees in each department
    SUM(emp_pay.Rate * 2080)               AS TotalAnnualSalary,     -- Based on full-time hours/year
    AVG(emp_pay.Rate * 2080)               AS AvgAnnualSalary        -- Average estimated annual salary

FROM HumanResources.Employee                            AS emp
    INNER JOIN HumanResources.EmployeeDepartmentHistory AS emp_dep_hist 
        ON emp.BusinessEntityID = emp_dep_hist.BusinessEntityID
    INNER JOIN HumanResources.Department                AS dep 
        ON emp_dep_hist.DepartmentID = dep.DepartmentID
    INNER JOIN HumanResources.EmployeePayHistory        AS emp_pay 
        ON emp.BusinessEntityID = emp_pay.BusinessEntityID

WHERE   
  -- Only include currently assigned employees
  emp_dep_hist.EndDate IS NULL
    
  -- Use the most recent salary rate for each employee
  AND emp_pay.RateChangeDate = (
                                    SELECT  MAX(emp_pay_hst.RateChangeDate)
                                    FROM    HumanResources.EmployeePayHistory AS emp_pay_hst
                                    WHERE   emp_pay_hst.BusinessEntityID = emp_pay.BusinessEntityID
                                    )

GROUP BY dep.Name

-- Only show departments with 5 or more employees
HAVING COUNT(emp_pay.BusinessEntityID) >= 5

ORDER BY TotalAnnualSalary DESC;
