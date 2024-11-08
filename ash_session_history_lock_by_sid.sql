alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
alter session set nls_timestamp_format='YYYY/MM/DD HH24:MI:SS';
set pages 1000 lines 1000;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Historico sqlid por sid                                                |
PROMPT +------------------------------------------------------------------------+
PROMPT
PROMPT
set pages 1000 lines 1000;
COL sql_id               FOR A16;
COL SQL_PLAN_HASH_VALUE  FOR 9999999999;
COL starting_time        FOR A21;
COL EVENT                FOR A21;
COL end_time             FOR A21;
COL run_time_sec         FOR 9999999999;
COL READ_IO_BYTES        FOR 9999999999;
COL PGA_ALLOCATED_BYTES  FOR 9999999999;
COL TEMP_ALLOCATED_BYTES FOR 9999999999;


select sql_id, SQL_PLAN_HASH_VALUE,
      starting_time,
      end_time,
                  event,
(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)) run_time_sec, SESSION_ID, TOP_LEVEL_SQL_ID,  BLOCKING_SESSION
from  (
select
       sql_id,SQL_PLAN_HASH_VALUE,
       max(sample_time - sql_exec_start) run_time,
       max(sample_time) end_time,
       sql_exec_start starting_time,
                   event, SESSION_ID, TOP_LEVEL_SQL_ID,  BLOCKING_SESSION
       from
       (
       select sql_id,SQL_PLAN_HASH_VALUE,
       sample_time,
       sql_exec_start,
       sql_exec_id,
                   event, SESSION_ID, TOP_LEVEL_SQL_ID,  BLOCKING_SESSION
       from
       dba_hist_active_sess_history
       where
       sample_time between to_date('2018-12-04 16:00:00', 'yyyy-mm-dd hh24:mi:ss') and to_date('2018-12-04 18:00:00', 'yyyy-mm-dd hh24:mi:ss')
       and sql_exec_start is not null
       and IS_SQLID_CURRENT='Y'
       )
group by sql_id,SQL_EXEC_ID,sql_exec_start,SQL_PLAN_HASH_VALUE,event, SESSION_ID, TOP_LEVEL_SQL_ID,  BLOCKING_SESSION
order by sql_id
)
where SESSION_ID='&sid'
order by STARTING_TIME, SQL_PLAN_HASH_VALUE, sql_id desc
/
