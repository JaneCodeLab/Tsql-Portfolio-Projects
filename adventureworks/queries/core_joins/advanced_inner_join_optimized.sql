/*
  Purpose   : Returns a list of currently assigned employees who have served in their 
              departments for over five years, including department and shift details.
*/

DECLARE @CutoffDate DATE = DATEADD(YEAR, -5, GETDATE());

SELECT 
    emp.BusinessEntityID                              AS EmployeeID,
    CONCAT(prsn.FirstName, ' ', prsn.LastName)        AS FullName,
    emp.JobTitle                                      AS Title,
    dep.Name                                          AS DepartmentName,
    shft.Name                                         AS ShiftName,
    emp_dep_hist.StartDate                            AS AssignedToDepartmentSince,
    DATEDIFF(YEAR, emp_dep_hist.StartDate, GETDATE()) AS YearsInDepartment

FROM HumanResources.Employee                              AS emp
    INNER JOIN HumanResources.EmployeeDepartmentHistory   AS emp_dep_hist 
        ON emp.BusinessEntityID = emp_dep_hist.BusinessEntityID

    INNER JOIN HumanResources.Department                  AS dep 
        ON emp_dep_hist.DepartmentID = dep.DepartmentID

    INNER JOIN HumanResources.Shift                       AS shft 
        ON emp_dep_hist.ShiftID = shft.ShiftID

    INNER JOIN Person.Person                              AS prsn 
        ON emp.BusinessEntityID = prsn.BusinessEntityID

WHERE   emp_dep_hist.EndDate IS NULL
    AND emp_dep_hist.StartDate <= @CutoffDate

ORDER BY DepartmentName, AssignedToDepartmentSince;
