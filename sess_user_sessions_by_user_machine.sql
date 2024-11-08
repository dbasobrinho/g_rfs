-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_user_sessions_by_user_machine.sql                          |
-- | CLASS    : Session Management                                              | 
-- | PURPOSE  : Report on all User Sessions.                                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : User Sessions Summary Report by user and machine            |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN max_sess_allowed  FORMAT 9,999,999       JUSTIFY r HEADING 'Max sessions allowed'
COLUMN max_proce_allowed FORMAT 9,999,999       JUSTIFY r HEADING 'Max processes allowed'
COLUMN num_sessions      FORMAT 9,999,999,999   JUSTIFY r HEADING 'Number of sessions'
COLUMN num_processes     FORMAT 9,999,999,999   JUSTIFY r HEADING 'Number of processes'
COLUMN pct_utl           FORMAT a19             JUSTIFY r HEADING 'Percent Utilization'
COLUMN username          FORMAT a20             JUSTIFY r HEADING 'Oracle User'
COLUMN machine           FORMAT a30             JUSTIFY r HEADING 'Machine'
COLUMN num_user_sess     FORMAT 9,999,999       JUSTIFY r HEADING 'Number of Logins'
COLUMN num_user_proc     FORMAT 9,999,999       JUSTIFY r HEADING 'Number of Processes'
COLUMN count_a           FORMAT 9,999,999       JUSTIFY r HEADING 'Active Logins'
COLUMN count_i           FORMAT 9,999,999       JUSTIFY r HEADING 'Inactive Logins'

SELECT
    TO_NUMBER(a.value)         max_sess_allowed
  , TO_NUMBER(count(*))        num_sessions
  , LPAD(ROUND((count(*)/a.value)*100,0) || '%', 19)  pct_utl
FROM 
    v$session    b
  , v$parameter  a
WHERE 
    a.name = 'sessions'
GROUP BY 
    a.value;
PROMPT
PROMPT
SELECT
    TO_NUMBER(a.value)           max_proce_allowed
  , TO_NUMBER(count(sid))        num_processes
  , LPAD(ROUND((count(sid)/a.value)*100,0) || '%', 19)  pct_utl
FROM 
    v$session    b
  , v$parameter  a
WHERE 
    a.name = 'processes'
GROUP BY 
    a.value;   

BREAK on report
COMPUTE sum OF num_user_sess count_a count_i ON report

SELECT
    lpad(nvl(sess.username, '[B.G. Process]'), 20) username
   ,lpad(upper(sess.machine), 30) machine
  , count(1) num_user_sess
  , nvl(act.count, 0)   count_a
  , nvl(inact.count, 0) count_i
FROM 
    v$session sess
  , (SELECT    count(*) count, nvl(username, '[B.G. Process]') username, nvl(machine, '/') machine
     FROM      v$session
     WHERE     status = 'ACTIVE'
     GROUP BY  username, machine)   act
  , (SELECT    count(*) count, nvl(username, '[B.G. Process]') username,  nvl(machine, '/') machine
     FROM      v$session
     WHERE     status = 'INACTIVE'
     GROUP BY  username, machine) inact
WHERE
         nvl(sess.username, '[B.G. Process]') = act.username   (+)
     and nvl(sess.username, '[B.G. Process]') = inact.username (+)
     and nvl(sess.machine, '/') = act.machine   (+)
     and nvl(sess.machine, '/') = inact.machine (+)
GROUP BY 
    sess.username, sess.machine
  , act.count
  , inact.count
  order by count_i desc, count_a asc, username, machine
/

SET FEEDBACK 6

