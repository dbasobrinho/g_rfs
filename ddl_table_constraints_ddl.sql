SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('CONSTRAINT', constraint_name, owner)
FROM   DBA_constraints
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'))
/
--AND    constraint_type IN ('U', 'P')
SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON