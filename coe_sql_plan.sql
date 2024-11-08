--> Script to display the execution plan of an SQL Statement 
-->
--> Parameters: instance number, sql_id
--> To Run: @xplan.sql inst_num sql_id
--> Example: @xplan.sql 1 27b3qfm5x89xn
--> 
--> Copyright 2020@The Ultimate SQL Tuning Formula


define inst=&1
define sqlid=&2

set linesize 200
set pagesize 200

col sql_id for A15
col child_number for 9999999999999
col plan_hash_value for 9999999999999
col elapsed for 
col plan_table_output for A100

select SQL_ID 
, CHILD_NUMBER 
, plan_hash_value
, round(ELAPSED_TIME/1000000/greatest(EXECUTIONS,1),3) ELAPSED
, round(CPU_TIME/1000000/greatest(EXECUTIONS,1),3) CPU
, EXECUTIONS "EXEC"
, BUFFER_GETS/greatest(EXECUTIONS,1) lio
, DISK_READS/greatest(EXECUTIONS,1) pio
, ROWS_PROCESSED/greatest(EXECUTIONS,1) NUM_ROWS
--, SQL_TEXT
from gv$sql 
where inst_id=&inst
  and sql_id ='&sqlid'
order by sql_id, child_number
/

-- Display the execution plan from the cursor cache.

select plan_table_output from table(dbms_xplan.display_cursor('&sqlid',NULL,'ADVANCED -PROJECTION -BYTES RUNSTATS_LAST'));


/* Sample output

@xplan.sql 31d96zzzpcys9 1

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
SQL_ID  31d96zzzpcys9, child number 0
-------------------------------------
select * from hr.employees where employee_id=100

Plan hash value: 1833546154

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | E-Rows | Cost (%CPU)| E-Time   |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |        |     1 (100)|          |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES     |      1 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | EMP_EMP_ID_PK |      1 |     0   (0)|          |
--------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1 / EMPLOYEES@SEL$1
   2 - SEL$1 / EMPLOYEES@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('18.1.0')
      DB_VERSION('18.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      INDEX_RS_ASC(@"SEL$1" "EMPLOYEES"@"SEL$1" ("EMPLOYEES"."EMPLOYEE_ID"))
      END_OUTLINE_DATA
  */
----
----Predicate Information (identified by operation id):
-------------------------------------------------------
----
----   2 - access("EMPLOYEE_ID"=100)
----
----Note
---------
----   - Warning: basic plan statistics not available. These are only collected when:
----       * hint 'gather_plan_statistics' is used for the statement or
----       * parameter 'statistics_level' is set to 'ALL', at session or system level
----
----*/