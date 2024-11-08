-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : s_sid.sql                                                       |
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
PROMPT | Report   : Sessoes BY SID                                              |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT ..
PROMPT .
ACCEPT QQ_SID CHAR PROMPT 'ENTER_SID   = '
PROMPT .
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
col machine for a18
col logon_time for a10
col hold for a6
col sessionwait for a25
col sc_wait for a9 HEADING 'sc_wt'
col STATUS  for a9 HEADING 'STATUS'
col sql_id for a13 
col HASH_VALUE for a10
col "SID/SERIAL" format a13  HEADING 'SID/SERIAL@I'
col "SLAVE"      format a13
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
col sc_wait      format a06 HEADING 'WAIT'
SET COLSEP '|'
--col lw for a2
select  s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL"
,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
 to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
,s.status
,    to_char(p.pid)          as opid
,    to_char(p.spid)         as sopid
,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
,    substr(s.osuser,1,10)   as osuser
,    substr(s.program,1,10)  as program
,    substr(s.machine,1,20)  as machine
,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
,        to_char(s.last_call_et)              as call_et
,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
,        s.sql_id  as sql_id
,    s.blocking_session || ',' || s.blocking_instance as hold
,        to_char(s.seconds_in_wait) as sc_wait
from gv$session s
,	 gv$process p 
,    gv$px_session e
Where s.paddr    = p.addr 
  and s.inst_id  = p.inst_id 
  --and s.username is not null 
  and s.sid       = &QQ_SID
  and s.inst_id  = e.inst_id(+)
  and s.sid      = e.sid(+)
  and s.serial#  = e.serial#(+)
  order by STATUS desc, s.seconds_in_wait desc,e.qcsid || ',' || e.qcserial#, s.username, s.program
/