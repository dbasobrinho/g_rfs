set lines 5000
set pages 1000
SET FEEDBACK    0
alter session set statistics_level = all;
SET FEEDBACK    1
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | SQL_PLAN HASH [GV$SQL]                                                      |
PROMPT +-----------------------------------------------------------------------------+
PROMPT
ACCEPT sssql_id  char   PROMPT 'SQL ID = '
PROMPT
COL sql_id               FOR A16;
COL child_number         FOR 999999999;
COL plan_hash            FOR 9999999999999999;
COL execs                FOR 999999999;
COL avg_etime            FOR 999999999;
COL avg_lio              FOR 999999999;
COL sql_text             FOR a80;

select sql_id, child_number, plan_hash_value plan_hash, executions execs,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
substr(sql_text,1,80)  as sql_text
from gv$sql s
where sql_id='&sssql_id'
/

UNDEF sssql_id

