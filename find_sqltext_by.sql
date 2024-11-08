-- |----------------------------------------------------------------------------|
-- | Objetivo   : LOCALIZAR POR STRING SQID NA GV$SQL                           |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 05/10/2018                                                    |
-- | Exemplo    : @find_sqltext_by                                              |
-- | Arquivo    : find_sqltext_by.sql                                           |
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
COLUMN INST_ID          FORMAT 99      head "INST_ID|"
COLUMN execs            FORMAT 999999  head "EXECS|"
COLUMN LOADS            FORMAT 999999  head "LOADS|"
COLUMN CHEILD#          FORMAT 999999  head "CHEILD#|"
COLUMN PARSE_CALLS      FORMAT 999999  head "PARSE|CALLS"
COLUMN SQL_ID           FORMAT A13     head "SQL_ID|"
COLUMN sql_text         FORMAT A50     head "SQL_TEXT|"
COLUMN INV              FORMAT 999999  head "INVALI|DATIONS"
COLUMN L_VERSIONS       FORMAT 999999  head "LOADED|VERSIONS"
COLUMN OPEN_VERSIONS    FORMAT 999999  head "OPEN|VERSIONS"
COLUMN OBJECT_STATUS    FORMAT A08     head "OBJECT|STATUS"
COLUMN FIRST_LOAD_TIME  FORMAT A19     head "FIRST|LOAD_TIME"
COLUMN LAST_LOAD_TIME   FORMAT A19     head "LAST|LOAD_TIME"

ACCEPT sssql_txt  char   PROMPT 'ENTRE_COM_TEXTO_DO_SQL = '

SELECT INST_ID,SQL_ID, substr(sql_text,1,50) as sql_text, CHILD_NUMBER AS CHEILD#, executions execs,LOADS,PARSE_CALLS, INVALIDATIONS INV, LOADED_VERSIONS L_VERSIONS
      ,OPEN_VERSIONS, OBJECT_STATUS,FIRST_LOAD_TIME  AS FIRST_LOAD_TIME,   LAST_LOAD_TIME  AS LAST_LOAD_TIME
FROM   gv$sql
WHERE  INSTR(upper(sql_text), upper('&sssql_txt')) > 0
AND    INSTR(upper(sql_text), upper('PROCURA')) = 0 
AND    INSTR(upper(sql_text), upper('gv$sql'))  = 0
ORDER BY SQL_ID, INST_ID
/
UNDEF sssql_txt
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;
