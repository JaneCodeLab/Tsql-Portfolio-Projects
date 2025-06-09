/*
  Purpose     : Use a recursive CTE to return the full management chain for a specific employee.
  Scenario    : Starting from a given employee, recursively trace their managers up to the top of the organization.
  Features    : Uses the hierarchyid column (OrganizationNode) and the GetAncestor() method.
*/

DECLARE @EmployeeID INT = 200;


WITH EmployeeHierarchy AS (
    -- Anchor: Start with the specified employee
    SELECT 
			emp.BusinessEntityID  AS EmployeeID,
			emp.OrganizationNode  AS OrganizationNode,
			emp.OrganizationLevel AS Org_Level,
			emp.JobTitle          AS Job,
			0                     AS HierarchyLevel
    FROM HumanResources.Employee  AS emp
    WHERE emp.BusinessEntityID = @EmployeeID

    UNION ALL

    -- Recursive: Find the immediate manager using hierarchyid.GetAncestor(1)
    SELECT 
        mgr.BusinessEntityID          AS EmployeeID,
        mgr.OrganizationNode          AS OrganizationNode,
        mgr.OrganizationLevel         AS Org_Level,
        mgr.JobTitle                  AS Job,
        emp_hrchy.HierarchyLevel + 1  AS HierarchyLevel
    FROM HumanResources.Employee AS mgr
    INNER JOIN EmployeeHierarchy AS emp_hrchy
        ON mgr.OrganizationNode = emp_hrchy.OrganizationNode.GetAncestor(1)
)




-- Final result: Join with Person.Person to include full name
SELECT 
    emp_hrchy.HierarchyLevel                    AS LevelFromEmployee,
    emp_hrchy.EmployeeID                        AS EmployeeID,
    CONCAT(prsn.FirstName, ' ', prsn.LastName)  AS FullName,
    emp_hrchy.Job                               AS Job,
    emp_hrchy.Org_Level                         AS EmployeeID
FROM EmployeeHierarchy AS emp_hrchy
	JOIN Person.Person AS prsn
		ON emp_hrchy.EmployeeID = prsn.BusinessEntityID
ORDER BY emp_hrchy.HierarchyLevel;