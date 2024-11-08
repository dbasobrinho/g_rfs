-- |----------------------------------------------------------------------------|
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessoes Lock History                                        |
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
COLUMN sql_id            FORMAT 9999
COLUMN inst_id           FORMAT 9999
COLUMN blocking_session  FORMAT 9999
COLUMN blocking_serial   FORMAT 9999
COLUMN user_id           FORMAT 9999 
COLUMN sql_text          FORMAT A200
COLUMN module            FORMAT A25
COLUMN last_call_et    for 99999 HEADING 'LAST|CALL_ET'
COLUMN seconds_in_wait for 99999 HEADING 'SECONDS|IN_WAIT'
COLUMN SessionWait for A30 HEADING 'EVENT|WAIT'

SELECT distinct a.sql_id
               ,a.inst_id
               ,a.blocking_session
               ,a.blocking_session_serial# blocking_serial
               ,a.user_id
               ,a.module
               ,s.sql_text
  FROM GV$ACTIVE_SESSION_history a
      ,gv$sql                    s
 where a.sql_id = s.sql_id
   and blocking_session is not null
   and a.user_id <> 0 
   and a.sample_time > sysdate - 7
/

SET PAGESIZE 14
