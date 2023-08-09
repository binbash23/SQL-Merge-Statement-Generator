
/*
20230809 jens heine, nils loewemann, yetis batmaz
*/

/* MAN MUSS NUR DIESE BEIDEN VARIABLEN SETZEN (und "result to text" im ssms anklicken)!!! */
declare @target_table_schema as varchar(255) = 'database_schema_name'
declare @target_table_name   as varchar(255) = 'table_name'
/* MAN MUSS NUR DIESE BEIDEN VARIABLEN SETZEN!!! */



select
c as 'Merge Statement'
from

(

select 'Diese Punkte bitte manuell korrigieren (1) bis (4)' as c, 1 as nr
union
select ' ' as c, 2 as nr
union

select CONCAT('MERGE ', @target_table_schema, '.', @target_table_name,' as TARGET ', 
CHAR(13), 'USING ', 
CHAR(13), '(', 
CHAR(13), '/* (1) Hier muss das select stmt hin */', 
CHAR(13), ')', CHAR(13), 'AS SOURCE ON ', 
CHAR(13), '( ', 
CHAR(13), '/* (2) Spalten einsetzen: TARGET.<PK_SPALTE> = SOURCE.<PK_SPALTE> */', 
CHAR(13), ') ', 
CHAR(13), 'WHEN MATCHED AND ', 
CHAR(13), '(', 
CHAR(13), '/* (3) Das erste "OR" muss weg */'
) as c, 10 as nr

union

/* 1. iteration (vergleichen) */

select
CONCAT(
 ' OR TARGET.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' <> SOURCE.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' 
,CHAR(13), '    OR (TARGET.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' IS NULL AND SOURCE.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' 
,' IS NOT NULL)', 
CHAR(13), '    OR (TARGET.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' IS NOT NULL AND SOURCE.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' IS NULL)'
) as c,
20 as nr
from
(
SELECT 
C.COLUMN_NAME,
C.DATA_TYPE
FROM 
INFORMATION_SCHEMA.TABLES as T 
inner join INFORMATION_SCHEMA.COLUMNS as C
on T.TABLE_SCHEMA = C.TABLE_SCHEMA and T.TABLE_NAME = C.TABLE_NAME
WHERE T.TABLE_TYPE = 'BASE TABLE' 
and
T.TABLE_NAME = @target_table_name
and
T.TABLE_SCHEMA = @target_table_schema
and
C.COLUMN_NAME not in ('Create_Date', 'Last_Update_Date')
) as TARGET_TABLE_COLUMNS


union

select CONCAT( ') ', 
CHAR(13), 'THEN UPDATE SET ', 
CHAR(13), '/* (4) ACHTUNG hier muss die PK_SPALTE noch entfernt werden */', 
CHAR(13), '  Last_Update_Date = getdate() ') as c, 30 as nr

union


/* 2. iterationssache (update-block) */


select
CONCAT(
 ' ,TARGET.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' = SOURCE.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' 
) as c,
40 as nr
from
(
SELECT 
C.COLUMN_NAME,
C.DATA_TYPE
FROM 
INFORMATION_SCHEMA.TABLES as T 
inner join INFORMATION_SCHEMA.COLUMNS as C
on T.TABLE_SCHEMA = C.TABLE_SCHEMA and T.TABLE_NAME = C.TABLE_NAME
WHERE T.TABLE_TYPE = 'BASE TABLE' 
and
T.TABLE_NAME = @target_table_name
and
T.TABLE_SCHEMA = @target_table_schema
and
C.COLUMN_NAME not in ('Create_Date', 'Last_Update_Date')
) as TARGET_TABLE_COLUMNS


union

select
CONCAT(
'WHEN NOT MATCHED THEN INSERT ', 
CHAR(13), '(', 
CHAR(13), '  Create_Date ', 
CHAR(13), ' ,Last_Update_Date ') as c,
50 as nr


union


/* insert block */
select
CONCAT(
 ' ,', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']'  
) as c,
60 as nr
from
(
SELECT 
C.COLUMN_NAME,
C.DATA_TYPE
FROM 
INFORMATION_SCHEMA.TABLES as T 
inner join INFORMATION_SCHEMA.COLUMNS as C
on T.TABLE_SCHEMA = C.TABLE_SCHEMA and T.TABLE_NAME = C.TABLE_NAME
WHERE T.TABLE_TYPE = 'BASE TABLE' 
and
T.TABLE_NAME = @target_table_name
and
T.TABLE_SCHEMA = @target_table_schema
and
C.COLUMN_NAME not in ('Create_Date', 'Last_Update_Date')
) as TARGET_TABLE_COLUMNS


union

select concat(') ', 
CHAR(13), 'VALUES ', 
CHAR(13), '(', 
CHAR(13), '  getdate() ', 
CHAR(13), ' ,getdate() ') as c, 70 as nr



/* values block */


union
select
CONCAT(
 ' ,SOURCE.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' 
) as c,
80 as nr
from
(
SELECT 
C.COLUMN_NAME,
C.DATA_TYPE
FROM 
INFORMATION_SCHEMA.TABLES as T 
inner join INFORMATION_SCHEMA.COLUMNS as C
on T.TABLE_SCHEMA = C.TABLE_SCHEMA and T.TABLE_NAME = C.TABLE_NAME
WHERE T.TABLE_TYPE = 'BASE TABLE' 
and
T.TABLE_NAME = @target_table_name
and
T.TABLE_SCHEMA = @target_table_schema
and
C.COLUMN_NAME not in ('Create_Date', 'Last_Update_Date')
) as TARGET_TABLE_COLUMNS


union


select  '); ' as c, 90 as nr

) x
order by nr