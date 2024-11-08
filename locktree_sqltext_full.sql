-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_lock_tree.sql                                              |
-- | CLASS    :                                                                 |
-- | PURPOSE  :                                                                 |
-- | NOTE     :                                                                 |
-- |                                                                            |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessoes em Locked Tree                                      |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    500
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

set lines 400
set pages 100
COLUMN level        FORMAT 999
COLUMN username     FORMAT A10
COLUMN osuser       FORMAT A20
COLUMN "SID/SERIAL" FORMAT A10
COLUMN block_sid    FORMAT 999  HEADING 'BLOCK|SID'
COLUMN lockwait     FORMAT 999
COLUMN status       FORMAT A8
COLUMN module       FORMAT A25
COLUMN machine      FORMAT A25
COLUMN program      FORMAT A25
COLUMN logon_time   FORMAT A20
COLUMN last_call_et    for 99999 HEADING 'LAST|CALL_ET'
COLUMN seconds_in_wait for 99999 HEADING 'SECONDS|IN_WAIT'
COLUMN SessionWait for A30 HEADING 'EVENT|WAIT'
COLUMN sql_fulltext for A68 HEADING 'SQL_FULLTEXT'

SELECT level,
       LPAD(' ', (level-1)*2, ' ') || NVL(s.username, '(oracle)') AS username,
       --s.osuser,
       s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  "SID/SERIAL",
      -- s.blocking_session block_sid,
       --s.status,
       --s.module,
       --s.machine,
       --s.program,
       --TO_CHAR(s.logon_Time,'DD/MM/YYYY HH24:MI:SS') AS logon_time,
       SUBSTR((select trim(substr(event,4,100)) from v$session_wait where sid = s.sid),1,30) SessionWait,
       s.prev_sql_id,
       s.sql_id,
       s.seconds_in_wait,
       (select (sql_fulltext)
         from v$sql
        where sql_id = nvl(s.sql_id,s.prev_sql_id) and sql_fulltext is not null and rownum =1 ) as sql_fulltext
FROM   gv$session s
WHERE  level > 1
OR     EXISTS (SELECT 1
               FROM   v$session
               WHERE  blocking_session = s.sid)
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL;

SET PAGESIZE 14
