-- |----------------------------------------------------------------------------|
-- | Objetivo   : Oracle Active Sessions Database                               |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 19/12/2019                                                    |
-- | Exemplo    : s_parallel.sql                                                |
-- | Arquivo    : s.sql                                                         |
-- | Modificacao: V1.0 - 03/08/2019 - rfsobrinho -                              |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessions Parallel                   +-+-+-+-+-+-+-+-+-+-+   |
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

select
      s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",
	  to_char(nvl((case when px.qcsid is not null then px.qcsid || ',' || px.qcserial#|| case when px.inst_id is not null then ',@' || px.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE,
	  substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username,
	  s.sql_id  as sql_id,
      to_char(p.pid)          as opid,
     to_char(p.spid)         as sopid	,
s.status,	 
	  substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait,
      decode(px.qcinst_id,NULL,s.username,' - '||lower(substr(s.program,length(s.program)-4,4) ) ) Username2,
      decode(px.qcinst_id,NULL, 'QC', '(Slave)') QC_Slave ,
      to_char( px.server_set) Slave_Set,
      decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) QC_SID,
      px.req_degree Requested_DOP,
     px.degree Actual_DOP
   from
     gv$px_session px,
     gv$session s, gv$process p
   where
     px.sid=s.sid (+) and
     px.serial#=s.serial# and
     px.inst_id = s.inst_id
     and p.inst_id = s.inst_id
     and p.addr=s.paddr
  order by 1 desc
/
SET FEEDBACK on
--SET COLSEP ' '
