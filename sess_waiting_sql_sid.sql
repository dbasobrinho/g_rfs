-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE :                                                                 |
-- | FILE     :                                                                 |
-- | CLASS    :                                                                 |
-- | PURPOSE  :                                                                 |
-- |                                                                            |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Session Waits SIDs                                          |
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

COLUMN instance_name     FORMAT a9            HEADING 'Instance'
COLUMN sid               FORMAT 999999        HEADING 'SID'
COLUMN serial_id         FORMAT 99999999      HEADING 'Serial ID'
COLUMN session_status    FORMAT a9            HEADING 'Status'
COLUMN oracle_username   FORMAT a20           HEADING 'Oracle User'
COLUMN state             FORMAT a8            HEADING 'State'
COLUMN event             FORMAT a25           HEADING 'Event'
COLUMN wait_time_sec     FORMAT 999,999,999   HEADING 'Wait Time (sec)'
COLUMN last_sql          FORMAT a45           HEADING 'Last SQL'

select a.sid
      ,a.serial#
      ,a.status
      ,a.program
      ,b.event
      ,to_char(a.logon_time, 'dd-mon-yy hh24:mi') LOGON_TIME
      ,to_char(Sysdate, 'dd-mon-yy-hh24:mi') CURRENT_TIME
      ,(a.last_call_et / 3600) "Hrs connected"
  from v$session      a
      ,v$session_wait b
 where a.sid in (&SIDs)
   and a.sid = b.sid
 order by 8;
