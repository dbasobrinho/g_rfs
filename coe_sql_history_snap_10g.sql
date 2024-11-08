alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Historico de planos de execucao de um SQL_ID                           |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT sql_idx char   PROMPT 'SQL ID = '
set pages 999 lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
--break on plan_hash_value on startup_time skip 1
select ss.snap_id,
       ss.instance_number node,
       to_char(begin_interval_time, 'dd/mm/yyyy hh24:mi:ss') begin_interval_time,
       sql_id,
       plan_hash_value,
       nvl(executions_delta, 0) execs,
       (elapsed_time_delta /
       decode(nvl(executions_delta, 0), 0, 1, executions_delta)) / 1000000 avg_etime,
       (buffer_gets_delta /
       decode(nvl(buffer_gets_delta, 0), 0, 1, executions_delta)) avg_lio
  from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
 where sql_id = trim('&sql_idx')
   and ss.snap_id = S.snap_id
   and ss.instance_number = S.instance_number
   and executions_delta > 0
 order by 1, 2, 3
/
