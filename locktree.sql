-- |----------------------------------------------------------------------------|
-- | Objetivo   : Active Locked Tree                                            |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 25/10/2018                                                    |
-- | Exemplo    : @locktree                                                     |
-- | Arquivo    : locktree.sql                                                  |
-- | Modificacao: 2.0 Dei uma arrumada, aproveitando que ta SOL                 |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Active Locked Tree                  +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT
SET ECHO        OFF
SET FEEDBACK    6
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
set lines 600
set pages 300
COLUMN level        FORMAT 9999 HEADING 'LEVEL|-'  JUSTIFY CENTER
COLUMN username     FORMAT A18 HEADING 'USERNAME|-'  JUSTIFY CENTER
COLUMN osuser       FORMAT A20 HEADING 'OSUSER|-' JUSTIFY CENTER
COLUMN SID_SERIAL   FORMAT A14 HEADING 'SID/SERIAL|-' JUSTIFY CENTER
COLUMN block_sid    FORMAT A10 HEADING 'SID/BLOCK|-' JUSTIFY CENTER
COLUMN status       FORMAT A8  HEADING 'STATUS|-' JUSTIFY CENTER
COLUMN sql_id       FORMAT A13 HEADING 'SQLID|-' JUSTIFY CENTER  
COLUMN prev_sql_id  FORMAT A13 HEADING 'SQLID PREV|-' JUSTIFY CENTER 
COLUMN program      FORMAT A25 JUSTIFY CENTER
COLUMN logon_time   FORMAT A15 HEADING 'LOGON TIME|-' JUSTIFY CENTER
COLUMN last_call_et    for 99999999 HEADING 'LAST|CALL_ET' JUSTIFY CENTER
COLUMN seconds_in_wait for 99999999 HEADING 'SECONDS|IN_WAIT' JUSTIFY CENTER
COLUMN SessionWait for A30 HEADING 'EVENT WAIT|-' JUSTIFY CENTER
SET COLSEP '|'
SELECT level,
       LPAD(' ', (level-1)*2, ' ') || NVL(s.username, '(oracle)') AS username,
       s.osuser,
       s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  SID_SERIAL,
       s.blocking_session||nvl2(s.blocking_session,',@',' ')||BLOCKING_INSTANCE block_sid,
       s.status,
       TO_CHAR(s.logon_Time,'DDMMYY HH24:MI:SS') AS logon_time,
       SUBSTR((select trim(substr(event,1,100)) from gv$session_wait where sid = s.sid and inst_id = s.inst_id),1,30) SessionWait,
       s.prev_sql_id,
       s.sql_id,
       s.last_call_et,
       s.seconds_in_wait
FROM   gv$session s
WHERE  level > 1
OR     EXISTS (SELECT 1
               FROM   gv$session
               WHERE  blocking_session = s.sid and BLOCKING_INSTANCE =  s.inst_id)
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL
/
