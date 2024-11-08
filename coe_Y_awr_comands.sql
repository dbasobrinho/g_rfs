--@coe_Y_awr_comands.sql fidelity 202004270000 202004280000

ALTER SESSION SET nls_numeric_characters=',.';
SET SERVEROUTPUT ON SIZE 1000000 PAGES 50000 LINES 10000 VERIFY OFF FEEDBACK OFF TRIMSPOOL ON TERMOUT OFF COLSEP ';'


column cpu_time_s     format 99999999990.9
column elap_time_s    format 99999999990.9
column parses         format 99999999
column execs          format 9999999999
column pct            format 90.99
column sql_text       format a31
column module         for a100


set echo on
SET TIMING ON
EXEC dbms_application_info.set_module( module_name => 'coe_Y_awr_comands! WORKING -> ', action_name =>  'coe_Y_awr_comands');
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
col fn new_value banco;
SELECT 'coe_Y_awr_comands_'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS')||'.csv' as fn from dual;
spool &BANCO;



WITH
SNAP_MIN AS (select snap_id snap_id_min
				from (select snap_id,
							 MIN(begin_interval_time) over() begin_interval_time_min,
							 begin_interval_time
						from dba_hist_snapshot
					   where begin_interval_time >= to_date('&2','yyyymmddhh24mi'))
			   where begin_interval_time_min = begin_interval_time),
SNAP_MAX AS (select snap_id snap_id_max
				from (select snap_id,
							 MAX(end_interval_time) over() end_interval_time_max,
							 end_interval_time
						from dba_hist_snapshot
					   where end_interval_time <= to_date('&3','yyyymmddhh24mi'))
			   where end_interval_time_max = end_interval_time)
select *
  from (select /*+ ordered use_nl (b st) */
               ratio_to_report(nvl(to_number(elap_time_s),0)) over ()*100 PCT,
               t.*
		  from (select sq.*,
                       substr(trim(st.sql_text), 1, 30) sql_text
                  from (  SELECT SQL_ID                      ,
                                 nvl(module,'VAZIO')   module   ,
                                 SUM(BUFFER_GETS_DELTA) buffer_gets,
                                 SUM(DISK_READS_DELTA) disk_reads,
                                 SUM(CPU_TIME_DELTA)/1000000 cpu_time_s,
                                 SUM(ELAPSED_TIME_DELTA)/1000000 ELAP_time_s,
                                 SUM(PARSE_CALLS_DELTA) parses,
                                 SUM(EXECUTIONS_DELTA) execs
                            FROM DBA_HIST_SQLSTAT,
							     SNAP_MIN,
								 SNAP_MAX
                           WHERE SNAP_ID (+)  <=  snap_id_min
                             AND SNAP_ID      <= snap_id_max
                             AND module is not null
                        GROUP BY SQL_ID,
						         nvl(module,'VAZIO')  ) sq,
                       DBA_HIST_SQLTEXT st
                 WHERE SQ.SQL_ID = ST.SQL_ID
                   and (upper(ltrim(st.sql_text)) like 'INSERT%'
                    or  upper(ltrim(st.sql_text)) like 'UPDATE%'
                    or  upper(ltrim(st.sql_text)) like 'DELETE%'
                    or  upper(ltrim(st.sql_text)) like 'SELECT%')) t
      order by pct desc)
 where rownum <= 25;

spool off
