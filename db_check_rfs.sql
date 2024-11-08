set verify off
undefine sid;
set lines 400 pages 50000 
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
COLSEP
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : IDENTIFICACAO                       +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
set timing      OFF
SET UNDERLINE   	'-'
SET COLSEP      '|'
SET FEEDBACK    OFF
SET SQLBLANKLINES ON
COLUMN INSTANCE_NAME FORMAT A13
COLUMN DB_STATUS     FORMAT A10
COLUMN VERSION       FORMAT A10
COLUMN HOST_NAME     FORMAT A17
COLUMN STARTUP_TIME  FORMAT A22
COLUMN ACTIVE_STATE  FORMAT A12
COLUMN date_scn      FORMAT A22
COLUMN cur_scn       FORMAT A8
COLUMN f_logging     FORMAT A10
COLUMN BLOCKED       FORMAT A5
COLUMN THREAD        FORMAT A6
COLUMN THREAD        FORMAT A4
COLUMN I_NUM         FORMAT 999
COLUMN NAME          FORMAT A8
COLUMN OPEN_MODE           FORMAT A10
COLUMN RESETLOGS_CHANGE    FORMAT 9999999999999999    HEAD 'RESETLOGS|CHANGE'    
COLUMN RESETLOGS_TIME      FORMAT A21           HEAD 'RESETLOGS TIME'    
COLUMN OPEN_RESETLOGS      FORMAT A15           HEAD 'OPEN|RESETLOGS'  
COLUMN LOG_MODE            FORMAT A11
COLUMN FLASHBACK_ON        FORMAT A9            HEAD 'FLASHBACK|ON'   JUSTIFY RIGHT
COLUMN CONTROLFILE_SEQ     FORMAT 9999999999    HEAD 'CONTROLFILE|SEQ'  
COLUMN VERSION_TIME        FORMAT A21           HEAD 'VERSION_TIME'  
COLUMN I_NUM         FORMAT 999
COLUMN INSTANCE_NAME FORMAT A13
COLUMN HOST_NAME     FORMAT A28
COLUMN VERSION       FORMAT A13
COLUMN STARTUP_TIME  FORMAT A22
COLUMN ACTIVE_STATE  FORMAT A12
COLUMN DB_STATUS     FORMAT A10
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Check    : DATABASE                                                    |
PROMPT +------------------------------------------------------------------------+
SELECT  NAME
       ,OPEN_MODE
       ,RESETLOGS_CHANGE# as RESETLOGS_CHANGE
	   ,TO_CHAR(RESETLOGS_TIME,'DD/MM/YYYY HH24:MI:SS') RESETLOGS_TIME
	   ,OPEN_RESETLOGS
	   ,LOG_MODE
	   ,FORCE_LOGGING f_logging
	   ,FLASHBACK_ON
	   ,CONTROLFILE_SEQUENCE# CONTROLFILE_SEQ
	   ,TO_CHAR(VERSION_TIME,'DD/MM/YYYY HH24:MI:SS') VERSION_TIME
FROM v$database A
/
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Check    : INSTANCE                                                    |
PROMPT +------------------------------------------------------------------------+
SELECT INSTANCE_NUMBER AS I_NUM,
	   A.INSTANCE_NAME INSTANCE_NAME, 
	   A.HOST_NAME HOST_NAME,
	   A.VERSION, 
	   TO_CHAR(A.STARTUP_TIME, 'DD/MM/YYYY HH24:MI:SS') STARTUP_TIME, 
	   A.ACTIVE_STATE,
	   A.DATABASE_STATUS DB_STATUS   ,
	   A.INSTANCE_ROLE
FROM GV$INSTANCE A
/
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
COLUMN group_name             FORMAT a25           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'
COLUMN pct_free               FORMAT 999.99        HEAD 'Pct. Free'
BREAK ON report ON disk_group_name SKIP 1
COMPUTE sum LABEL "Grand Total: " OF total_mb used_mb ON report
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Check    : ASM                                                         |
PROMPT +------------------------------------------------------------------------+
SELECT
    name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , trunc(total_mb/1024)                     total_gb
  , trunc((total_mb - free_mb)/1024)         used_gb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
  , 100 - (ROUND((1- (free_mb / total_mb))*100, 2))  pct_free
FROM
    v$asm_diskgroup
WHERE
    total_mb != 0
ORDER BY
    pct_free DESC
/

CLEAR COLUMNS
COLUMN TABLESPACE           FORMAT A30                 HEADING  "TABLESPACE|NAME"   JUSTIFY CENTER
COLUMN STATUS               FORMAT A08                 HEADING  "STATUS|-"          JUSTIFY CENTER
COLUMN TOTAL_MB             FORMAT A10                 HEADING  " TOTAL|SIZE"       JUSTIFY CENTER
COLUMN USED_MB              FORMAT A10                 HEADING  "USED|SIZE"         JUSTIFY CENTER
COLUMN FREE_MB              FORMAT A10                 HEADING  "FREE|SIZE"         JUSTIFY CENTER
COLUMN TOTAL_MB_MAX         FORMAT A10                 HEADING  " TOTAL|SIZE EXT"   JUSTIFY CENTER
COLUMN USED_MB_MAX          FORMAT A10                 HEADING  "MAX USED|SIZE"     JUSTIFY CENTER
COLUMN FREE_MB_MAX          FORMAT A10                 HEADING  "FREE|SIZE EXT"     JUSTIFY CENTER
COLUMN PCT_USED             FORMAT 999.99              HEADING  " % USED|-"         JUSTIFY CENTER
COLUMN GRAPH                FORMAT A25                 HEADING  "GRAPH| (X=5%)"     JUSTIFY CENTER
COLUMN PCT_USED_MAX         FORMAT 999.99              HEADING  " % USED|EXT"       JUSTIFY CENTER
COLUMN GRAPH_MAX            FORMAT A25                 HEADING  "GRAPH| (X=5%) EXT" JUSTIFY CENTER
COLUMN GRAPH_EXTEND         FORMAT A25 HEADING "GRAPH_EXT (X=5%)"
COLUMN TOTAL_MB_MAX2        FORMAT A10
COLUMN USED_MB2             FORMAT A10
COMPUTE                     SUM OF TOTAL_MB     ON REPORT
COMPUTE                     SUM OF USED_MB      ON REPORT
COMPUTE                     SUM OF FREE_MB      ON REPORT
COMPUTE                     SUM OF TOTAL_MB_MAX ON REPORT
COMPUTE                     SUM OF USED_MB_MAX  ON REPORT
COMPUTE                     SUM OF FREE_MB_MAX  ON REPORT
BREAK   ON REPORT           
SET PAGESIZE            1000 
SET LINESIZE            230
SET COLSEP '|'

select z.*
from (
SELECT  /*+ PARALLEL(TOTAL,2) PARALLEL(FREE,2) */
TOTAL.TS                                                as TABLESPACE,
DECODE(TOTAL.MB,NULL,'OFFLINE',DBAT.STATUS)             as STATUS,
lpad(dbms_xplan.format_size(TOTAL.MB),10,' ')                        as TOTAL_MB,
lpad(dbms_xplan.format_size(NVL(TOTAL.MB-FREE.MB,TOTAL.MB)),10,' ')  as USED_MB,
lpad(dbms_xplan.format_size(NVL(FREE.MB,0)),10,' ')                  as FREE_MB,
DECODE(TOTAL.MB,NULL,0,NVL(ROUND((TOTAL.MB - FREE.MB)/(TOTAL.MB)*100,2),100))  as PCT_USED,
CASE WHEN (TOTAL.MB IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']' 
                             ELSE '['|| DECODE(FREE.MB,NULL,'XXXXXXXXXXXXXXXXXXXX',NVL(RPAD(LPAD('X',TRUNC((100-ROUND( (FREE.MB)/(TOTAL.MB) * 100, 2))/5),'X'),20,'-'),'--------------------'))||']' END AS GRAPH,
lpad(dbms_xplan.format_size(TOTAL.MB_MAX),10,' ')                                            as TOTAL_MB_MAX,
lpad(dbms_xplan.format_size(TOTAL.MB_MAX - NVL(TOTAL.MB-FREE.MB,TOTAL.MB)),10,' ')           as FREE_MB_MAX,
DECODE(TOTAL.MB_MAX,NULL,0,ROUND(100-(((TOTAL.MB_MAX - NVL(TOTAL.MB-FREE.MB,TOTAL.MB)) *100) / TOTAL.MB_MAX),2)) as PCT_USED_MAX,
CASE WHEN (TOTAL.MB_MAX IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']' 
                             ELSE '['|| DECODE((TOTAL.MB_MAX - NVL(TOTAL.MB-FREE.MB,TOTAL.MB)),NULL,'XXXXXXXXXXXXXXXXXXXX',NVL(RPAD(LPAD('X',TRUNC((100-ROUND( (TOTAL.MB_MAX - NVL(TOTAL.MB-FREE.MB,TOTAL.MB))/(TOTAL.MB_MAX) * 100, 2))/5),'X'),20,'-'),'--------------------'))||']' END AS GRAPH_MAX
FROM
      (SELECT /*+ PARALLEL(DBA_DATA_FILES,2) */ TABLESPACE_NAME TS, SUM(BYTES) MB, SUM(GREATEST(MAXBYTES, BYTES)) MB_MAX  FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME) TOTAL,
      (SELECT TABLESPACE_NAME TS, SUM(BYTES) MB FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME) FREE,
      DBA_TABLESPACES DBAT
WHERE TOTAL.TS = FREE.TS(+) 
  AND TOTAL.TS = DBAT.TABLESPACE_NAME) z
  --and TOTAL.TS = 'SYSAUX'
order by z.PCT_USED_MAX desc 
/ 


 
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


