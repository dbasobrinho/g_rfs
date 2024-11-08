-- |----------------------------------------------------------------------------|
-- | Objetivo   : LOCALIZAR POR STRING SQID NA GV$SQL                           |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 05/10/2018                                                    |
-- | Exemplo    : @findsql.sql                                                  |
-- | Arquivo    : findsql.sql                                                   |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Localizar SQLID pelo TEXTO [gv$sql] +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.1                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    on
SET HEADING     ON
SET LINES       10000
SET PAGES       10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a17  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a20
col logon_time   format a10
col hold         format a06
col sessionwait  format a25
col status       format a08
col hash_value   format a10
col sc_wait      format a06 HEADING 'WAIT'
col module       format a08 HEADING 'MODULE'
SET COLSEP '|'
COLUMN INST_ID          FORMAT 9      head " I|"                     JUSTIFY CENTER
COLUMN execs            FORMAT 999999  head "EXECS|"                JUSTIFY CENTER
COLUMN LOADS            FORMAT 999999  head "LOADS|"                JUSTIFY CENTER
COLUMN CHILD#          FORMAT 999999  head "CHILD#|"                JUSTIFY CENTER
COLUMN PARSE_CALLS      FORMAT 999999  head "PARSE|CALLS"           JUSTIFY CENTER
COLUMN SQL_ID           FORMAT A13     head "SQL_ID|"               JUSTIFY CENTER
COLUMN sql_text         FORMAT A40      head "SQL_TEXT|"            JUSTIFY CENTER
COLUMN INV              FORMAT 9999     head " INV|"                  JUSTIFY CENTER
COLUMN L_VERSIONS       FORMAT 999999  head "LOADED|VERSIONS"       JUSTIFY CENTER
COLUMN OPEN_VERSIONS    FORMAT 99999  head "OPEN|VERS"              JUSTIFY CENTER
COLUMN HASH_VALUE       FORMAT 9999999999  head "HASH|VALUE"        JUSTIFY CENTER
COLUMN PLAN_HASH_VALUE  FORMAT 9999999999  head "PLAN|HASH_VALUE"   JUSTIFY CENTER
COLUMN OBJECT_STATUS    FORMAT A08     head "OBJECT|STATUS"         JUSTIFY CENTER
COLUMN FIRST_LOAD_TIME  FORMAT A19     head "FIRST|LOAD_TIME"       JUSTIFY CENTER
COLUMN LAST_LOAD_TIME   FORMAT A19     head "LAST|LOAD_TIME"        JUSTIFY CENTER
col IS_bind_sensitive   format a10  HEADING 'IS_BIND|SENSITIVE'     JUSTIFY CENTER
col IS_BIND_AWARE       format a10  HEADING 'IS_BIND|AWARE'         JUSTIFY CENTER
col IS_SHAREABLE        format a10  HEADING 'IS|SHAREABLE'          JUSTIFY CENTER
set verify on
--ACCEPT sssql_txt  char   PROMPT 'ENTRE_COM_TEXTO_DO_SQL = '
SELECT --is_bind_sensitive, IS_BIND_AWARE, IS_SHAREABLE,
       INST_ID,SQL_ID, substr(sql_text,1,40) as sql_text,HASH_VALUE,PLAN_HASH_VALUE, CHILD_NUMBER AS CHILD#, executions execs,LOADS,PARSE_CALLS, INVALIDATIONS INV, LOADED_VERSIONS L_VERSIONS
      ,OPEN_VERSIONS, substr(OBJECT_STATUS,1,8) OBJECT_STATUS ,FIRST_LOAD_TIME  AS FIRST_LOAD_TIME,   LAST_LOAD_TIME  AS LAST_LOAD_TIME
FROM   gv$sql 
WHERE  INSTR(upper(sql_text), upper('&1')) > 0
AND    INSTR(upper(sql_text), upper('EXPLAIN PLAN')) = 0
AND    INSTR(upper(sql_text), upper('/* SQL ANALYZE(')) = 0
AND    INSTR(upper(sql_text), upper('v$sql'))  = 0
ORDER BY SQL_ID,CHILD_NUMBER, INST_ID
/
UNDEF 1
UNDEF sqltxt
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;