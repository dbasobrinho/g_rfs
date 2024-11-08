-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg_gap_e_prim.sql                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DG Identifica papel                                         |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFFwdw

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN thread#                               
COLUMN dest_id                          
COLUMN sequence#                               
COLUMN first_time  FORMAT a22  HEAD 'first_time'                            
COLUMN next_time   FORMAT a22  HEAD 'next_time' 
COLUMN dest_id                                                          

select 	name, db_unique_name, database_role, switchover_status, dataguard_broker, flashback_on 
from 	v$database
/
