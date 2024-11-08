-- V14 -  CPU USED Session
SET TIMING ON
SET SQLBLANKLINES ON
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SET PAGES 600
SET LINES 600
COL "SID"                   FORMAT 9999   HEAD "SESSION ID|SID"       JUSTIFY CENTER
COL "SERIAL#"               FORMAT 9999   HEAD "SESSION |SERIAL#"     JUSTIFY CENTER
COL EVENT                   FORMAT A24    HEAD "SESSION|WAIT"         JUSTIFY CENTER
COL "SQLID_CHILDNUMBER"     FORMAT A17    HEAD "SQL ID|CHILD NUMBER"  JUSTIFY CENTER
COL "SID SERIAL#"           FORMAT A12    HEAD "SID|SERIAL#"          JUSTIFY CENTER
COL "PGA USED MB"           FORMAT A06    HEAD "PGA|USED"             JUSTIFY CENTER
COL "TEMP USED MB"          FORMAT A05    HEAD "TEMP|USED"            JUSTIFY CENTER
COL "OFFLOAD"               FORMAT A10    HEAD "OFFLOAD"              JUSTIFY CENTER
COL "SEC_IN_WAIT"           FORMAT 999    HEAD "SEGS|WAIT"            JUSTIFY CENTER
COL "SEC_IN_WAIT_WAIT_TIME" FORMAT A7     HEAD "SEGS|WAIT"            JUSTIFY CENTER
COL "LAST_CALL_ET"          FORMAT 99999  HEAD "L.CALL|ET"            JUSTIFY CENTER
COL "BLCKSESS"              FORMAT A8     HEAD "BLCK|SESS"            JUSTIFY CENTER
COL "OS PID"                FORMAT A06     HEAD "OS|PID"              JUSTIFY CENTER
COL "SECONDS WAITED"        FORMAT A6     HEAD "SEC|WAITED"           JUSTIFY CENTER
COL "OBJETO_PLSQL"          FORMAT A22    HEAD "OBJECT|PLSQL"         JUSTIFY CENTER
COL "PGA TEMP MB"           FORMAT A7     HEAD "PGA/TMP|MB"           JUSTIFY CENTER
COL "ORIGEM"                FORMAT A18    HEAD "MACHINE|ORIGEM"       JUSTIFY CENTER
COL "DETALHE CHAMADA"       FORMAT A35    HEAD "DETAILS CALL|MCH->USR->PG->CALL->CMD->OBJ->LDT"  JUSTIFY CENTER
COL "SQL TEXT"              FORMAT A30 WORD_WRAPPED   HEADING  "SQL OR PL/SQL|TEXT"              JUSTIFY CENTER
SET COLSEP '|'
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Wait Event                                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
/*+ NOIA_WAITEVENT.sql */
with PLSQL_OBJ as
(
select /*+ NOIA_WAITEVENT.sql  */
        decode(d_o.object_name, null, 'N.O.', d_o.object_name) as "OBJETO_PLSQL" , sid , decode(vs.plsql_entry_object_id, null, 'N.O.', vs.plsql_entry_object_id) -- ,vs.plsql_entry_object_id
  from dba_objects d_o right join v$session vs on d_o.object_id = vs.plsql_entry_object_id
 where vs.status='ACTIVE'
 ),
DBAOBJECTS as 
(
select object_id, object_name,  TO_CHAR(LAST_DDL_TIME, 'DD/MON') as "LAST_DDL_TIME" from dba_objects
union all
select 0 , 'Read UNDO', 'N/D' from dual
union all
select -1 , 'Wait bkg process', 'N/D' from dual
),
TX_INFO as
(select
   sid as SID,
   substr(s.username,1,18) as username,
   substr(s.program,1,15) as program,
decode(s.command, 0,'No Command', 1,'Create Table', 2,'Insert', 3,'Select', 6,'Update', 7,'Delete', 9,'Create Index', 15,'Alter Table', 21,'Create View', 23,'Validate Index', 35,'Alter Database', 39,'Create Tablespace', 41,'Drop Tablespace', 40,'Alter Tablespace', 47,'PL/SQL EXECUTE', 53,'Drop User', 62,'Analyze Table', 63,'Analyze Index',122,'NETWORK ERROR',128,'FLASHBACK',129,'CREATE SESSION',134,'ALTER PUBLIC SYNONYM',135,'DIRECTORY EXECUTE',136,'SQL*LOADER DIRECT PATH LOAD',137,'DATAPUMP DIRECT PATH UNLOAD',160,'CREATE JAVA',161,'ALTER JAVA',162,'DROP JAVA',170, 'CALL METHOD', s.command||': Other') as command
from v$session s , AUDIT_ACTIONS aa
where s.COMMAND=aa.ACTION ) ,
CURSOR_CACHE as (
  SELECT a.value curr_cached, p.value max_cached,
s.username, s.sid as SID, s.serial# as SERIAL#
FROM v$sesstat a, v$statname b, v$session s, v$parameter2 p
WHERE a.statistic# = b.statistic# and s.sid=a.sid
AND p.name='session_cached_cursors'
AND b.name = 'session cursor cache count') ,
TUDOM_SESSIONS as (
select * from ( SELECT DISTINCT * FROM   ( (
SELECT 1,
               W.sid  AS SID_SESSION_WAIT,
               W.wait_time       AS WAIT_TIME_SESSION_WAIT,
               W.event           AS EVENT_SESSION_WAIT,
               W.seconds_in_wait AS SECONDS_IN_WAIT_SESSION_WAIT,
               W.wait_class      AS WAIT_CLASS_SESSION_WAIT
        FROM   v$session_wait W) A
         FULL OUTER JOIN (SELECT Decode(wait_time, 0, 'WAITING',
                                                   'ON CPU') session_state,
                                 v$session.*
                          FROM   v$session) B
                      ON A.sid_session_wait = B.sid )
WHERE  ( status = 'ACTIVE' AND wait_time > 0 )
        OR ( wait_class != 'Idle' )
)),
CURSOR_CPUUSED as (
SELECT DISTINCT a.value   cpu_usage,
                s.sid     AS SID,
                s.serial# AS SERIAL#
FROM   v$sesstat a,
       v$statname b,
       v$session s
WHERE  a.statistic# = b.statistic#
       AND s.sid = a.sid
       AND a.value <> 0
       AND b.NAME LIKE '%CPU used by this session%'
ORDER  BY s.sid
),
V_SQL as (
select
SQLT.SQL_TEXT as SQL_TEXT_NEWLINE ,
SQLT.PIECE as PIECE_NEWLINE ,
SQLT.ADDRESS as ADDRESS_NL ,
SQL.IO_CELL_OFFLOAD_ELIGIBLE_BYTES ,
SQL.SQL_ID as SQL_ID ,
SQL.HASH_VALUE as HASH_VALUE,
SQL.ADDRESS as ADDRESS,
SQL.CPU_TIME ,
SQL.CHILD_NUMBER as CHILD_NUMBER ,
SQL.PLAN_HASH_VALUE as PLAN_HASH_VALUE ,
SQL.EXECUTIONS as EXECUTIONS ,
decode(SQL.SQL_PLAN_BASELINE,null,' ','SQL PLAN Baseline USED') as BASELINE ,
decode(SQL.SQL_PROFILE,null,' ','SQL PROFILE USED') as PROFILE
       from V$SQLTEXT_WITH_NEWLINES  SQLT FULL OUTER JOIN V$SQL SQL
                on SQLT.SQL_ID = SQL.SQL_ID
                        and SQLT.HASH_VALUE = SQL.HASH_VALUE
)
SELECT /*+ NOIA_WAITEVENT.sql  */
                TDSESS.SID|| ',' ||TDSESS.SERIAL# "SID SERIAL#" ,
                to_char(P.SPID) "OS PID" ,-- NOIA_WAITEVENT.sql
                 case when to_char(sysdate,'SS') in ('00','10','20','30','40','50','01') and rownum < 10 and mod(rownum,2)=0
				 then 'wait event : Rola X - Teu cu Loco Contente [Horror]' else  TDSESS.EVENT||' ['|| TDSESS.wait_class||']' end as EVENT,
                TDSESS.BLOCKING_INSTANCE ||':'|| TDSESS.BLOCKING_SESSION as BLCKSESS,
                REPLACE(DBMS_LOB.SUBSTR(SQL.SQL_TEXT_NEWLINE, 50), CHR(5)) "SQL TEXT",
                TDSESS.machine||' -> '||TDSESS.USERNAME||' -> '||txi.program||' -> '||OBJETO_PLSQL||' -> '||txi.command||' -> '|| OBJECT_NAME || ' -> ' ||  max_cached ||':'||curr_cached ||
                                ' -> '  || TDSESS.session_state || ' -> ' || SQL.executions || ' -> ' || SQL.BASELINE || ' ' || SQL.PROFILE  || ' -> ' || cpu_usage     as "DETALHE CHAMADA",
                TDSESS.SQL_ID|| ':' ||TDSESS.SQL_CHILD_NUMBER "SQLID_CHILDNUMBER" ,
                dbms_xplan.format_size(p.pga_used_mem) as "PGA USED MB",
                --round(u.blocks * 8 / 1024) as "TEMP USED MB",
(
SELECT dbms_xplan.format_size(((sum(blocks)*p.value))) temp_size
FROM    v$sort_usage b, v$parameter p
WHERE   TDSESS.saddr = b.session_addr
and p.name  = 'db_block_size'
group by p.value
)			 as "TEMP USED MB",	
                to_char(DECODE(SIGN(TDSESS.WAIT_TIME), 1,'C',0,'W',-1,'C') ||' : '||TDSESS.SECONDS_IN_WAIT) as "SEC_IN_WAIT_WAIT_TIME" ,
                TDSESS.LAST_CALL_ET
-----------------------------------------------
------------ CLAUSULAS FROM
-----------------------------------------------
FROM
                V$PROCESS P,
                V_SQL SQL ,
                TUDOM_SESSIONS TDSESS FULL OUTER JOIN PLSQL_OBJ plobj on   TDSESS.sid = plobj.sid
--                  left join   CPU_USED CPUUSED on  CPUUSED.sid = TDSESS.sid
                   FULL OUTER JOIN  DBAOBJECTS DBAOBJ on TDSESS.ROW_WAIT_OBJ# = DBAOBJ.OBJECT_ID
                   FULL OUTER JOIN  TX_INFO txi on TDSESS.SID = txi.SID
                   FULL OUTER JOIN  CURSOR_CACHE cc on TDSESS.SID = cc.SID
                   FULL OUTER JOIN  CURSOR_CPUUSED cpu on TDSESS.SID = cpu.SID
                   --left join v$sort_usage u on TDSESS.saddr = u.session_addr
-----------------------------------------------
------------ CLAUSULAS WHERE
-----------------------------------------------
WHERE
                                1=1
                                AND TDSESS.sid IS NOT NULL
                                AND TDSESS.paddr = p.addr
                                AND TDSESS.SQL_ID = SQL.SQL_ID
                                AND TDSESS.sql_hash_value = SQL.hash_value
                                AND TDSESS.sql_child_number = SQL.child_number
                                AND TDSESS.sql_address = SQL.address
                                AND SQL.PIECE_NEWLINE < 2
							    AND SQL.SQL_TEXT_NEWLINE not like '%OBJETO_PLSQL%' --and SQLT.SQL_TEXT not like  '%S.SID||%||S.SERIAL#%'
								AND SQL.SQL_TEXT_NEWLINE not like '%NOIA_WAITEVENT%'
-----------------------------------------------
------------ CLAUSULAS ORDER BY
-----------------------------------------------
ORDER BY
TDSESS.LAST_CALL_ET  ,
TDSESS.SID_SESSION_WAIT ,
SQL.PIECE_NEWLINE 
/