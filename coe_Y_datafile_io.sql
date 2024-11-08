ALTER SESSION SET nls_numeric_characters=',.';
SET SERVEROUTPUT ON SIZE 1000000 PAGES 50000 LINES 10000 VERIFY OFF FEEDBACK OFF TRIMSPOOL ON TERMOUT OFF COLSEP ';'

set echo on
SET TIMING ON
EXEC dbms_application_info.set_module( module_name => 'coe_Y_datafile_io! WORKING -> ', action_name =>  'coe_Y_datafile_io');
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
col fn new_value banco;
SELECT 'coe_Y_datafile_io_'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS')||'.csv' as fn from dual;
spool &BANCO;


WITH
t_raw AS ( SELECT TO_CHAR(b.end_interval_time,'DD/MM/YYYY HH24:MI') snap_time,
                  '[' || file# || ']...' || SUBSTR(REPLACE(a.filename,'\','/'),INSTR(REPLACE(a.filename,'\','/'),'/',-1),LENGTH(REPLACE(a.filename,'\','/'))) filename,
				  filename full_filename,
                  phyrds phy_reads,
				  readtim*10 time_spent_reads_ms,
				  b.instance_number
             FROM dba_hist_filestatxs a,
                  dba_hist_snapshot b
            WHERE a.instance_number = b.instance_number
              AND a.snap_id = b.snap_id
              AND a.dbid = b.dbid
              AND 1=1
              AND end_interval_time >= to_date('&2','yyyymmddhh24mi')
              AND end_interval_time <= to_date('&3','yyyymmddhh24mi')
         ORDER BY TO_DATE(snap_time, 'DD/MM/YYYY HH24:MI') ),
t_lag AS ( SELECT snap_time,
                  filename,
				  phy_reads,
				  time_spent_reads_ms,
                  time_spent_reads_ms - LAG(time_spent_reads_ms,1) OVER (PARTITION BY full_filename ORDER BY snap_time) l_time_spent_reads_ms,
				  phy_reads - LAG(phy_reads,1) OVER (PARTITION BY full_filename ORDER BY snap_time) l_phy_reads,
				  instance_number
             FROM t_raw ),
t_io AS ( SELECT snap_time || ';' ||
                 filename || ';' ||
                 ROUND(DECODE(SIGN(l_time_spent_reads_ms),-1,time_spent_reads_ms, l_time_spent_reads_ms)/DECODE(SIGN(l_phy_reads),NULL,1,-1,DECODE(phy_reads,NULL,1,0,1,phy_reads),0,1,l_phy_reads)) || ';' ||
				 instance_number DADOS,
				 snap_time,
				 instance_number
            FROM t_lag )
  SELECT DADOS "Date;Name;AvgReadMs;InstNum"
    FROM t_io 
GROUP BY DADOS, snap_time, instance_number
ORDER BY instance_number, TO_DATE(snap_time,'DD/MM/YYYY HH24:MI');
/

spool off