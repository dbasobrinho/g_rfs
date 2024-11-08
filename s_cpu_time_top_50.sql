-- |----------------------------------------------------------------------------|
-- | Objetivo   : Oracle Active Sessions Database                               |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 19/12/2019                                                    |
-- | Exemplo    : s_cpu_time_top_50.sql                                         |
-- | Arquivo    : s_cpu_time_top_50.sql                                         |
-- | Modificacao: V1.0 - 03/08/2019 - rfsobrinho -                              |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessões que consomem muita CPU      +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
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
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a17  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a10
col username2     format a10
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
COL SC_WAIT      FORMAT A06 HEADING 'WAIT'
COL QC_SLAVE     FORMAT A10 HEADING 'QC/SLAVE'
COL SLAVE_SET    FORMAT A10 HEADING 'SLAVE SET'
COL QC_SID       FORMAT A10 HEADING 'QC SID'
COL REQUESTED_DOP      FORMAT 999999 HEADING 'REQUESTED DOP'
COL ACTUAL_DOP      FORMAT 999999 HEADING 'ACTUAL DOP'
SET COLSEP '|'

col program form a30 heading "Program" 
col CPUMins form 99990 heading "CPU in Mins" 
select rownum as rank, a.* 
from ( 
SELECT sess.sid || ',' || sess.serial#|| case when sess.inst_id is not null then ',@' || sess.inst_id end  as "SID/SERIAL", 
substr(sess.username,1,10)||decode(sess.username,'SYS',SUBSTR(nvl2(sess.module,' [',null)||UPPER(sess.module),1,6)||nvl2(sess.module,']',null)) as username,
program, v.value / (100 * 60) CPUMins ,
sess.sql_id  as sql_id,
sess.status,	
substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = sess.sid and j.INST_ID =  sess.inst_id),1,25) as sessionwait
FROM gv$statname s , gv$sesstat v, gv$session sess 
WHERE s.name = 'CPU used by this session' 
and sess.sid = v.sid 
and sess.INST_ID = v.INST_ID 
and v.statistic#=s.statistic# 
and v.INST_ID=s.INST_ID 
and v.value>0 
ORDER BY v.value DESC) a 
where rownum < 51
/
SET FEEDBACK on
--SET COLSEP ' '
