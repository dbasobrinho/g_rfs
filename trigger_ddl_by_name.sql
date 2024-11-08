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
FROM   dba_triggers
WHERE  owner        = UPPER('&owner')
AND    trigger_name like UPPER('&trigger_name_or_per');

SET PAGESIZE 14 
SET LINESIZE 100 
SET FEEDBACK ON 
SET VERIFY ON
