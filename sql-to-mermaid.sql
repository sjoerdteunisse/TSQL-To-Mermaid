-- Declare a table variable to store the intermediate results
DECLARE @Result TABLE (DiagramPart NVARCHAR(MAX));
 
-- Insert 'erDiagram' as the first part of the result
INSERT INTO @Result (DiagramPart)
VALUES ('erDiagram');
 
-- Insert table definitions
INSERT INTO @Result (DiagramPart)
SELECT
    't' + t.TABLE_NAME + ' {' + CHAR(13) + CHAR(10) + STRING_AGG('    ' + c.COLUMN_NAME + ' ' + c.DATA_TYPE, CHAR(13) + CHAR(10)) + CHAR(13) + CHAR(10) + '}'
FROM
    INFORMATION_SCHEMA.TABLES t
    JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME AND t.TABLE_SCHEMA = c.TABLE_SCHEMA
WHERE
    t.TABLE_TYPE = 'BASE TABLE'
GROUP BY
    t.TABLE_NAME;
 
-- Insert foreign key relationships
INSERT INTO @Result (DiagramPart)
SELECT
    fk.TABLE_NAME + ' }|..|| ' + pk.TABLE_NAME + ' : ' + fk.CONSTRAINT_NAME
FROM
    INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
    JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS fk ON rc.CONSTRAINT_NAME = fk.CONSTRAINT_NAME
    JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ON rc.UNIQUE_CONSTRAINT_NAME = pk.CONSTRAINT_NAME
WHERE
    fk.CONSTRAINT_TYPE = 'FOREIGN KEY';
 
-- Select all parts of the diagram
SELECT DiagramPart
FROM @Result;
