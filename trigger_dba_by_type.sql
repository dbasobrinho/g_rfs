SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
  
COLUMN owner         FORMAT a20        
COLUMN trigger_name  FORMAT a30        
COLUMN trigger_type  FORMAT a14                    
COLUMN table_owner   FORMAT a20        
COLUMN table_name    FORMAT a30                                     
COLUMN status        FORMAT a10         


select t.owner, t.trigger_type,  t.status, count(*)
  from dba_triggers t
 group by  t.owner, t.trigger_type,  t.status
 order by t.trigger_type
/ 

select t.owner, t.trigger_name, t.trigger_type, t.table_owner, t.table_name, t.status
  from dba_triggers t
 where t.trigger_type      = UPPER('&trigger_type')
 order by t.status
/


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
