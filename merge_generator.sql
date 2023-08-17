
/*
20230809 jens heine, nils loewemann, yetis batmaz
*/

/* 
Man muss nur 2 Variablen setzen (und "result to text" im ssms anklicken)!!! 
Dann das Ergebniss dieses ganzen SQL Statements noch ein wenig anpassen (sieht Punkt (1)
im Output des SQL's.
*/


/* MAN MUSS NUR DIESE BEIDEN VARIABLEN SETZEN!!! */
declare @target_table_schema as varchar(255) = 'schema_name'
declare @target_table_name   as varchar(255) = 'table_name'




select
c as 'Merge Statement'
from

(

select 'Bitte manuell das SQL für die Quelltabelle hier einfügen unter (1)' as c, 1 as nr
union
select ' ' as c, 2 as nr

union

select CONCAT('MERGE ', @target_table_schema, '.', @target_table_name,' as TARGET ', 
CHAR(13), 'USING ', 
CHAR(13), '(', 
CHAR(13), ' <(1) Hier das SQL für die Quelle der Daten angeben>',
CHAR(13), 'select') as c,
5 as nr

union

select
CONCAT(
 ' S.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' as ', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' 
) as c,
8 as nr
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

select CONCAT('from', 
CHAR(13), ' <BASETABLE(s)_NAME or JOINS> as S', 
CHAR(13), ')', 
CHAR(13), 'AS SOURCE ON ', 
CHAR(13), '( ') as c,
10 as nr

union

select
CONCAT('TARGET.', CU.COLUMN_NAME , ' = SOURCE.', CU.COLUMN_NAME) as c,
12 as nr
from
INFORMATION_SCHEMA.TABLE_CONSTRAINTS C
left join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CU
on C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
where
C.TABLE_SCHEMA = @target_table_schema
and
C.TABLE_NAME = @target_table_name

union

select
CONCAT(
') ', 
CHAR(13), 'WHEN MATCHED AND ', 
CHAR(13), '('
) as c, 15 as nr

union

/* 1. iteration (vergleichen) */

select
case when rownum > 1 then CONCAT('OR ', c) else c end as c,
nr
from(
select
CONCAT(
 ' TARGET.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' <> SOURCE.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' 
,CHAR(13), '    OR (TARGET.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' IS NULL AND SOURCE.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' ,' IS NOT NULL)', 
CHAR(13), '    OR (TARGET.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' IS NOT NULL AND SOURCE.', '[', TARGET_TABLE_COLUMNS.COLUMN_NAME, ']' , ' IS NULL)'
) as c,
20 as nr,
TARGET_TABLE_COLUMNS.ORDINAL_POSITION,
ROW_NUMBER() over (order by TARGET_TABLE_COLUMNS.ORDINAL_POSITION ) as rownum
from
(
SELECT 
C.COLUMN_NAME,
C.DATA_TYPE,
C.ORDINAL_POSITION
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
) as X

union

select CONCAT( ') ', 
CHAR(13), 'THEN UPDATE SET ', 
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
and
C.COLUMN_NAME not in 
(
select
CU.COLUMN_NAME
from
INFORMATION_SCHEMA.TABLE_CONSTRAINTS C
left join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CU
on C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
where
C.TABLE_SCHEMA = @target_table_schema
and
C.TABLE_NAME = @target_table_name
)
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
