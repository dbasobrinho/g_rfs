COLUMN user_name       FORMAT a12
COLUMN ddl_date        FORMAT a17
COLUMN ddl_type        FORMAT a10
COLUMN object_type     FORMAT a17
COLUMN object_name     FORMAT a30
COLUMN osuser          FORMAT a12
COLUMN terminal        FORMAT a15
COLUMN program         FORMAT a25
COLUMN ipadress        FORMAT a15
COLUMN SQL_ID          FORMAT a16

SET TERMOUT OFF;
SET ECHO        OFF
set timing      OFF
set time       OFF
SET UNDERLINE   	'-'
SET COLSEP      '|'
SET FEEDBACK    OFF
SET SQLBLANKLINES ON
set linesize 200
set verify   off
set pagesize 999
alter session set nls_territory='portugal';
alter session set nls_language='portuguese';
--set markup html on entmap on spool on preformat off
--spool coleta.xls
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
SET TERMOUT ON;
---ACCEPT ENTER_MINUTOS CHAR FORMAT 'A20' DEFAULT '2' PROMPT 'QTDE MINUTOS [2]:  '
PROMPT
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : LISTA USUARIOS DBA/SYSDBA             +-+-+-+-+-+-+-+-+-+-+ |
PROMPT | Instance : &current_instance                     |r|f|s|o|b|r|i|n|h|o| |
PROMPT | Version  : 1.0                                   +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+

select to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss') data_coleta, instance_name, host_name  from v$instance
/
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | +-+-+-+-+-+-+-+-+-+-+      USERS DBA/SYSDBA      +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
select 'GRANT DBA' TIPO, b.username, b.ACCOUNT_STATUS from dba_role_privs a, dba_users b
 where granted_role='DBA'
 and a.GRANTEE = b.username
 --and b.username not in ('OERR','SYSMAN','DBLINK_ORACLE','TVTSPI','DBSNMP','ADVISOR','OPS$ORACLE')
UNION ALL
select 'GRANT SYSDBA' TIPO,  b.username, b.ACCOUNT_STATUS from v$pwfile_users a, dba_users b
 where a.USERNAME = b.username
ORDER BY 2
/
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | +-+-+-+-+-+-+-+-+-+-+     EVENTOS AUDITADOS      +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
SELECT COUNT(*) QTDE, Y.*
FROM (
select a.DB_USER user_name, a.OS_USER osuser, substr(a.ddl_type,1,10)ddl_type,  substr(a.program,1, 25) program,substr(a.terminal,1, 15) terminal, TO_CHAR(SUBSTR(SQL_TEXT,1,10)) SQL_TEXT10
from ddl_log a
where a.DB_USER  IN (
SELECT DISTINCT username
FROM 
(
select  b.username from dba_role_privs a, dba_users b
 where granted_role='DBA'
 and a.GRANTEE = b.username
 and b.username not in ('SYSMAN','DBLINK_ORACLE','TVTSPI','DBSNMP','ADVISOR')
UNION ALL
select b.username from v$pwfile_users a, dba_users b
 where a.USERNAME = b.username
 ) Z
))Y
GROUP BY user_name , osuser , ddl_type,  program ,terminal , SQL_TEXT10
order by QTDE desc
/

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | +-+-+-+-+-+-+-+-+-+-+ EVENTOS AUDITADOS DETALHADO+-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
select to_char(a.ddl_date, 'dd/mm/yy hh24:mi:ss')ddl_date, substr(a.DB_USER,1, 12) user_name, substr(a.OS_USER,1, 12) osuser,
substr(a.ddl_type,1,10)ddl_type, substr(a.OBJ_TYPE,1, 17)object_type,
substr(a.OBJ_OWNER||'.'||a.OBJ_NAME,1, 30) object_name,
substr(a.terminal,1, 15) terminal, substr(a.program,1, 25) program
from ddl_log a
where a.DB_USER  in(
SELECT DISTINCT username
FROM 
(
select  b.username from dba_role_privs a, dba_users b
 where granted_role='DBA'
 and a.GRANTEE = b.username
 --and b.username not in ('SYSMAN','DBLINK_ORACLE','TVTSPI','DBSNMP','ADVISOR')
UNION ALL
select b.username from v$pwfile_users a, dba_users b
 where a.USERNAME = b.username
 ) Z
)
order by a.ddl_date desc
/

COLUMN PRIV_DATE       FORMAT a19
COLUMN PRIV_NAME       FORMAT a08   HEADING 'PRIV'
COLUMN PRIVILEGE       FORMAT a25
COLUMN OBJECT_OWNER    FORMAT a12
COLUMN OBJECT_NAME     FORMAT a30
COLUMN PRIV_TO_USER    FORMAT a13
COLUMN USER_NAME       FORMAT a13
COLUMN OSUSER          FORMAT a13
COLUMN OSUSER          FORMAT a13
COLUMN terminal        FORMAT a15
COLUMN program         FORMAT a18
COLUMN ipadress        FORMAT a15
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | +-+-+-+-+-+-+-+-+-+-+EVENTOS AUDITADOS PRIVILEGIO+-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
 select
  TO_CHAR(PRIV_DATE,'DD/MM/YYYY HH24:MI:SS')  AS PRIV_DATE
 ,OSUSER
 ,USER_NAME
 ,PRIV_NAME
 ,PRIVILEGE
 ,OBJECT_OWNER
 ,OBJECT_NAME
 ,PRIV_TO_USER
 ,substr(a.terminal,1, 15) terminal
 ,substr(a.program ,1, 18) program
 from DDL_LOG_PRIV a
 where USER_NAME <>  'SYS'
 and USER_NAME in(
 SELECT DISTINCT username
FROM 
(
select  b.username from dba_role_privs a, dba_users b
 where granted_role='DBA'
 and a.GRANTEE = b.username
 --and b.username not in ('SYSMAN','DBLINK_ORACLE','TVTSPI','DBSNMP','ADVISOR')
UNION ALL
select b.username from v$pwfile_users a, dba_users b
 where a.USERNAME = b.username
 ) Z
 )
 order by a.PRIV_DATE desc, OBJECT_OWNER, PRIV_TO_USER
 /
create table tvtspi.XXX AS SELECT * FROM DBA_USERS
/
drop table  tvtspi.XXX
/
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT     O GUINA NAO TINHA DÓ, SE REGIR, BUMMM! VIRA PÓ . . . 

set markup html off entmap off spool off preformat on

