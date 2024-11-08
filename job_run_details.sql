-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/11g/job_run_details.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays scheduler job information for previous runs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_run_details (job-name | all)
-- Last Modified: 06/06/2014
-- -----------------------------------------------------------------------------------
SET LINESIZE 300 VERIFY OFF
set pages 500

COLUMN log_date FORMAT A17
COLUMN owner_10 FORMAT A10
COLUMN job_name FORMAT A30
COLUMN status FORMAT A15
COLUMN req_start_date FORMAT A17
COLUMN actual_start_date FORMAT A17
COLUMN run_duration FORMAT A18
COLUMN credential_owner FORMAT A20
COLUMN credential_name FORMAT A20
COLUMN additional_info FORMAT A40
PROMPT .
PROMPT . .
PROMPT . . .
ACCEPT j_name char   PROMPT 'JOB_NAME or ALL = '

select z.log_date, z.owner_10, z.job_name, z.status, z.req_start_date, z.actual_start_date, z.run_duration, substr(z.additional_info,1,40) additional_info
from(
SELECT to_char(log_date,'dd/mm/rr hh24:mi:ss')log_date,
       to_number(to_char(log_date,'yyyymmddhh24miss'))log_date2,
       substr(owner,1,10) owner_10,
       job_name,
       status,
       to_char(req_start_date,'dd/mm/rr hh24:mi:ss') req_start_date,
       to_char(actual_start_date,'dd/mm/rr hh24:mi:ss') actual_start_date, 
       run_duration,
       credential_owner,
       credential_name,
       additional_info
FROM   dba_scheduler_job_run_details
WHERE  job_name = DECODE(UPPER('&j_name'), 'ALL', job_name, UPPER('&j_name'))
ORDER BY 2) z
/


