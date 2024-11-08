-- -----------------------------------------------------------------------------------
-- File Name    : jobs_dba_scheduler.sql
-- Author       : Roberto Sobrinho
-- Description  : Mostrar informacoes sobre jobs
-- Requirements : Acesso de leitura nas visoes de DBA
-- Call Syntax  : @jobs_dba_scheduler.sql
-- Last Modified: 09/03/2019
-- -----------------------------------------------------------------------------------SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DBA_SCHEDULER_JOBS                                          |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
PROMPT .
PROMPT . .
PROMPT . . .
ACCEPT jname char   PROMPT 'JOB_NAME or ALL = '
col owner for a6
col job_name for a25
col job_action for a40
COL LAST_START_DATE for a22
COL NEXT_RUN_DATE for a22
COL state for a10
COL LAST_RUN_DURATION for a26
col fail for 9999
col max_fail for 9999

select	owner
	, job_name
	, job_action
	, state, failure_count  fail
	, max_failures max_fail  --qtd de falhas que deve ter para ficar broken
	, TO_CHAR(last_start_date,'DD/MM/YYYY HH24:MI:SS') last_start_date
	, TO_CHAR(next_run_date,'DD/MM/YYYY HH24:MI:SS') next_run_date
	, last_run_duration 
from dba_scheduler_jobs 
where ((upper('&jname') = 'ALL') OR (upper('%&jname%') <> 'ALL' AND job_name LIKE upper('%&jname%')))
/