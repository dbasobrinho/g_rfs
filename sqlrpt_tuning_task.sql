SET LONG 10000;
SET PAGESIZE 9999
SET LINESIZE 155
set verify off
set feedback off
set echo off
col recommendations for a160
PROMPT
PROMPT=================================================
ACCEPT v_sql_id CHAR PROMPT 'SQL_ID  = ' 
PROMPT=================================================
PROMPT
DECLARE
 ret_val VARCHAR2(4000);
BEGIN
begin dbms_sqltune.drop_tuning_task('Homem_na_Estrada_&&v_sql_id'); exception when others then null; end;
ret_val := dbms_sqltune.create_tuning_task(task_name=>'Homem_na_Estrada_&&v_sql_id', sql_id=>'&&v_sql_id', time_limit=>3000);
dbms_sqltune.execute_tuning_task('Homem_na_Estrada_&&v_sql_id');
END;
/
SELECT DBMS_SQLTUNE.report_tuning_task('Homem_na_Estrada_&&v_sql_id') AS recommendations FROM dual;

set echo off
set feedback off
UNDEFINE v_sql_id
