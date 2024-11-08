--ash_top_events.sql
set pages 1000
set lines 1000
col username  format a25 
select event,
sum(wait_time +time_waited) ttl_wait_time
from v$active_session_history 
where sample_time between sysdate - 60/2880 and sysdate
group by event
order by 2 ;
