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

COLUMN instance_name      FORMAT a10      HEADING 'Instance'
COLUMN sid                                HEADING 'Oracle|SID'
COLUMN serial_num                         HEADING 'Serial|#'
COLUMN opname             FORMAT a30      HEADING 'Operation'
COLUMN start_time         FORMAT a18      HEADING 'Start|Time'
COLUMN totalwork                          HEADING 'Total|Work'
COLUMN sofar                              HEADING 'So|Far'
COLUMN pct_done                           HEADING 'Percent|Done'
COLUMN elapsed_seconds                    HEADING 'Elapsed|Seconds'
COLUMN time_remaining                     HEADING 'Seconds|Remaining'
COLUMN done_at            FORMAT a18      HEADING 'Done|At'

SELECT
    i.instance_name                                 instance_name
  , sid                                             sid
  , serial#                                         serial_num
  , b.opname                                        opname
  , TO_CHAR(b.start_time, 'mm/dd/yy HH24:MI:SS')    start_time
  , b.totalwork                                     totalwork
  , b.sofar                                         sofar
  , ROUND( (b.sofar/DECODE(   b.totalwork
                            , 0
                            , 0.001
                            , b.totalwork)*100),2)  pct_done
  , b.elapsed_seconds                               elapsed_seconds
  , b.time_remaining                                time_remaining
  , DECODE(   b.time_remaining
            , 0
            , TO_CHAR((b.start_time + b.elapsed_seconds/3600/24), 'mm/dd/yy HH24:MI:SS')
            , TO_CHAR((SYSDATE + b.time_remaining/3600/24), 'mm/dd/yy HH24:MI:SS')
    ) done_at
FROM
       gv$session         a
  JOIN gv$session_longops b USING (sid,serial#)
  JOIN gv$instance        i ON (      i.inst_id = a.inst_id
                                  AND i.inst_id = b.inst_id)
WHERE b.totalwork > 0
ORDER BY b.time_remaining , pct_done 
   ,i.instance_name
  , b.start_time
/
