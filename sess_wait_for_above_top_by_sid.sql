--sess_wait_for_above_top_by_sid.sql
set pages 1000
set lines 1000
col username  format a25 
select event, total_waits, time_waited/100/60 time_waited_minutes,
       average_wait*10 aw_ms, max_wait/100 max_wait_seconds
from v$session_event
where sid=&sid 
order by 5 desc
/