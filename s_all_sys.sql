-- |----------------------------------------------------------------------------|
-- | Objetivo   : Vizualizar sessoes ativas e Inativas no Oracle                |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 15/12/2015                                                    |
-- | Exemplo    : @s_all                                                        |
-- | Arquivo    : s_all.sql                                                     |
-- |                                                                            |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Inactives / Active Sessions Oracle  |-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.2                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT ..
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       600
SET PAGES       600 
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a16  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a19
col logon_time   format a13 
col hold         format a06
col sessionwait  format a24
col status       format a08
col hash_value   format a10 
col sc_wait      format a06 HEADING 'WAIT'
col SQL_ID       format a15 HEADING 'SQL_ID/CHILD'
col module       format a08 HEADING 'MODULE'
SET COLSEP '|'
select  s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL"
,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
 to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,12)))  as SLAVE
,    to_char(p.pid)          as opid
,    to_char(p.spid)         as sopid
,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
,    substr(s.osuser,1,10)   as osuser
--,    substr(s.program,1,10)  as program
--,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
,    substr(s.machine,1,19)  as machine
,    to_char(s.logon_time,'ddmm:hh24mi')||
     case when to_number(to_char((sysdate-nvl(s.last_call_et,0)/86400),'yyyymmddhh24miss'))-to_number(to_char(s.logon_time,'yyyymmddhh24miss')) > 60 then '[P]' ELSE '[NP]' END as logon_time
,        to_char(s.last_call_et)              as call_et
,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,24) as sessionwait
,        s.sql_id||' '||SQL_CHILD_NUMBER  as sql_id
,    s.blocking_session || ',' || s.blocking_instance as hold
,        to_char(s.seconds_in_wait) as sc_wait
,     SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
from gv$session s
,	 gv$process p 
,    gv$px_session e
Where s.paddr       = p.addr    (+)
  and s.inst_id     = p.inst_id (+)
  --and s.status      = 'ACTIVE'
  and s.inst_id     = e.inst_id (+)
  and s.sid         = e.sid     (+)
  and s.serial#     = e.serial# (+)
  and s.username  = 'SYS' --is not null
  order by s.logon_time desc  , s.status desc, s.inst_id,s.seconds_in_wait desc, e.qcsid || ',' || e.qcserial#, s.username, s.program
/
SET FEEDBACK on

