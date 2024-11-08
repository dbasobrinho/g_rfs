--ash_top_segments.sql
set pages 1000
set lines 1000
col object_name  format a40 
col object_type  format a25 
col event        format a50

SELECT dba_objects.object_name,
dba_objects.object_type,
active_session_history.event,
SUM(active_session_history.wait_time +
active_session_history.time_waited) ttl_wait_time
FROM v$active_session_history active_session_history,
dba_objects
WHERE active_session_history.sample_time BETWEEN SYSDATE - 1 AND SYSDATE
AND active_session_history.current_obj# = dba_objects.object_id
GROUP BY dba_objects.object_name, dba_objects.object_type, active_session_history.event
ORDER BY 4 DESC;
