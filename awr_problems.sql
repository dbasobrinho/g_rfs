/* Configurações */
ALTER SESSION SET nls_numeric_characters=',.';
SET SERVEROUTPUT ON SIZE 1000000 PAGES 50000 LINES 10000 VERIFY OFF FEEDBACK OFF TRIMSPOOL ON TERMOUT OFF COLSEP ';'

spool YAMAN_AWR_PROBLEMS_&1..csv

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
     AND A.execution_end BETWEEN to_date('&2','yyyymmddhh24mi') AND to_date('&3','yyyymmddhh24mi')
ORDER BY a.execution_end DESC,
         b.impact,
         d.rank;

spool off