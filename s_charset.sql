set linesize 300
set pagesize 1000
col osuser format a20
col username format a20
col client_charset format a30
col "SID/SERIAL" format a13 
col program format a20 trunc
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/mm/YYYY HH24:MI:SS'
/
select distinct i.sid || ',' || i.serial#|| case when i.inst_id is not null then ',@' || i.inst_id end  "SID/SERIAL",
s.username, i.osuser,  i.AUTHENTICATION_TYPE, s.program, i.client_charset, s.logon_time, s.status
from  gv$session_connect_info i, gv$session s
where i.sid = s.sid
and i.serial#=s.serial#
and i.inst_id = s.inst_id
order by i.client_charset desc 
/ 