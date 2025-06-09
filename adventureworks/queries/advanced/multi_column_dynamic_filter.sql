/*
  Purpose     : Dynamically filter any table by multiple columns using safe, parameterized dynamic SQL.
  Scenario    : Filter Person.Person based on a flexible list of columns/values provided at runtime.
*/

DECLARE    @TableName       NVARCHAR(128) = 'Person.Person';

-- Simulated dynamic filters (normally this could come from a UI or JSON input)
DECLARE    @FilterColumns   
TABLE 
(  ColumnName NVARCHAR(128), 
   FilterValue NVARCHAR(100)  
);


INSERT INTO @FilterColumns 
       (  ColumnName,   FilterValue)
VALUES (  'FirstName',  'John'), 
       (  'LastName',   'Smith');

-- Step 1: Validate all column names exist in the target table
IF EXISTS (
            SELECT 1
            FROM @FilterColumns fc
            WHERE NOT EXISTS (
                                SELECT 1
                                FROM   INFORMATION_SCHEMA.COLUMNS
                                WHERE  TABLE_NAME = PARSENAME(@TableName, 1)
                                  AND  COLUMN_NAME = fc.ColumnName
                             )
           )
BEGIN
    PRINT 'Error: One or more columns do not exist in the specified table.';
    RETURN;
END



-- Step 2: Build dynamic WHERE clause and parameter definitions
DECLARE @Index      INT = 1;
DECLARE @ParamDef   NVARCHAR(MAX) = N'';
DECLARE @ParamList  NVARCHAR(MAX) = N'';
DECLARE @Sql        NVARCHAR(MAX) = N' SELECT   BusinessEntityID, 
                                                FirstName, 
                                                LastName 
                                       FROM ' + QUOTENAME(@TableName) + 
                                    N' WHERE 1=1';



DECLARE    @ColumnName    NVARCHAR(128);
DECLARE    @FilterValue   NVARCHAR(100);

DECLARE    FilterCursor   
CURSOR FOR 
           SELECT ColumnName, FilterValue 
           FROM @FilterColumns;

OPEN       FilterCursor;
FETCH NEXT 
FROM       FilterCursor 
INTO       @ColumnName, @FilterValue;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @ParamName NVARCHAR(50) = N'@p' + CAST(@Index AS NVARCHAR);
    SET   @Sql       += N' AND '   + QUOTENAME(@ColumnName) + ' = ' + @ParamName + ' ';
    SET   @ParamDef  += @ParamName + ' NVARCHAR(100), ';
    SET   @ParamList += IIF(@Index > 1, N', ', N'') + @ParamName + ' = ''' + REPLACE(@FilterValue, '''', '''''') + '''';
    SET   @Index     += 1;

    FETCH NEXT 
    FROM       FilterCursor 
    INTO       @ColumnName, @FilterValue;
    END

CLOSE      FilterCursor;
DEALLOCATE FilterCursor;

-- Trim trailing comma from @ParamDef
IF LEN(@ParamDef) > 0
    SET @ParamDef = LEFT(@ParamDef, LEN(@ParamDef) - 1);

-- Step 3: Execute dynamic SQL with parameters
EXEC sp_executesql @Sql, @ParamDef, @ParamList;