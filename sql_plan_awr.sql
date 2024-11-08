set lines 600
set pages 600
SET FEEDBACK    0
alter session set statistics_level = all; 
SET FEEDBACK    1
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | XPLAN.DISPLAY_CURSOR FORMAT => 'ALL iostats +peeked_binds -alias last'      |
PROMPT +-----------------------------------------------------------------------------+
PROMPT 
--ACCEPT sssql_id  char   PROMPT 'SQL ID = '
PROMPT
COL sql_id               FOR A16;
COL predicate            FOR A70;
COL object_owner         FOR A21; 
COL object_name          FOR A35;
COL policy_group         FOR A21; 
COL PLAN_TABLE_OUTPUT    FOR A100;
select * from table(dbms_xplan.display_awr('&1'));

UNDEF sssql_id
UNDEF 1