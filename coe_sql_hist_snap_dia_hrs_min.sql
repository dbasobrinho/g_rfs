alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | SQL_ID MEDIA EXECUCAO POR DIA HORAS [DBA_HIST_SNAPSHOT]                     |
PROMPT +-----------------------------------------------------------------------------+
PROMPT
ACCEPT sql_id2 char   PROMPT 'SQL ID                  = '
ACCEPT days    number PROMPT 'Dias Atras (SYSDATE - ) = '
PROMPT
COL sql_id               FOR A16;
COL PLAN_HASH_VALUE      FOR 9999999999;
COL Day                  FOR A22;
COL Executions           FOR 9999999999;
COL Rows_                FOR 9999999999;
COL "DiskRead/Exec"      FOR 9999999999;
COL "BufferGets/Exec"    FOR 9999999999;
COL "Elapsed/Exec (ms)"  FOR 9999999999;
COL "Px Servers"         FOR 9999999999;
set pages 300
set lines 5000
 --POR DIA
 select sq.sql_id sql_id,
         sq.plan_hash_value PLAN_HASH_VALUE,
           to_char(s.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI') Day,
           sum(sq.EXECUTIONS_DELTA) Executions,
         sum(sq.ROWS_PROCESSED_DELTA) Rows_,
         round(sum(DISK_READS_delta)/greatest(sum(executions_delta),1),0) "DiskRead/Exec",
         round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),0) "BufferGets/Exec",
         round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),0) "Elapsed/Exec (ms)",
         sum(sq.PX_SERVERS_EXECS_DELTA) "Px Servers"
    from DBA_HIST_SQLSTAT sq,
         DBA_HIST_SNAPSHOT s
   where sql_id  = '&sql_id2' 
--     and sq.plan_hash_value=3586029406
     and s.snap_id = sq.snap_id
     and s.dbid = sq.dbid
     and s.instance_number = sq.instance_number
     and trunc(s.END_INTERVAL_TIME) >= trunc(sysdate)-&days
group by sq.sql_id,
         sq.plan_hash_value,
         to_char(s.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI')
order by 3 desc
/
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF days
UNDEF sql_id2
