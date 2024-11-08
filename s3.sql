-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_active.sql                                                 |
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
PROMPT | Report   : Sessoes Ativas                                              |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    4
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

set lines 400
set pages 100
col "SID/SERIAL" format a13 
col "SLAVE" format a13
col opid format a4
col sopid format a8
col username format a10
col osuser format a10
col call_et for a7
col program for a10
col client_info for a23
col machine for a18
col logon_time for a10
col hold for a6
col sessionwait for a25
col sc_wait for a5 HEADING 'sc_wt'
--col lw for a2
select	s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  "SID/SERIAL"
       ,case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end "SLAVE"
,    to_char(p.pid)    opid
,    to_char(p.spid)    sopid
,	substr(s.username,1,10) username
,   substr(s.osuser,1,10)  osuser       
,substr(s.program,1,10) Program
,substr(s.machine,1,18) Machine
,       TO_CHAR(s.logon_time,'ddmmrrhh24mi') logon_time
,	to_char(s.last_call_et) as call_et
,SUBSTR((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from v$session_wait j where j.sid = s.sid /*and j.INST_ID =  s.inst_id*/),1,25) SessionWait
,	s.sql_id
,       s.blocking_session || ',' || s.blocking_instance hold
,	to_char(s.seconds_in_wait) sc_wait--,    nvl2(s.lockwait,'S','N') as lw
from gv$session s
,	 gv$process p 
,    gv$px_session e
Where s.paddr    = p.addr (+)
  and s.inst_id  = p.inst_id (+)
  and s.username is not null 
  and s.status   = 'ACTIVE'
  and s.inst_id  = e.inst_id(+)
  and s.sid      = e.sid(+)
  and s.serial#  = e.serial#(+)
  --and s.WAIT_CLASS != 'Idle'
  order by s.inst_id, e.qcsid || ',' || e.qcserial#, s.username, s.program
/
SET FEEDBACK on

--select trim(substr(event,1,100)) from gv$session_wait where sid = 1192 and INST_ID =  1
