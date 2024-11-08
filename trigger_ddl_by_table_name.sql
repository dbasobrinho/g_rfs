SET LONG 20000 
SET LONGCHUNKSIZE 20000 
SET PAGESIZE 0 
SET LINESIZE 1000 
SET FEEDBACK OFF 
SET VERIFY OFF 
SET TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner)
FROM   all_triggers
WHERE  table_owner        = UPPER('&table_owner')
AND    table_name like UPPER('&table_name_or_per');

SET PAGESIZE 14 
SET LINESIZE 100 
SET FEEDBACK ON 
SET VERIFY ON
