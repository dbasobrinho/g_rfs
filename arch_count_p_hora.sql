set pages 5000
set lines 5000
select z.first_time_hrs, total_arch
from (
select trunc(x.first_time) first_time
       ,to_char(x.first_time, 'dd/mm/yyyy hh24') first_time_hrs
      ,count(x.SEQUENCE#) total_arch
  from v$archived_log x
 group by trunc(x.first_time),  to_char(x.first_time, 'dd/mm/yyyy hh24')
 order by trunc(x.first_time) asc  ) z
 order by z.first_time, to_date(first_time_hrs, 'dd/mm/yyyy hh24');
