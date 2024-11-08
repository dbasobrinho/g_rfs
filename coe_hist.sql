alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | Historico de planos de execucao de um SQL_ID [DBA_HIST_ACTIVE_SESS_HISTORY] |
PROMPT +-----------------------------------------------------------------------------+
PROMPT
ACCEPT sql_id2 char   PROMPT 'SQL ID                  = '
ACCEPT days    number PROMPT 'Dias Atras (SYSDATE - ) = '
PROMPT
COL sql_id               FOR A16;
COL SQL_PLAN_HASH_VALUE  FOR 999999999999999;
COL starting_time        FOR A21;
COL sess_ora             FOR A13;
COL end_time             FOR A21;
COL run_time_sec         FOR 999999999999999;
COL READ_IO_BYTES        FOR 999999999999999;
COL PGA_ALLOCATED_BYTES  FOR 999999999999999;
COL TEMP_ALLOCATED_BYTES FOR 999999999999999;

select sess_ora, sql_id, SQL_PLAN_HASH_VALUE,
      starting_time,
      end_time,
 (EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)) run_time_sec,
      READ_IO_BYTES,
      PGA_ALLOCATED PGA_ALLOCATED_BYTES,
      TEMP_ALLOCATED TEMP_ALLOCATED_BYTES
from  (
select
       sess_ora, sql_id,SQL_PLAN_HASH_VALUE,
       max(sample_time - sql_exec_start) run_time,
       max(sample_time) end_time,
       sql_exec_start starting_time,
       sum(DELTA_READ_IO_BYTES) READ_IO_BYTES,
       sum(DELTA_PGA) PGA_ALLOCATED,
       sum(DELTA_TEMP) TEMP_ALLOCATED
       from
       (
       select sql_id,SQL_PLAN_HASH_VALUE,
       sample_time,
       sql_exec_start,
       DELTA_READ_IO_BYTES,
       sql_exec_id,
	   SESSION_ID|| ',' ||SESSION_SERIAL# sess_ora,
       greatest(PGA_ALLOCATED - first_value(PGA_ALLOCATED) over (partition by sql_id,sql_exec_id order by sample_time rows 1 preceding),0) DELTA_PGA,
       greatest(TEMP_SPACE_ALLOCATED - first_value(TEMP_SPACE_ALLOCATED) over (partition by sql_id,sql_exec_id order by sample_time rows 1 preceding),0) DELTA_TEMP
       from
       dba_hist_active_sess_history
       where --sample_time >= to_date ('2016/05/08 00:00:00','YYYY/MM/DD HH24:MI:SS')
     --sample_time < to_date ('2016/05/09 03:10:00','YYYY/MM/DD HH24:MI:SS') and
       sample_time >= sysdate - &days
       and sample_time < sysdate
       and sql_exec_start is not null
       and IS_SQLID_CURRENT='Y'
       )
group by sess_ora, sql_id,SQL_EXEC_ID,sql_exec_start,SQL_PLAN_HASH_VALUE
order by sql_id
)
where sql_id = '&sql_id2'
order by STARTING_TIME, SQL_PLAN_HASH_VALUE, sql_id desc
/
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF days
UNDEF sql_id2
