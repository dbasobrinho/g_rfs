-- |----------------------------------------------------------------------------|
-- | Objetivo   : LOCALIZAR POR STRING SQID NA GV$SQL                           |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 05/10/2018                                                    |
-- | Exemplo    : @coe_findsql_cursor_sharing 'TEXT_SQL'                        |
-- | Arquivo    : coe_findsql_cursor_sharing.sql                                |
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
COLUMN INST_ID          FORMAT 9      head "I|"
COLUMN execs            FORMAT 999999  head "EXECS|"
COLUMN LOADS            FORMAT 999999  head "LOADS|"
COLUMN CHILD#           FORMAT 999999  head "CHILD#|"
COLUMN PARSE_CALLS      FORMAT 999999  head "PARSE|CALLS"
COLUMN SQL_ID           FORMAT A13     head "SQL_ID|"
COLUMN sql_text         FORMAT A40     word_wrapped head "SQL_TEXT|"
COLUMN INV              FORMAT 9999     head "INV"
COLUMN L_VERSIONS       FORMAT 999999  head "LOADED|VERSIONS"
COLUMN OPEN_VERSIONS    FORMAT 99999  head "OPEN|VERS"
COLUMN HASH_VALUE       FORMAT 9999999999  head "HASH|VALUE"
COLUMN PLAN_HASH_VALUE  FORMAT 9999999999  head "PLAN|HASH_VALUE"
COLUMN OBJECT_STATUS    FORMAT A08     head "OBJECT|STATUS"
COLUMN FIRST_LOAD_TIME  FORMAT A19     head "FIRST|LOAD_TIME"
COLUMN LAST_LOAD_TIME   FORMAT A19     head "LAST|LOAD_TIME"
col IS_bind_sensitive   format a10  HEADING 'IS_BIND|SENSITIVE' JUSTIFY CENTER
col IS_BIND_AWARE       format a10  HEADING 'IS_BIND|AWARE'     JUSTIFY CENTER
col IS_SHAREABLE        format a10  HEADING 'IS|SHAREABLE'       JUSTIFY CENTER
col bind_mismatch       format a10  HEADING 'BIND|MISMATCH'       JUSTIFY CENTER
set verify on
--ACCEPT sssql_txt  char   PROMPT 'ENTRE_COM_TEXTO_DO_SQL = '
SELECT a.is_bind_sensitive, a.IS_BIND_AWARE, a.IS_SHAREABLE, b.bind_mismatch, 
       a.INST_ID,a.SQL_ID, substr(a.sql_text,1,40) as sql_text,a.HASH_VALUE,a.PLAN_HASH_VALUE, a.CHILD_NUMBER AS CHILD#, executions execs,LOADS,PARSE_CALLS, INVALIDATIONS INV, LOADED_VERSIONS L_VERSIONS
      ,OPEN_VERSIONS--, OBJECT_STATUS,FIRST_LOAD_TIME  AS FIRST_LOAD_TIME,   LAST_LOAD_TIME  AS LAST_LOAD_TIME
FROM   gv$sql a, gv$sql_shared_cursor b
WHERE  INSTR(upper(a.sql_text), upper('&1')) > 0
AND    INSTR(upper(a.sql_text), upper('EXPLAIN PLAN')) = 0 
AND    INSTR(upper(a.sql_text), upper('gv$sql'))  = 0
and a.INST_ID = b.INST_ID
and a.child_number = b.child_number
and a.sql_id = b.sql_id
ORDER BY SQL_ID, INST_ID
/
UNDEF 1
UNDEF sqltxt
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;