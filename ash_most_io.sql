--ash_most_io.sql
set pages 1000
set lines 1000
col username  format a25 
SELECT sql_id, COUNT(*)
FROM gv$active_session_history ash, gv$event_name evt
WHERE ash.sample_time > SYSDATE - 1/24
AND ash.session_state = 'WAITING'
AND ash.event_id = evt.event_id
AND evt.wait_class = 'User I/O'
GROUP BY sql_id
ORDER BY COUNT(*) DESC
/
SELECT * FROM TABLE(dbms_xplan.display_cursor('&SQL_ID'))
/
