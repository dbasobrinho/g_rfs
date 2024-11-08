while true
do
clear
sqlplus -S "/ as sysdba" <<EOF
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
COLUMN opname             FORMAT a30      HEADING 'RMAN|Operation'
COLUMN start_time         FORMAT a18      HEADING 'Start|Time'
COLUMN totalwork                          HEADING 'Total|Work'
COLUMN sofar                              HEADING 'So|Far'
COLUMN pct_done                           HEADING 'Percent|Done'
COLUMN elapsed_seconds                    HEADING 'Elapsed|Seconds'
COLUMN time_remaining                     HEADING 'Seconds|Remaining'
COLUMN done_at            FORMAT a18      HEADING 'Done|At'
select * from vw_rest_rman;
EOF
sleep 10
done
