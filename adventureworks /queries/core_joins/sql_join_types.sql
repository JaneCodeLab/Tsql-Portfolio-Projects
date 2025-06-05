/*
  Purpose     : Showing how different SQL JOIN types affect query results when combining person records with email addresses.
  Scenario    : Joining Persons with their Email Addresses using INNER, LEFT, RIGHT, and FULL OUTER JOINs.
*/

-- INNER JOIN: Returns only people who have at least one email address (matched records in both tables)
SELECT 
    prsn.BusinessEntityID                        AS PersonID,
    CONCAT(prsn.FirstName, ' ', prsn.LastName)   AS FullName,
    email.EmailAddress                           AS Email
  
FROM Person.Person             AS prsn
INNER JOIN Person.EmailAddress AS email
    ON prsn.BusinessEntityID = email.BusinessEntityID
  
ORDER BY FullName;




-- LEFT JOIN: Returns all people, including those who do not have an email address (unmatched rows show NULL for Email)
SELECT DISTINCT
    prsn.BusinessEntityID                        AS PersonID,
    CONCAT(prsn.FirstName, ' ', prsn.LastName)   AS FullName,
    email.EmailAddress                           AS Email
  
FROM Person.Person            AS prsn
LEFT JOIN Person.EmailAddress AS email
    ON prsn.BusinessEntityID = email.BusinessEntityID
  
ORDER BY FullName;



-- RIGHT JOIN: Returns all email addresses, including those not linked to a person (unmatched rows show NULL for person info)
SELECT DISTINCT
    email.BusinessEntityID                       AS EmailEntityID,
    CONCAT(prsn.FirstName, ' ', prsn.LastName)   AS FullName,
    email.EmailAddress                           AS Email
  
FROM Person.Person             AS prsn
RIGHT JOIN Person.EmailAddress AS email
    ON prsn.BusinessEntityID = email.BusinessEntityID
  
ORDER BY FullName;




-- FULL OUTER JOIN: Returns all people and all email addresses; unmatched rows from either side will contain NULLs
SELECT DISTINCT
    prsn.BusinessEntityID                        AS PersonID,
    CONCAT(prsn.FirstName, ' ', prsn.LastName)   AS FullName,
    email.EmailAddress                           AS Email,
    email.BusinessEntityID                       AS EmailID
  
FROM Person.Person                  AS prsn
FULL OUTER JOIN Person.EmailAddress AS email
    ON prsn.BusinessEntityID = email.BusinessEntityID
  
ORDER BY FullName;
