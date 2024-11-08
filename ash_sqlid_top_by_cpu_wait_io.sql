-- |----------------------------------------------------------------------------|
-- | Objetivo   : TOP SQLS SPENT MORE ON CPU/WAIT/IO                            |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 19/02/2020                                                    |
-- | Exemplo    : @ash_sqlid_top_by_cpu_wait_io.sql                             |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT  --TOP SQLS SPENT MORE ON CPU/WAIT/IO
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : TOP SQLS SPENT MORE ON CPU/WAIT/IO  +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       1000
SET PAGES       1000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a17  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a20
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
col CPU          format 99999999999 HEADING 'CPU'
col WAIT         format 99999999999 HEADING 'WAIT'
col IO           format 99999999999 HEADING 'IO'
col TOTAL        format 99999999999999 HEADING 'TOTAL'
col module       format a30 HEADING 'MODULE'
SET COLSEP '|'
ACCEPT TTOP_NN    number PROMPT 'TOP_N      <= '
select * from 
(
select a.INST_ID,
a.SQL_ID ,
sum(decode(a.session_state,'ON CPU',1,0)) CPU,
sum(decode(a.session_state,'WAITING',1,0)) - sum(decode(a.session_state,'WAITING', decode(en.wait_class, 'User I/O',1,0),0)) WAIT ,
sum(decode(a.session_state,'WAITING', decode(en.wait_class, 'User I/O',1,0),0)) IO ,
sum(decode(a.session_state,'ON CPU',1,1)) TOTAL
from gv$active_session_history a,gv$event_name en
where a.SQL_ID is not NULL 
and en.event#(+)=a.event#
and en.INST_ID(+)=a.INST_ID
--and a.SQL_ID =  '098f9y82vqwx5'
group by a.SQL_ID, a.INST_ID
order by TOTAL desc 
)
where rownum <= &TTOP_NN
/
UNDEF TTOP_NN
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 