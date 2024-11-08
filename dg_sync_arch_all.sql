-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg_sync_arch_all.sql                                            |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Oracle Data Guard Sync                                      |
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
COLUMN dest_id         FORMAT 99        HEAD 'Instance|Dest Id'                      
COLUMN sequence        FORMAT 999999    HEAD 'Sequence|Arc'                               
COLUMN first_time      FORMAT a22  HEAD 'first_time'                            
COLUMN next_time       FORMAT a22  HEAD 'next_time' 
           
                                
select thread#
      ,dest_id
      ,sequence#
      ,APPLIED
      ,to_char(first_time,'dd/mm/yyyy hh24:mi:ss') first_time
      ,to_char(next_time,'dd/mm/yyyy hh24:mi:ss') next_time
  from v$archived_log
 where resetlogs_change# = (select resetlogs_change# from v$database)
 order by first_time, thread#,sequence#,dest_id;
/

