-- V12
SET TIMING ON
SET SQLBLANKLINES ON
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SET PAGES 400
SET LINES 400
COL "SID"                   FORMAT 9999   HEAD "SESSION ID|SID"       JUSTIFY CENTER
COL "SERIAL#"               FORMAT 9999   HEAD "SESSION |SERIAL#"     JUSTIFY CENTER
COL EVENT                   FORMAT A24    HEAD "SESSION|WAIT"         JUSTIFY CENTER
COL "SQLID_CHILDNUMBER"     FORMAT A17    HEAD "SQL ID|CHILD NUMBER"  JUSTIFY CENTER
COL "SID SERIAL#"           FORMAT A11    HEAD "SID|SERIAL#"          JUSTIFY CENTER
COL "PGA USED MB"           FORMAT 99999  HEAD "PGA|MB"               JUSTIFY CENTER
COL "TEMP USED MB"          FORMAT 99999  HEAD "TEMP|MB"              JUSTIFY CENTER
COL "OFFLOAD"               FORMAT A10    HEAD "OFFLOAD"              JUSTIFY CENTER
COL "SEC_IN_WAIT"           FORMAT 999    HEAD "SEGS|WAIT"            JUSTIFY CENTER
COL "SEC_IN_WAIT_WAIT_TIME" FORMAT A7     HEAD "SEGS|WAIT"            JUSTIFY CENTER
COL "LAST_CALL_ET"          FORMAT 99999  HEAD "L.CALL|ET"            JUSTIFY CENTER
COL "BLCKSESS"              FORMAT A8     HEAD "BLCK|SESS"            JUSTIFY CENTER
COL "OS PID"                FORMAT A5     HEAD "OS|PID"               JUSTIFY CENTER
COL "SECONDS WAITED"        FORMAT A6     HEAD "SEC|WAITED"           JUSTIFY CENTER
COL "OBJETO_PLSQL"          FORMAT A22    HEAD "OBJECT|PLSQL"         JUSTIFY CENTER
COL "PGA TEMP MB"           FORMAT A7     HEAD "PGA/TMP|MB"           JUSTIFY CENTER
COL "ORIGEM"                FORMAT A18    HEAD "MACHINE|ORIGEM"       JUSTIFY CENTER
COL "DETALHE CHAMADA"       FORMAT A35    HEAD "DETAILS CALL|MCH->USR->PG->CALL->CMD->OBJ->LDT"  JUSTIFY CENTER
COL "SQL TEXT"              FORMAT A30 WORD_WRAPPED   HEADING  "SQL OR PL/SQL|TEXT"              JUSTIFY CENTER
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Wait Event                                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
/* NOIA WAITEVENT.sql */  with PLSQL_OBJ as
(select       /* NOIA WAITEVENT.sql   */
decode(d_o.object_name, null, 'N.O.', d_o.object_name) as "OBJETO_PLSQL" ,
        sid , decode(vs.plsql_entry_object_id, null, 'N.O.', vs.plsql_entry_object_id) 
from dba_objects d_o right join v$session vs on d_o.object_id = vs.plsql_entry_object_id
where vs.status='ACTIVE'),
DBAOBJECTS as (
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
AND b.name = 'session cursor cache count')
SELECT /* WAITEVENT.sql */
		  S.SID|| ',' ||S.SERIAL# "SID SERIAL#" ,
                to_char(P.SPID) "OS PID" ,
                substr(W.EVENT,1,24) EVENT,
                S.BLOCKING_INSTANCE ||':'|| S.BLOCKING_SESSION as BLCKSESS,
                REPLACE(DBMS_LOB.SUBSTR(SQLT.SQL_TEXT, 30), CHR(5)) "SQL TEXT",
                machine||' -> '||s.USERNAME||' -> '||txi.program||' -> '||OBJETO_PLSQL||' -> '||txi.command||' -> '|| OBJECT_NAME || ' -> ' ||  LAST_DDL_TIME || ' -> ' || max_cached ||':'||curr_cached      as "DETALHE CHAMADA",
                S.SQL_ID|| ':' ||S.SQL_CHILD_NUMBER "SQLID_CHILDNUMBER" ,
                ROUND(p.pga_used_mem/(1024*1024), 2) as "PGA USED MB",
                round(u.blocks * 8 / 1024) as "TEMP USED MB",
		  to_char(DECODE(SIGN(W.WAIT_TIME), 1,'C',0,'W',-1,'C') ||' : '||W.SECONDS_IN_WAIT) as "SEC_IN_WAIT_WAIT_TIME" ,
                LAST_CALL_ET
               --,decode(SQL.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload
-----------------------------------------------
------------ CLAUSULAS FROM
-----------------------------------------------
FROM            V$SESSION_WAIT W,
                V$PROCESS P,
--				V$SQLTEXT SQLT ,
	         V$SQLTEXT_WITH_NEWLINES  SQLT ,
                V$SQL SQL,
                v$session_event SE, PLSQL_OBJ plobj,
                V$SESSION S left join v$sort_usage u on s.saddr = u.session_addr,                -- COM TEMP
                DBAOBJECTS DBAOBJ,
		  TX_INFO txi,
                CURSOR_CACHE cc
--				V$SESSION S                             -- SEM TEMP 
-----------------------------------------------
------------ CLAUSULAS WHERE
-----------------------------------------------
WHERE
        S.PADDR = P.ADDR                                                                    -- Cruzamento V$SESSION x V$PROCESS
        AND (SE.SID = S.SID and SE.SID = W.SID and W.SID = S.SID)                           -- Cruzamento V$SESSION_EVENT x V$SESSION x V$SESSION_WAIT
        AND (plobj.SID = S.SID and plobj.SID = W.SID and plobj.SID = SE.SID)                -- Cruzamento V$SESSION_EVENT, V$SESSION, V$SESSION_WAIT  x  QUERY WITH PLSQL_OBJ
        AND (SQLT.SQL_ID = SQL.SQL_ID and SQLT.HASH_VALUE = SQL.HASH_VALUE)                                             -- Cruzamento V$SQLTEXT x V$SQL
        AND (S.SQL_ID = SQL.SQL_ID and S.SQL_HASH_VALUE = SQL.HASH_VALUE and S.SQL_CHILD_NUMBER = SQL.CHILD_NUMBER)     -- Cruzamento V$SESSION x V$SQL
        AND (SQLT.SQL_ID = S.SQL_ID and SQLT.HASH_VALUE = S.SQL_HASH_VALUE and SQLT.ADDRESS = S.SQL_ADDRESS)            -- Cruzamento V$SQLTEXT x V$SESSION
        AND (SQLT.ADDRESS = S.SQL_ADDRESS and SQL.ADDRESS = S.SQL_ADDRESS and SQLT.ADDRESS = SQL.ADDRESS)
        AND (SQLT.HASH_VALUE = S.SQL_HASH_VALUE and SQL.HASH_VALUE = S.SQL_HASH_VALUE and SQLT.HASH_VALUE = SQL.HASH_VALUE)
        AND (SQLT.SQL_ID = S.SQL_ID and SQLT.HASH_VALUE = S.SQL_HASH_VALUE and SQLT.ADDRESS = S.SQL_ADDRESS)
        AND (SE.EVENT=W.EVENT)
        AND (W.WAIT_CLASS=SE.WAIT_CLASS AND W.WAIT_CLASS != 'Idle' AND SE.WAIT_CLASS != 'Idle')
        AND (S.ROW_WAIT_OBJ# = DBAOBJ.OBJECT_ID)
        AND (TXI.SID=PLOBJ.SID AND TXI.SID=W.SID AND TXI.SID=SE.SID AND TXI.SID=S.SID)
        AND (CC.SID=SE.SID AND CC.SID=S.SID AND CC.SID=W.SID AND plobj.SID=CC.SID)
        AND SQLT.PIECE < 1    -- Pedaco query
--------
--      AND S.PROGRAM='sqlplus@lnxorasp11 (TNS V1-V3)' --'SQL Developer' -- 'w3wp.exe'
--      AND W.SID=4                                         -- <<<<< Especificar SID
--      AND S.SQL_ID='4ywmu3bf4pkb2'                        -- <<<<< Especificar SQL_ID
      AND SQLT.SQL_TEXT not like '%NOIA WAITEVENT.sql%' --and SQLT.SQL_TEXT not like  '%S.SID||%||S.SERIAL#%'
---------
ORDER BY
S.LAST_CALL_ET  , W.SID , SQLT.PIECE
/


