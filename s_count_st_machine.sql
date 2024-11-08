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
PROMPT | Report   : Count Sessoes Machine / Status                              |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    1000
SET PAGESIZE    10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES


col "SID/SERIAL" format a13 
col opid format a4
col sopid format a8
col username format a10
col osuser format a10
col call_et for a7
col program for a10
col client_info for a23
col machine for a30
col logon_time for a10
col hold for a6
col sessionwait for a25
col sc_wait for a9 HEADING 'sc_wt'
col STATUS  for a9 HEADING 'STATUS'
--col lw for a2
select	s.inst_id, s.status ,s.machine Machine, count(1) total
from gv$session s
,	 gv$process p 
,    gv$px_session e
Where s.paddr    = p.addr 
  and s.inst_id  = p.inst_id 
  and s.username is not null 
  and s.inst_id  = e.inst_id(+)
  and s.sid      = e.sid(+)
  and s.serial#  = e.serial#(+)
  group by s.inst_id, s.machine, s.status
  order by 1, 4 desc, 3
  /
