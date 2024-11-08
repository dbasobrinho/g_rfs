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


select t.owner, t.trigger_name, t.trigger_type, t.table_owner, t.table_name, t.status
  from dba_triggers t
 where t.owner        = UPPER('&owner')
   and t.trigger_name like UPPER('&trigger_name_or_per');

