col input_type for a20
col status for a35
SET LINES 1000
SET PAGES 1000
col start_time          for a17
col end_time            for a17
col output_MB           for a10
col TIME_TAKEN_DISPLAY  for a20

SELECT DISTINCT input_type from v$rman_backup_job_details
/

select  input_type,
       status,
       to_char(start_time,'DD/MM/YYYY hh24:mi') start_time,
       to_char(end_time  ,'DD/MM/YYYY hh24:mi') end_time,
       output_bytes_display output_MB,
       time_taken_display
from v$rman_backup_job_details
  where input_type= '&input_type'
  AND start_time > SYSDATE-&DIAS_ATRAS
order by session_key asc
/
