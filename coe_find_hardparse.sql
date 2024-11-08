-- |----------------------------------------------------------------------------|
-- | Objetivo   : ANALISAR HARD PARSE                                           |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 21/02/2021                                                    |
-- | Exemplo    : @coe_find_hardparse 1                                         |
-- | Arquivo    : find_hardparse.sql                                            |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual; 
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Locate HardParse                    +-+-+-+-+-+-+-+-+-+-+   |
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
COLUMN CHEILD#          FORMAT 999999  head "CHEILD#|"
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
COLUMN name             FORMAT A30     head "NAME"
COLUMN username         FORMAT A20     head "USERNAME"
COLUMN value            FORMAT 99999999999   
COLUMN tot              FORMAT 99999999999  
--set define '&'
set verify off
--define cnt=&1
PROMPT
PROMPT
PROMPT +------------------------------------------------------------------------+ 
PROMPT | Quantidade HardParses em [v$statname, v$mystat]                        |
PROMPT +------------------------------------------------------------------------+

select s.name, m.value
 from   v$statname s, v$mystat m
 where  s.statistic# = m.statistic#
 and    s.name like 'parse%(%'
/ 
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Entre com a quantidade [count(distinct(sql_id)) > :1]                  |
PROMPT +------------------------------------------------------------------------+
select u.username ,  PLAN_HASH_VALUE, count(distinct(sql_id)) tot
from   gv$sql, dba_users u
where PLAN_HASH_VALUE > 0
and PARSING_USER_ID = u.USER_ID and u.USER_ID <> 0
group by PLAN_HASH_VALUE, u.username
having count(distinct(sql_id)) > &1
order by tot
/
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Entre com a PLAN_HASH_VALUE para detalhes                              |
PROMPT +------------------------------------------------------------------------+
SELECT u.username, INST_ID,SQL_ID, substr(sql_text,1,40) as sql_text,HASH_VALUE,PLAN_HASH_VALUE, CHILD_NUMBER AS CHEILD#, executions execs,LOADS,PARSE_CALLS, INVALIDATIONS INV, LOADED_VERSIONS L_VERSIONS
      ,OPEN_VERSIONS, OBJECT_STATUS --,/*FIRST_LOAD_TIME  AS FIRST_LOAD_TIME,*/   LAST_LOAD_TIME  AS LAST_LOAD_TIME
FROM   gv$sql, dba_users u
WHERE  PLAN_HASH_VALUE = &PLAN_HASH_VALUE
and PARSING_USER_ID = u.USER_ID 
ORDER BY SQL_ID,sql_text, INST_ID
/




