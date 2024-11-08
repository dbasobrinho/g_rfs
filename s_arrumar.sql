-- |----------------------------------------------------------------------------|
-- | Objetivo   : Vizualizar sessoes ativas no Oracle                           |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 15/12/2015                                                    |
-- | Exemplo    : @s                                                            |
-- | Arquivo    : s.sql                                                         |
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
PROMPT ..
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
col "SID/SERIAL" format a17  HEADING 'SID/SERIAL@I'
col slave        format a16  HEADING 'SLAVE/W_CLASS'
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
SET COLSEP '|'
select  decode(upper(s.WAIT_CLASS),'IDLE','[I]','[N]')||s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL"
,nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13))  as SLAVE
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
,        gv$process p
,    gv$px_session e
Where s.paddr       = p.addr    (+)
  and s.inst_id     = p.inst_id (+)
  and s.status      = 'ACTIVE'
  and s.inst_id     = e.inst_id (+)
  and s.sid         = e.sid     (+)
  and s.serial#     = e.serial# (+)
  --and s.WAIT_CLASS != 'Idle'
  and s.username is not null
order by s.inst_id, case when instr(SLAVE,',,@') >0 then to_number('1'||substr(SLAVE,1,3)) when instr(SLAVE,'@') >0 then  to_number('2'||substr(SLAVE,1,3)) else null end
  --order by decode(upper(s.WAIT_CLASS),'IDLE',1,0),s.inst_id, case when instr(SLAVE,',,@') >0 then SLAVE when instr(SLAVE,'@') >0 then SLAVE else null end, decode(s.username,'SYS',1,0), s.inst_id,s.seconds_in_wait desc, e.qcsid || ',' || e.qcserial#, s.username, s.program
/
SET FEEDBACK on
--SET COLSEP ' '

||decode(upper(s.WAIT_CLASS),'IDLE','(I)')



select case when instr('2440,,@1',',,') >0 then '0' else '2440,,@1' end from dual;

