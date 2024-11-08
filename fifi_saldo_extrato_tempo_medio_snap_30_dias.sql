PROMPT ..
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       10000
SET PAGES       10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col inst_id      format 99
col snap_id      format 99999999
col sql_id       format a13
col hash_value   format 9999999999
col SQL_PROFILE  format a30
col LOADS_DELTA  format 99999       HEADING 'LOADS|TOTAL(DT)'
col CPU_TIME     format 99999       HEADING 'CPU|TIME(MIN)'
col ELAPSED_TIME format 9999999999  HEADING 'ELAPSED TIME|TOTAL(MIN)'
col btime        format a14         HEADING 'TIME|SNAP'
col minutes      format 9999999
col executions   format 9999999
col AGV_DURATION format a19         HEADING 'AVG|DURATION (SEC)'


select a.instance_number inst_id,
       a.snap_id,
       a.sql_id,
       a.plan_hash_value as hash_value,
       a.SQL_PROFILE,
       a.LOADS_DELTA,
       a.CPU_TIME_DELTA / 60000 as CPU_TIME,
       a.ELAPSED_TIME_DELTA / 60000 as ELAPSED_TIME,
       to_char(begin_interval_time, 'dd/MM/YY hh24:mi') btime,
       abs(extract(minute from(end_interval_time - begin_interval_time)) +
           extract(hour from(end_interval_time - begin_interval_time)) * 60 +
           extract(day from(end_interval_time - begin_interval_time)) * 24 * 60) minutes,
       executions_delta executions,
       '   '||TO_CHAR(round(ELAPSED_TIME_delta / 1000000 / greatest(executions_delta, 1), 4),'FM9990.000') AGV_DURATION
  from dba_hist_SQLSTAT a, dba_hist_snapshot b
 where sql_id = 'cpy2pc0vfqp6q'
   and a.snap_id = b.snap_id
   and a.instance_number = b.instance_number
   and begin_interval_time > trunc(sysdate - 30)
 order by snap_id desc, begin_interval_time desc, a.instance_number
/
