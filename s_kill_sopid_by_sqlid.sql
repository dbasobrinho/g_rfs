-- |----------------------------------------------------------------------------|
-- | Objetivo   : Oracle Active Sessions Database                               |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 15/12/2015                                                    |
-- | Exemplo    : @s                                                            |
-- | Arquivo    : s.sql                                                         |
-- | Modificacao: V2.1 - 03/08/2019 - rfsobrinho - Vizulizar MODULE no USERNAME |
-- |            : V2.2 - 24/02/2021 - rfsobrinho - Ver POOL conexao e CHILD     |
-- +----------------------------------------------------------------------------+
-- |kill -9 $(ps -ef | grep -v grep | grep 'LOCAL=NO' | grep pbackS | awk '{print $2}')
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : KILL -9 SOPID BY sqlid              +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
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
col sopid        format a15
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
spo kill.sh
select  'kill -9 '||to_char(p.spid)       as sopid
from gv$session s
,        gv$process p
,    gv$px_session e
Where s.paddr       = p.addr    (+)
  and s.inst_id     = p.inst_id (+)
  and s.status      = 'ACTIVE'
  and s.inst_id     = e.inst_id (+)
  and s.sid         = e.sid     (+)
  and s.serial#     = e.serial# (+)
  and s.WAIT_CLASS != 'Idle'
  and s.inst_id = (select INSTANCE_NUMBER from v$instance) and s.sql_id = '&INFORMAR_SQLID'
  and nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)) != 'Idle'
  and s.username is not null
order by 1
/
spo off
SET FEEDBACK on
--SET COLSEP ' '
