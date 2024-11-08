SET FEEDBACK off TIMING off
SET TERMOUT OFF;
alter session set nls_date_format='dd/mm hh24:mi';
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Replicacao OGG ALELO                +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
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
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a16
col logon_time   format a10
col hold         format a06
col sessionwait  format a25
col status       format a08
col hash_value   format a10
col USED_UBLK    format a05 HEADING 'USED|UBLK' 
col used_urec    format a05 HEADING 'USED|UREC' 
col sc_wait      format a06 HEADING 'WAIT'
col module       format a08 HEADING 'MODULE'
col START_SCN    format a14
col xid           format a16         head 'XID|TRANSACTION'    JUSTIFY CENTER
SET COLSEP '|'
SET FEEDBACK off TIMING off
SELECT s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",s.status
--,decode(upper(s.WAIT_CLASS),'IDLE','I','*')||' '||
-- to_char(nvl((case when e.qcsid is not null then e.qcsid || ',' || e.qcserial#|| case when e.inst_id is not null then ',@' || e.inst_id end end),substr(trim(s.WAIT_CLASS),1,13)))  as SLAVE
,    substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username
,    substr(s.osuser,1,10)   as osuser
--,    substr(s.program,1,10)  as program
,    case when instr(s.program,'(J0') > 0  then substr(s.program,instr(s.program,'(J0'),10)||'-JOB' else substr(s.program,1,10) end  as program
,    substr(replace(substr(s.machine,1,20),'EMISSAO'),1,16)  as machine
--,    to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
,        to_char(s.last_call_et)              as call_et
--,    substr((select trim(replace(replace(substr(event,1,100),'SQL*Net'),'Streams')) from gv$session_wait j where j.sid = s.sid and j.INST_ID =  s.inst_id),1,25) as sessionwait
,        s.sql_id  as sql_id
--,    s.blocking_session || ',' || s.blocking_instance as hold
--,        to_char(s.seconds_in_wait) as sc_wait
,          t.START_DATE
--,        t.START_TIME
,          to_char(t.START_SCN) as  START_SCN
,       to_char(t.used_ublk) USED_UBLK
,       to_char(t.used_urec) used_urec
, t.xid
--,     rs.segment_name
--,       r.rssize
,       r.status
--,      SUBSTR(nvl2(s.module,'[',null)||UPPER(trim(s.module)),1,6)||nvl2(s.module,']',null) as module
FROM   gv$transaction t,
       gv$session s,
       gv$rollstat r,
       dba_rollback_segs rs,
           gv$px_session e
WHERE  s.saddr = t.ses_addr
AND    s.inst_id = t.inst_id
AND    t.xidusn = r.usn
AND    t.inst_id = r.inst_id
AND    rs.segment_id = t.xidusn
  and s.inst_id     = e.inst_id (+)
  and s.sid         = e.sid     (+)
  and s.serial#     = e.serial# (+)
ORDER BY t.START_TIME asc
/

SET TERMOUT OFF;
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
SET TERMOUT ON;
SET ECHO        OFF
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
col THREEAD      format a07
col SEQ          format a08
col ARCHIVED     format a08
col APPLIED      format a07
col REGISTRAR    format a09
col DEST_ID      format 999999
SET COLSEP '|'
PROMPT
SET FEEDBACK off TIMING off
SELECT  to_char(THREAD#)  as THREEAD ,to_char(SEQUENCE#) as SEQ, ARCHIVED, APPLIED, REGISTRAR, DEST_ID, FIRST_TIME, COMPLETION_TIME,  STATUS
FROM  V$archived_log
where COMPLETION_TIME > sysdate-3/24
and  CASE WHEN '5' = 'ALL' THEN to_char(DEST_ID) ELSE  '5' END = to_char(DEST_ID)
ORDER BY DEST_ID, COMPLETION_TIME, THREAD#
-----10/1440  --min
/
SET FEEDBACK off TIMING off
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
col MONITORACAO         format a30
col SAIDA               format a90
col STATUS              format a10		
col DESCRICAO           format a50	
col MSG                 format a90		
col SEND_ALL            format 999		  
SET FEEDBACK off TIMING off 
SELECT MONITORACAO, STATUS, DESCRICAO AS MSG, 0 GERA_INC FROM TABLE(TVTSPI.pkg_wonka_monitor.fnc_pipe_mon('OGG_GAP')) order by decode(STATUS,'NOK','ORA',STATUS) DESC;
UNDEFINE v_dt
UNDEFINE 1
SET FEEDBACK    on
PROMPT.                                                                                                                     ______ _ ___
PROMPT.     @s_track_trans_undo.sql                                                                                        |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT
SET FEEDBACK on TIMING on