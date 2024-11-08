--
set lines 3000
set pages 500
COLUMN username          FORMAT a30         HEAD 'username'
COLUMN sample_time       FORMAT a14         HEAD 'sample_time'
COLUMN sql_id            FORMAT a15         HEAD 'sql_id'
COLUMN program           FORMAT a30         HEAD 'program'
COLUMN module            FORMAT a20         HEAD 'module'
COLUMN machine           FORMAT a20         HEAD 'machine'
COLUMN temp_use_gb       FORMAT 9999999     HEAD 'temp_use_gb'

select z.username, z.sample_time, round(z.gig,3) temp_use_gb, sql_id, substr(program,1,30) program, module , machine
from (
select b.username, to_char(a.sample_time, 'dd/mm/yyyy hh24') sample_time
      ,max((a.TEMP_SPACE_ALLOCATED)) / (1024 * 1024 * 1024) gig, sql_id, program, module , machine
  from DBA_HIST_ACTIVE_SESS_HISTORY a, dba_users b
 where a.sample_time > sysdate - &days
   --and a.TEMP_SPACE_ALLOCATED > (50 * 1024 * 1024 * 1024)
   and a.USER_ID = b.USER_ID 
   and b.username = '&username'
 group by b.username, to_char(a.sample_time, 'dd/mm/yyyy hh24'), sql_id,program, module , machine )z
 where z.gig is not null
 and z.username not in ('SYS')
 and z.gig is not null
 order by to_date(z.sample_time , 'dd/mm/yyyy hh24')
/
-- JFACHINA