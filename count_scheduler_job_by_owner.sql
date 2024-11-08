alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Contagem dba_scheduler_job_run_details                                 |
PROMPT +------------------------------------------------------------------------+
PROMPT
--ACCEPT sql_id9 char   PROMPT 'SQL ID = '
SET LINES 200
SET PAGES 1000   
col total       for 99999 
col INSTANCE_ID for 99
col OWNER       for a10
col STATUS      for a15
col LOG_DATE    for a16
col ADDITIONAL_INFO    for a18
col node        for 99999
--break on plan_hash_value on startup_time skip 1
select count(1) total,
       to_char(LOG_DATE,'dd/mm/yyyy hh24')LOG_DATE,
       INSTANCE_ID,
       OWNER,
      -- JOB_NAME,
       --JOB_SUBNAME,
       STATUS,
       ERROR#,
      -- sum(RUN_DURATION) sum_RUN_DURATION,
       substr(ADDITIONAL_INFO,1,12) ADDITIONAL_INFO
  from dba_scheduler_job_run_details
  where owner = TRIM(UPPER('&OWNER'))
      --JOB_NAME like 'SS_JOB%'
  and trunc(LOG_DATE) >= trunc(sysdate) -&DAYS
  group by 
       to_char(LOG_DATE,'dd/mm/yyyy hh24'),
       INSTANCE_ID,
       OWNER,
     --  JOB_NAME,
       JOB_SUBNAME,
       STATUS,
       ERROR#,
       substr(ADDITIONAL_INFO,1,12)
  order by LOG_DATE desc, INSTANCE_ID, status desc
/  
