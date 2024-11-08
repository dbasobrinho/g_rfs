set lines 5000
set pages 1000
SET FEEDBACK    0
alter session set statistics_level = all; 
SET FEEDBACK    1
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | XPLAN.DISPLAY_CURSOR FORMAT => 'ADVANCED ALLSTATS LAST'                     |
PROMPT +-----------------------------------------------------------------------------+
PROMPT
ACCEPT sssql_id  char   PROMPT 'SQL ID = '
PROMPT
COL sql_id               FOR A16;
COL predicate            FOR A70;
COL object_owner         FOR A21; 
COL object_name          FOR A35;
COL policy_group         FOR A21; 
COL PLAN_TABLE_OUTPUT    FOR A300;

@xplan.display_cursor.sql '&sssql_id' '0' "ADVANCED ALLSTATS LAST"

UNDEF sssql_id

SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;


