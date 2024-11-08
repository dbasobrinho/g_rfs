with malha as (
select sql_id, SQL_PLAN_HASH_VALUE,
(EXTRACT(HOUR FROM run_time) * 3600
+ EXTRACT(MINUTE FROM run_time) * 60
+ EXTRACT(SECOND FROM run_time)) run_time_sec, TOP_LEVEL_SQL_ID
from (
select
sql_id,SQL_PLAN_HASH_VALUE,
max(sample_time - sql_exec_start) run_time,
max(sample_time) end_time,
sql_exec_start starting_time, TOP_LEVEL_SQL_ID
from
(
select sql_id,SQL_PLAN_HASH_VALUE,
sample_time,
sql_exec_start,
sql_exec_id, TOP_LEVEL_SQL_ID
from
dba_hist_active_sess_history
where 1=1 and
-- sample_time between to_date('2020-04-17 00:00:00', 'yyyy-mm-dd hh24:mi:ss') and to_date('2020-04-18 23:00:00', 'yyyy-mm-dd hh24:mi:ss') and
sample_time >= sysdate - 7 and
sql_exec_start is not null and
IS_SQLID_CURRENT='Y'
--and MACHINE in ('BT31','BT32') )
and TOP_LEVEL_SQL_ID='7vf8hr9wgxx9j' )
group by sql_id,SQL_EXEC_ID,sql_exec_start,SQL_PLAN_HASH_VALUE, TOP_LEVEL_SQL_ID
)
order by run_time_sec)
select sql_id, SQL_PLAN_HASH_VALUE, sum(run_time_sec)/60 , count (*) from malha
group by sql_id, SQL_PLAN_HASH_VALUE order by 3;