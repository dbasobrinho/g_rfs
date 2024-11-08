--ash_find_dif_sql_ids_last_60_minutes.sql
select distinct sql_id, session_serial# from v$active_session_history
where sample_time >  sysdate - interval '60' minute 
and session_id=&sid
/ 
--Find full sqltext (CLOB) of above sql
select sql_fulltext from v$sql where sql_id='&sql_id'
/