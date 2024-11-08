SET SQLPROMPT "_USER'@'_CONNECT_IDENTIFIER _PRIVILEGE> "
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-yyYY hh24:mi:ss';
---- Mostrar instance(s) do banco
set lines 350
set pages 50000
set time on
set timing on
col target format a10
col opname format a15
col message format a26
col inst_id format 999999
col sid format 999999
col serial# format 999999
col execution format a9
col username format a10
col opname format a40
col perc format 999.99
Select INST_ID,sid,username,serial#,substr(to_char(numtodsinterval(elapsed_seconds,'SECOND')),9,8) Execution,round(sofar/totalwork*100,2) perc,
       to_char(start_time,' dd/mm  hh24:mi ') start_time,sofar,
       totalwork,last_update_time, SQL_ID,opname,to_char(time_remaining/(24*3600)+sysdate,'dd/mm hh24:mi') FINISH_TIME
from GV$SESSION_LONGOPS
where sofar<>totalwork and totalwork > 0
order by FINISH_TIME;
exit
