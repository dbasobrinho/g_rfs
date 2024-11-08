-- |----------------------------------------------------------------------------|
-- | Objetivo   : Top Uso CPU - TOP N                                           |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 19/02/2020                                                    |
-- | Exemplo    : @ash_top_by_cpu_last_60_minutes.sql                           |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Top 10 session CPU last 60 minute   +-+-+-+-+-+-+-+-+-+-+   |
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
col sc_wait      format a06 HEADING 'WAIT'
col module       format a30 HEADING 'MODULE'
SET COLSEP '|'
ACCEPT TTOP_NN    number PROMPT 'TOP_N      <= '
-->Top session on CPU in last 15 minute
SELECT * FROM
(
SELECT  s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",
s.username, s.module,s.sql_id,count(*) 
FROM gv$active_session_history h, gv$session s
WHERE h.session_id = s.sid
AND h.session_serial# = s.serial#
and h.INST_ID = s.INST_ID
AND session_state= 'ON CPU' AND
s.sql_id is not null and 
sample_time > sysdate - interval '60' minute
GROUP BY  s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end, s.username, s.module, s.sid, s.serial#,s.sql_id
ORDER BY count(*) desc
)
where rownum <= &TTOP_NN
/
UNDEF TTOP_NN
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 