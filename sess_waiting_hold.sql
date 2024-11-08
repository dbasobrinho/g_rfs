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
PROMPT | Report   : Session Waits Hold                                          |
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

SELECT  SUBSTR(TO_CHAR(w.session_id), 1, 5) WSID
       ,p1.spid                             WPID
       ,SUBSTR(s1.username, 1, 12)         "WAITING User"
       ,SUBSTR(s1.osuser, 1, 8)            "OS User"
       ,SUBSTR(s1.program, 1, 20)          "WAITING Program"
       ,s1.client_info                     "WAITING Client"
       ,SUBSTR(TO_CHAR(h.session_id), 1, 5) HSID
       ,p2.spid                             HPID
       ,SUBSTR(s2.username, 1, 12)         "HOLDING User"
       ,SUBSTR(s2.osuser, 1, 8)            "OS User"
       ,SUBSTR(s2.program, 1, 20)          "HOLDING Program"
       ,s2.client_info                     "HOLDING Client"
       ,o.object_name                      "HOLDING Object"
  FROM gv$process   p1
      ,gv$process   p2
      ,gv$session   s1
      ,gv$session   s2
      ,dba_locks    w
      ,dba_locks    h
      ,dba_objects  o
 WHERE w.last_convert       > 60
   AND h.mode_held         != 'None'
   AND h.mode_held         != 'Null'
   AND w.mode_requested    != 'None'
   AND s1.row_wait_obj#     = o.object_id
   AND w.lock_type(+)       = h.lock_type
   AND w.lock_id1(+)        = h.lock_id1
   AND w.lock_id2(+)        = h.lock_id2
   AND w.session_id         = s1.sid(+)
   AND h.session_id         = s2.sid(+)
   AND s1.paddr             = p1.addr(+)
   AND s2.paddr             = p2.addr(+)
 ORDER BY w.last_convert DESC;
