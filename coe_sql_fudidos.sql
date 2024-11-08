-- |----------------------------------------------------------------------------|
-- | Objetivo   : SQLs que estao Zuando tudo                                    |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 02/04/2018                                                    |
-- | Exemplo    : @coe_sql_fudidos                                              |
-- | Arquivo    : coe_sql_fudidos.sql                                           |
-- | Modificacao: 10/05/2019 - RFSOBRINHO - INCLUSÃO DE BUFFER_GETS             |
-- +----------------------------------------------------------------------------+

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | SQLs FERRANDO O BANCO                                                  |
PROMPT +------------------------------------------------------------------------+
PROMPT
PROMPT
SET FEEDBACK   off
set lines 1000  
set pages 500  
set timing off
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';

COL sql_id               FOR A16;
COL type                 FOR A15;
COL SQL_PLAN_HASH_VALUE  FOR 9999999999;
COL starting_time        FOR A21;
COL end_time             FOR A21;
COL run_time_sec         FOR 9999999999;
COL READ_IO_BYTES        FOR 9999999999;
COL PGA_ALLOCATED_BYTES  FOR 9999999999;
COL TEMP_ALLOCATED_BYTES FOR 9999999999;
SET FEEDBACK   on
with query_stats as
(select sql_id,
         type,
         sum(run_time_sec) run_time_sec,
         sum(read_io_bytes) read_io_bytes,
         sum(pga_allocated_bytes) pga_allocated_bytes,
         sum(temp_allocated_bytes) temp_allocated_bytes
    from (select ash.sql_id,
                 ash.type,
                 (EXTRACT(HOUR FROM run_time) * 3600 +
                 EXTRACT(MINUTE FROM run_time) * 60 +
                 EXTRACT(SECOND FROM run_time)) run_time_sec,
                 ash.READ_IO_BYTES,
                 ash.PGA_ALLOCATED PGA_ALLOCATED_BYTES,
                 ash.TEMP_ALLOCATED TEMP_ALLOCATED_BYTES
            from (select sql_id,
                         aud.name type,
                         max(sample_time - sql_exec_start) run_time,
                         sum(DELTA_READ_IO_BYTES) READ_IO_BYTES,
                         sum(DELTA_PGA) PGA_ALLOCATED,
                         sum(DELTA_TEMP) TEMP_ALLOCATED
                    from (select sql_id,
                                 sample_time,
                                 sql_exec_start,
                                 DELTA_READ_IO_BYTES,
                                 sql_exec_id,
                                 sql_opcode,
                                 greatest(PGA_ALLOCATED -
                                          first_value(PGA_ALLOCATED)
                                          over(partition by sql_id,
                                               sql_exec_id order by sample_time rows 1
                                               preceding),
                                          0) DELTA_PGA,
                                 greatest(TEMP_SPACE_ALLOCATED -
                                          first_value(TEMP_SPACE_ALLOCATED)
                                          over(partition by sql_id,
                                               sql_exec_id order by sample_time rows 1
                                               preceding),
                                          0) DELTA_TEMP,
                                 session_state,
                                 wait_class
                            from dba_hist_active_sess_history
                           where sample_time >= sysdate - 1
                             and sql_exec_start is not null
                             and IS_SQLID_CURRENT = 'Y') ash,
                         audit_actions aud
                   where ash.sql_opcode = aud.action
                   group by sql_id, SQL_EXEC_ID, sql_exec_start, aud.name
                   order by sql_id) ash)
   group by sql_id, type),
query_exec as
(SELECT sql.sql_id,
         sql.parsing_schema_name,
         sum(sql.executions_delta) sql_day_exec,
         sum(sql.DISK_READS_DELTA) DISK_READS,
         sum(sql.BUFFER_GETS_DELTA) BUFFER_GETS,
         sum(sql.CPU_TIME_DELTA / 1000000) CPU_TIME,
         sum(sql.IOWAIT_DELTA / 1000000) IOWAIT_TIME,
         avg(OPTIMIZER_COST) * sum(sql.executions_delta) COST_ADV
    FROM dba_hist_sqlstat sql
    JOIN dba_hist_snapshot ss
      ON sql.snap_id = ss.snap_id
   WHERE ss.begin_interval_time >= SYSDATE - 1
     and executions_delta != 0
   group by sql_id, parsing_schema_name),
final_query as
(select qs.sql_id,
         qe.sql_day_exec,
         qs.type,
         qs.run_time_sec tempo_total,
         qe.IOWAIT_TIME tempo_em_io,
         qe.CPU_TIME tempo_em_cpu,
         qe.BUFFER_GETS buffer_gets,
         qe.DISK_READS Physical_IO,
         round(qs.run_time_sec / qe.sql_day_exec) TEMPO_MEDIO_EXEC,
         qs.read_io_bytes / 1024 IO_MB_TOTAL,
         qs.pga_allocated_bytes / 1024 PGA_MB_TOTAL,
         qs.temp_allocated_bytes / 1024 TEMP_MB_TOTAL,
         trunc(COST_ADV) COST_ADV
    from query_stats qs, query_exec qe
   where qe.sql_id = qs.sql_id and COST_ADV > 0)
select sql_id, sql_day_exec, type, TEMPO_TOTAL, TEMPO_EM_IO, TEMPO_EM_CPU, BUFFER_GETS, Physical_IO, TEMPO_MEDIO_EXEC, IO_MB_TOTAL, PGA_MB_TOTAL, TEMP_MB_TOTAL, COST_ADV
  from final_query
order by COST_ADV desc
/
