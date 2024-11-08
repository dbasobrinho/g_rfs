-- |----------------------------------------------------------------------------|
-- | Objetivo   : Active Locked Tree com Rowid                                  |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 17/03/2021                                                    |
-- | Exemplo    : @locktreef                                                    |
-- | Arquivo    : locktreef.sql                                                 |
-- | Modificacao: 2.0 Dei uma arrumada, aproveitando que ta SOL                 |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
alter session force parallel dml parallel   15;
alter session force parallel query parallel 15;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Active Locked Tree ROWID            +-+-+-+-+-+-+-+-+-+-+   |
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
COLUMN osuser       FORMAT A10 HEADING 'OSUSER|-' JUSTIFY CENTER
COLUMN SID_SERIAL   FORMAT A14 HEADING 'SID/SERIAL|-' JUSTIFY CENTER
COLUMN block_sid    FORMAT A10 HEADING 'SID/BLOCK|-' JUSTIFY CENTER
COLUMN status       FORMAT A8  HEADING 'STATUS|-' JUSTIFY CENTER
COLUMN sql_id       FORMAT A13 HEADING 'SQLID|-' JUSTIFY CENTER  
COLUMN prev_sql_id  FORMAT A13 HEADING 'SQLID PREV|-' JUSTIFY CENTER 
COLUMN program      FORMAT A25 JUSTIFY CENTER
COLUMN logon_time   FORMAT A15 HEADING 'LOGON TIME|-' JUSTIFY CENTER
COLUMN last_call_et    for 99999999 HEADING 'LAST|CALL_ET' JUSTIFY CENTER
COLUMN seconds_in_wait for 99999999 HEADING 'SECONDS|IN_WAIT' JUSTIFY CENTER
COLUMN SessionWait for A15 HEADING 'EVENT WAIT|-' JUSTIFY CENTER
COLUMN ROW_LOCK    for A100 HEADING 'OBJECT|ROWID LOCKED'
SET COLSEP '|'

select --z.level,z.username, z.osuser,  --z.SID_SERIAL, z.status, z.SessionWait, z.sql_id, z.seconds_in_wait,
z.*, (select o.OBJECT_TYPE||'>>'||o.OWNER||'.'||o.object_name||'>>'|| dbms_rowid.rowid_create ( 1, o.DATA_OBJECT_ID, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# )
  from gv$session   s, dba_objects o 
where s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end = '987,21037,@1'
and s.ROW_WAIT_OBJ# = o.OBJECT_ID) row_lock
from(
SELECT level,
       LPAD(' ', (level-1)*2, ' ') || NVL(s.username, '(oracle)') AS username,
       SUBSTR(s.osuser,1,10) osuser,
       s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  SID_SERIAL,
     --  s.blocking_session||nvl2(s.blocking_session,',@',' ')||BLOCKING_INSTANCE block_sid,
       s.status,
     --  TO_CHAR(s.logon_Time,'DDMMYY HH24:MI:SS') AS logon_time,
       SUBSTR((select trim(substr(event,1,100)) from gv$session_wait where sid = s.sid and inst_id = s.inst_id),1,15) SessionWait,
    --   s.prev_sql_id,
       s.sql_id,
      -- s.last_call_et,
       s.seconds_in_wait
FROM   gv$session s
WHERE  level > 1
OR     EXISTS (SELECT 1
               FROM   gv$session
               WHERE  blocking_session = s.sid and BLOCKING_INSTANCE =  s.inst_id)
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL) z
/
------alter session force parallel dml parallel   15;
------alter session force parallel query parallel 15;
------SELECT /*+  PARALLEL(flashback_transaction_query, 35) */ xid, operation, TO_CHAR(start_scn) AS start_scn ,  TO_CHAR(commit_scn) commit_scn, SUBSTR(logon_user, 1,12) logon_user,
--------undo_sql, 
------SUBSTR(TABLE_OWNER||'.'||TABLE_OWNER,1,40) as TBLE, ROW_ID, UNDO_CHANGE# UNDO_SEQ, START_TIMESTAMP
------FROM   flashback_transaction_query
------WHERE  commit_scn is null
------and  START_TIMESTAMP > SYSDATE -1/24 and ROW_ID = 'AADsd1ACSAACITcAAI'
--------xid = HEXTORAW('&&XID')
------ORDER BY UNDO_SEQ DESC
------/
rem clear columns
UNDEFINE v_sees
SET FEEDBACK on
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT
