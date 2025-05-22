select "SET @@session.innodb_strict_mode = 0;" as alter_statement;
UNION ALL;
select "SET sql_mode = '';" as alter_statement;
UNION ALL;

SELECT 
  CONCAT(
    'USE `', i.TABLE_SCHEMA, '`; ALTER TABLE `', i.TABLE_NAME, '` ROW_FORMAT=', ROW_FORMAT, ';'
  ) AS alter_statement
FROM 
  information_schema.TABLES i
WHERE 
  TABLE_SCHEMA NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')
  AND table_type = 'BASE TABLE'
  AND TABLE_SCHEMA NOT LIKE '%dev%'
AND TABLE_SCHEMA NOT LIKE '%tmp%'  
ORDER BY TABLE_SCHEMA