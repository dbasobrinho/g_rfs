select 'Last Applied : ' INFO, to_char(max(next_time),'DD-MON-YY:HH24:MI:SS') Time,thread#,max(sequence#)
from gv$archived_log
where applied='YES'
group by thread# union
select 'Last received : ' INFO, to_char(max(next_time),'DD-MON-YY:HH24:MI:SS') Time,thread#,max(sequence#)
from gv$archived_log
group by thread#
order by  thread# ; 
