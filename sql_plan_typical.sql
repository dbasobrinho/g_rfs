set lines 5000
set pages 1000
SET FEEDBACK    0
alter session set statistics_level = all;
SET FEEDBACK    1
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | SQL_PLAN  FORMAT => 'TYPICAL allstats +peeked_binds last'                   |
PROMPT +-----------------------------------------------------------------------------+
PROMPT
ACCEPT sssql_id  char   PROMPT 'SQL ID = '
PROMPT
COL sql_id               FOR A16;
COL predicate            FOR A70;
COL object_owner         FOR A21; 
COL object_name          FOR A35;
COL policy_group         FOR A21;
COL PLAN_TABLE_OUTPUT    FOR A210;

select * from table(dbms_xplan.display_cursor(SQL_ID => '&sssql_id', FORMAT => 'TYPICAL allstats +peeked_binds last' ));

UNDEF sssql_id

