-- |----------------------------------------------------------------------------|
-- | Objetivo   : SQLs que estao Zuando tudo                                    |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 21/10/2020                                                    |
-- | Exemplo    : @coe_top10_sql_FIFI     >>FIFI ESTA DANDO TCHAU, QUE HORROR!! |
-- | Arquivo    : coe_top10_sql_FIFI.sql                                        |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | FIFI, FIFI, AONDE VAI FIFI, AONDE VAI FIFI                             |
PROMPT +------------------------------------------------------------------------+
PROMPT
PROMPT
SET FEEDBACK   off
set lines 1000  
set pages 500  
set timing off
set verify off
--ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
ACCEPT DATA_INI CHAR PROMPT 'Data Inicial (DD/MM/YYYY) = '
ACCEPT DATA_FIM CHAR PROMPT 'Data Final   (DD/MM/YYYY) = '
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

SET FEEDBACK   off
drop table aux_top10
/
create table aux_top10 as
(select to_date('&&DATA_INI','dd/mm/yyyy') Controle,ss.sql_id, SQL_PROFILE, min(s.begin_interval_time) min_time, max(s.begin_interval_time) max_time, 
        sum(ss.executions_delta) sum_execs, sum(ss.disk_reads_delta) sum_disk_reads, sum(ss.buffer_gets_delta) sum_buffer_gets, sum(ss.cpu_time_delta)/1000000 sum_cpu_time, 
             sum(ss.elapsed_time_delta)/1000000 sum_elapsed_time
          from dba_hist_sqlstat     ss,
                 dba_hist_snapshot s
          where ss.dbid = s.dbid
          and ss.instance_number = s.instance_number
          and ss.snap_id = s.snap_id
          and s.begin_interval_time >= to_date('&&DATA_INI','dd/mm/yyyy')
          and s.begin_interval_time < to_date('&&DATA_FIM','dd/mm/yyyy')
          and ss.PARSING_SCHEMA_NAME IN (SELECT usr.username FROM sys.dba_users usr WHERE usr.created > (SELECT created FROM sys.v_$database)  )
          group by to_date('&&DATA_INI','dd/mm/yyyy'),ss.sql_id, SQL_PROFILE)
/
insert into top10_mensal (select a.* from aux_top10 a, (select sql_id from aux2_top10 where rownum < 11) b where a.sql_id = b.sql_id)
/
commit;
/
SET FEEDBACK   ON
col sum_execs   format 999,999,999,999      
col sql_id      format a13
col sql_profile format a30
col MIN_TIME    format a30
col MAX_TIME    format a30
select a.sql_id, a.SQL_PROFILE, a.MIN_TIME, a.MAX_TIME, a.SUM_EXECS from top10_mensal a where a.controle > sysdate-60 order by sum_execs desc
/
