-- |----------------------------------------------------------------------------|
-- | Objetivo   : GUINA NAO TINHA DO                                            |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 29/04/2017                                                    |
-- | Exemplo    : s_tran_open_det_by_sid                                        |
-- | Arquivo    : s_tran_open_det_by_sid.sql                                    |
-- | Modificacao: V1.0 - rfsobrinho                                             |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Controlling Transactions Open OBJ   +-+-+-+-+-+-+-+-+-+-+   |
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
col username     format a15
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a20
col logon_time   format a10
col hold         format a06
col sessionwait  format a25
col obj          format a35
col rwid         format a18
col status       format a08
col hash_value   format a10
col sc_wait      format a06 HEADING 'WAIT'
col module       format a08 HEADING 'MODULE'
col START_SCN    format a14
SET COLSEP '|'
SELECT s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",s.status
--,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
-- to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
,    substr(s.osuser,1,10)   as osuser
--,    substr(s.program,1,10)  as program
,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
,    substr(s.machine,1,20)  as machine
,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
,        to_char(s.last_call_et)              as call_et
,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
,        s.sql_id  as sql_id
--,    s.blocking_session || ',' || s.blocking_instance as hold
--,        to_char(s.seconds_in_wait) as sc_wait
,	   t.START_DATE
 ,     o.owner||'.'||o.object_name as obj
 ,dbms_rowid.rowid_create ( 1, o.DATA_OBJECT_ID, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# ) rwid    
FROM   gv$transaction t,
       gv$session s,
       gv$rollstat r,
       dba_rollback_segs rs,
        gv$px_session e,
		dba_objects  o
WHERE  s.saddr = t.ses_addr
AND    s.inst_id = t.inst_id
AND    t.xidusn = r.usn
AND    t.inst_id = r.inst_id
AND    rs.segment_id = t.xidusn
  and s.inst_id     = e.inst_id (+)
  and s.sid         = e.sid     (+)
  and s.serial#     = e.serial# (+)
   and s.ROW_WAIT_OBJ# = o.OBJECT_ID(+)
   and s.sid = &SID_ENTER  
ORDER BY t.START_TIME asc
/
UNDEFINE SID_ENTER
