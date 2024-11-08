--ash_top_sessions.sql
set pages 1000
set lines 1000
col username  format a25 
select sesion.sid
      ,sesion.username
      ,sum(ash.wait_time + ash.time_waited) / 1000000 / 60 ttl_wait_time_in_minutes
  from v$active_session_history ash
      ,v$session                sesion
 where sample_time between sysdate - 60 / 2880 and sysdate
   and ash.session_id = sesion.sid
 group by sesion.sid
         ,sesion.username
 order by 3 desc;
