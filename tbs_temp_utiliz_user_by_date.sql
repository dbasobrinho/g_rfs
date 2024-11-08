-- 
set lines 3000
set pages 500
COLUMN username             FORMAT a30         HEAD 'username'
COLUMN sample_time          FORMAT a11         HEAD 'sample_time'
COLUMN gig                  FORMAT 9999999     HEAD 'gig'

select z.username, z.sample_time, round(z.gig,3) gig
from (
select b.username, to_char(a.sample_time, 'dd/mm/yyyy') sample_time
      ,max((a.TEMP_SPACE_ALLOCATED)) / (1024 * 1024 * 1024) gig
  from DBA_HIST_ACTIVE_SESS_HISTORY a, dba_users b
 where a.sample_time > sysdate - &days
   --and a.TEMP_SPACE_ALLOCATED > (50 * 1024 * 1024 * 1024)
   and a.USER_ID = b.USER_ID
 group by b.username, to_char(a.sample_time, 'dd/mm/yyyy') )z
 where z.gig is not null
 --and z.username not in ('SYS')
 order by to_date(z.sample_time , 'dd/mm/yyyy hh24')
/