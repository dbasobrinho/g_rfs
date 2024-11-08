set verify off
undefine sid;

prompt          ************ BACKUP EM EXECUÇÃO ************
prompt
 
set lines 200 pages 50000 timin on
column SID format a10
column SID format 999999999
column USERNAME format a10
column "Operation" format A55
column "Done" format A15
column "Total" format A12
column "Unit" format A7
column "Started" format A19
column "Elapsed" format A9
column "Estimated" format A9
column "% Done" format A10
SELECT DISTINCT s.SID, s.username,
       DECODE(TARGET_DESC, NULL, DECODE(TARGET, NULL, OPNAME, CONCAT(OPNAME, CONCAT(' - ', TARGET))),
       DECODE(TARGET, NULL, CONCAT(OPNAME, CONCAT(' : ',TARGET_DESC)),
       CONCAT(OPNAME, CONCAT(' : ', CONCAT(TARGET_DESC, CONCAT(' - ',TARGET)))))) "Operation",
       TO_CHAR(SOFAR, 'FM999,999,990') "Done", TO_CHAR(TOTALWORK, 'FM999,999,990') "Total", /*units "Unit",*/
       TO_CHAR(START_TIME, 'DD/MM/YYYY HH24:MI:SS') "Started",
-- TO_CHAR(ELAPSED_SECONDS,'99,999,990.00') "ElapsedSec",
       TO_CHAR(TRUNC(ELAPSED_SECONDS/3600) , 'FM00') || ':' ||
       TO_CHAR(TRUNC(MOD(ELAPSED_SECONDS, 3600)/60), 'FM00') || ':' ||
       TO_CHAR(MOD(MOD(ELAPSED_SECONDS, 3600), 60) , 'FM00') "Elapsed",
-- TIME_REMAINING "EstimatedSec",
       TO_CHAR(TRUNC(TIME_REMAINING/3600) , 'FM900')|| ':' ||
       TO_CHAR(TRUNC(MOD(TIME_REMAINING, 3600)/60), 'FM00') || ':' ||
       TO_CHAR(MOD(MOD(TIME_REMAINING, 3600), 60) , 'FM00') "Estimated",
       TO_CHAR(SOFAR / TOTALWORK * 100, '99.99') "% Done" --, V$SQL.SQL_TEXT, SQL_ADDRESS
  FROM gV$SESSION_LONGOPS sl, gV$SESSION s, gv$process p
WHERE sl.SID= s.SID AND sl.SERIAL#=s.SERIAL#
AND (sl.SOFAR/sl.TOTALWORK)*100 < 100
AND TOTALWORK > 0
AND s.paddr = p.addr
and OPNAME like '%RMAN%'
ORDER BY SID;


prompt          ************ LOCKS **************
prompt

set line 200
SELECT substr(DECODE(request,0,'Bloqueador: ','Bloqueado: ')||sid,1,20) sessao,
id1, id2, lmode, request, type, inst_id instance FROM GV$LOCK
WHERE (id1, id2, type) IN
(SELECT id1, id2, type FROM GV$LOCK WHERE request>0)
     ORDER BY id1, request;



prompt          ************ SESSÕES INATIVAS BLOQUEANDO ************
prompt
set pagesize 5555
set linesize 500
col username for a50
COL USER FOR A55
COL TRANSACTION_STATUS FOR A10
COL OBJECT_NAME FOR A30
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SELECT A.SID, A.SERIAL#, DECODE(XIDUSN, 0, 'WAITING', 'BLOCKING') "TRANSACTION_STATUS", 
C.OBJECT_NAME, C.OBJECT_TYPE, a.LOGON_TIME, A.USERNAME || CONCAT(' - ' || A.SID, ',' || A.SERIAL#) || CONCAT(' - ', A.OSUSER) || ' ' || A.STATUS "USER"
FROM gV$SESSION A, gV$LOCKED_OBJECT B, DBA_OBJECTS C 
WHERE A.SID = B.SESSION_ID AND 
B.OBJECT_ID = C.OBJECT_ID 
and A.STATUS = 'INACTIVE'
ORDER BY a.LOGON_TIME;



prompt          ************ SESSÕES BLOQUEANDO OBJETOS ************
prompt
set pagesize 5555
set linesize 500
col username for a50
COL USER FOR A55
COL TRANSACTION_STATUS FOR A10
COL OBJECT_NAME FOR A30
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SELECT A.SID, A.SERIAL#, DECODE(XIDUSN, 0, 'WAITING', 'BLOCKING') "TRANSACTION_STATUS", 
C.OBJECT_NAME, C.OBJECT_TYPE, a.LOGON_TIME, A.USERNAME || CONCAT(' - ' || A.SID, ',' || A.SERIAL#) || CONCAT(' - ', A.OSUSER) || ' ' || A.STATUS "USER"
FROM gV$SESSION A, gV$LOCKED_OBJECT B, DBA_OBJECTS C 
WHERE A.SID = B.SESSION_ID AND 
B.OBJECT_ID = C.OBJECT_ID 
--and A.STATUS = 'INACTIVE'
ORDER BY a.LOGON_TIME;


prompt          ************ SESSÕES EM ESPERA ************
prompt
set pagesize 5555
set linesize 500
col username for a50
COL USER FOR A55
COL TRANSACTION_STATUS FOR A10
COL OBJECT_NAME FOR A30
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SELECT A.SID, A.SERIAL#, DECODE(XIDUSN, 0, 'WAITING', 'BLOCKING') "TRANSACTION_STATUS", 
C.OBJECT_NAME, C.OBJECT_TYPE, a.LOGON_TIME, A.USERNAME || CONCAT(' - ' || A.SID, ',' || A.SERIAL#) || CONCAT(' - ', A.OSUSER) || ' ' || A.STATUS "USER"
FROM gV$SESSION A, gV$LOCKED_OBJECT B, DBA_OBJECTS C 
WHERE A.SID = B.SESSION_ID AND 
B.OBJECT_ID = C.OBJECT_ID 
and DECODE(XIDUSN, 0, 'WAITING', 'BLOCKING') = 'WAITING'
ORDER BY a.LOGON_TIME;


prompt          ************ QUEM ESTÁ BLOQUEANDO QUEM ************
prompt

set line 200
col username for a30

select s.username,l1.sid, ' IS BLOCKING ', s.username,l2.sid
from v$lock l1, v$lock l2,v$session s
where l1.block =1 and l2.request > 0
and l1.id1=l2.id1
and l1.id2=l2.id2
and s.sid = l1.sid
/
prompt
prompt


prompt          ************ SESSÃO QUE ESTÁ CAUSANDO LOCK ************
prompt
prompt			DIGITE O SID e serial#
define sid = &SID
prompt
set lines 200
set pages 50000
col username format a10
col sid format 999999
col inst_id format 99999
col sql_text format a36
col status format a8
col module format a20
col action format a20
col logon for a20
col SECONDS_IN_WAIT format 9999
col MACHINE for a20
Select f.inst_id, f.sid, f.serial#,f.username, f.STATUS,to_char(f.LOGON_TIME,'dd-mon-yyyy hh24:mi:ss') logon , f.SECONDS_IN_WAIT "SEG_WAIT", 
f.LAST_CALL_ET "Last_Call", f.module, f.action,s.SQL_TEXT, s.hash_value
  from gv$session f,
       gv$sqlarea s
   where f.inst_id = s.inst_id(+) and f.sql_hash_value = s.hash_value(+)  
   and f.sid= &SID
   order by logon_time;
   
prompt
prompt          ************ SESSÃO QUE ESTÁ CAUSANDO LOCK ************ 
prompt

set lines 1000
set pages 1000
col machine for a20
col username for a10
alter session set nls_date_format='dd-mm-yyyy hh24:mi:SS';
select inst_id, sid, serial#, username, machine,logon_time, event, sql_id,last_call_et
from gv$session
where 
--username = 'TRANSLOGIC'
--username <> 'SYS'
sid=&&sid
--and status = 'INACTIVE'
-- EVENT<> 'SQL*Net message from client'
order by LOGON_TIME
/

	SET SQLBLANKLINES ON
		SET COLSEP '|'
		set time on
		col startup_time    for a20
		col instance_name   for a15
		col host_name       for a10
		col sysdate         for a30
		COL "NOME_SERVIDOR" FOR A27
		col "BANCO_INICIADO" for a30
		col "DATA_E_HORA_SDCA" for a30
		SET lines 900 pages 500 trims on
		SELECT distinct instance_name Nome_Banco, i.host_name Nome_Servidor, to_char(startup_time,'dd/mm/yyyy hh24:mi:ss') Banco_iniciado,
			d.log_mode, i.status, i.logins,d.DATABASE_ROLE, d.open_mode, to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') DATA_E_HORA_SDCA
		FROM gv$instance i, gv$database d; 


