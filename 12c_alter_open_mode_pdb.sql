-- |----------------------------------------------------------------------------|
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
COLUMN current_instance_nt NEW_VALUE current_instance_nt NOPRINT;
SELECT rpad(instance_name, 17) current_instance, instance_name current_instance_nt FROM v$instance;
SET TERMOUT ON;
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : alter session set container                                 |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET PAGESIZE    1000
SET LINESIZE    500
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR           COLUMNS
CLEAR           BREAKS
CLEAR           COMPUTES
COLUMN con_id    FORMAT  99999999 
COLUMN name      FORMAT  A20     
COLUMN status    FORMAT  A10    
COLUMN open_mode FORMAT  A10  
select con_id,name,(select status from dba_pdbs x where  y.con_id = x.pdb_id) status, open_mode , dbid
from   v$pdbs y
order by name;
PROMPT | alter session set container = "container_name";     
PROMPT +------------------------------------------------------------------------+
PROMPT | alter pluggable database "pdb_name" open "read write";    




