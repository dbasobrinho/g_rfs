-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg_status_send.sql                                                   |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DG Status Send Archive                                      |
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

COLUMN dest_id        FORMAT 999  HEAD 'Dest|Id'         
COLUMN db_status      FORMAT a10  HEAD 'Db|Status'  
COLUMN schedule       FORMAT a10  HEAD 'Schedule'    
COLUMN archive_dest   FORMAT a35  HEAD 'Arch|Dest' 
COLUMN target         FORMAT a10  HEAD 'Target'
COLUMN error          FORMAT a40  HEAD 'Error'   
COLUMN valid_now      FORMAT a20  HEAD 'Valid|Now'  
COLUMN log_sequence   FORMAT 9999999  HEAD 'Log|Sequence'  

select dest_id      dest_id
      ,status       db_status
      ,schedule     schedule
      ,target       target
      ,destination  archive_dest
      ,error        error
      ,valid_now    valid_now
      ,log_sequence log_sequence
  from v$archive_dest 
 where schedule <> 'INACTIVE'
/
