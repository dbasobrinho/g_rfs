/* Configurações */
ALTER SESSION SET nls_numeric_characters=',.';
SET SERVEROUTPUT ON SIZE 1000000 PAGES 50000 LINES 10000 VERIFY OFF FEEDBACK OFF TRIMSPOOL ON TERMOUT OFF COLSEP ';'

set echo on
SET TIMING ON
EXEC dbms_application_info.set_module( module_name => 'coe_Y_awr_problems! WORKING -> ', action_name =>  'coe_Y_awr_problems');
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
col fn new_value banco;
SELECT 'coe_Y_awr_problems_'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS')||'.csv' as fn from dual;
spool &BANCO;


 SELECT a.execution_end,
        b.type,
        b.impact,
        d.rank,
        d.type,
        'Message : '||c.command COMMAND,
        'Action Message : ' ||c.message ACTION_MESSAGE
   FROM dba_advisor_tasks a,
        dba_advisor_findings b,
        dba_advisor_actions c,
        dba_advisor_recommendations d
   WHERE a.owner=b.owner
     AND a.task_id=b.task_id
     AND b.task_id=d.task_id
     AND b.finding_id=d.finding_id
     AND a.task_id=c.task_id
     AND d.rec_id=c.rec_id
     AND a.task_name LIKE 'ADDM%'
     AND a.status='COMPLETED'
     AND A.execution_end BETWEEN to_date(to_char(SYSDATE-30,'yyyymmddhh24mi'),'yyyymmddhh24mi') 
	                         AND to_date(to_char(SYSDATE,   'yyyymmddhh24mi'),'yyyymmddhh24mi') 
ORDER BY a.execution_end DESC,
         b.impact,
         d.rank;

spool off