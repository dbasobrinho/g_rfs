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

COLUMN instance_name      FORMAT a5       HEADING 'INST'
COLUMN sid                FORMAT 9999     HEADING 'SID'
COLUMN serial_num         FORMAT 9999     HEADING 'SERIAL#'
COLUMN opname             FORMAT a45      HEADING 'RMAN OPERATION'
COLUMN start_time         FORMAT a20      HEADING 'START TIME'
COLUMN totalwork                          HEADING 'TOTAL WORK'
COLUMN sofar                              HEADING 'SOFAR'
COLUMN pct_done                           HEADING '% DONE'
COLUMN elapsed_seconds                    HEADING 'ELAPSED|SECONDS'
COLUMN time_remaining                     HEADING 'SECONDS|REMAINING'
COLUMN done_at            FORMAT a20      HEADING 'DONE AT'

SELECT
    substr(i.instance_name,1,5)                     instance_name
  , sid                                             sid
  , serial#                                         serial_num
  , b.opname                                        opname
  , TO_CHAR(b.start_time, 'dd/mm/yyyy HH24:MI:SS')  start_time
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
            , TO_CHAR((b.start_time + b.elapsed_seconds/3600/24), 'dd/mm/yyyy HH24:MI:SS')
            , TO_CHAR((SYSDATE + b.time_remaining/3600/24), 'dd/mm/yyyy HH24:MI:SS')
    ) done_at
FROM
       gv$session         a
  JOIN gv$session_longops b USING (sid,serial#)
  JOIN gv$instance        i ON (      i.inst_id = a.inst_id
                                  AND i.inst_id = b.inst_id)
WHERE
      a.program LIKE 'rman%'
  AND b.opname LIKE 'RMAN%'
  AND b.opname NOT LIKE '%aggregate%'
  AND b.totalwork > 0
ORDER BY
    i.instance_name
  , b.start_time
/
