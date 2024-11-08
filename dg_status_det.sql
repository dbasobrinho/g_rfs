-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg_status_det.sql                                               |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DG Status Replicacao Detalhado                              |
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
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN thread          FORMAT 99        HEAD 'Thread'    
COLUMN inst_id         FORMAT 99        HEAD 'Instance|Id'  
COLUMN dest_id         FORMAT 99        HEAD 'Instance|Dest Id'
COLUMN sequence        FORMAT 999999    HEAD 'Sequence|Arc'    
COLUMN next_time       FORMAT a19       HEAD 'Date' 
COLUMN applied         FORMAT a10       HEAD 'Applied'
COLUMN name            FORMAT a90       HEAD 'Name'
    
select thread# thread
      ,inst_id
      ,dest_id
      ,sequence# sequence
      ,to_char(next_time, 'dd/mm/yyyy hh24:mi:ss') as next_time
      ,applied
      ,name
  from gv$archived_log 
  where next_time > sysdate-&Menos_X_Minutos/24/60
 order by next_time, sequence# desc, dest_id
/

