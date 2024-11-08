-- |----------------------------------------------------------------------------|
-- | Objetivo   : Sessions Undo Open                                            |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 17/03/2021                                                    |
-- | Exemplo    : s_rollback.sql                                                |
-- | Arquivo    : s_rollback.sql                                                |
-- | Modificacao:                                                               |
-- |            :                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessions Undo Open                  +-+-+-+-+-+-+-+-+-+-+   |
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
col sum_used_ublk format 99999999999 head 'USED UNDO|BLOKS'    JUSTIFY CENTER
col total         format 99999999999 head 'TOTAL|-'            JUSTIFY CENTER
col "SID/SERIAL"  format a15         head 'SID/SERIAL@I|-'     JUSTIFY CENTER
col xid           format a16         head 'XID|TRANSACTION'    JUSTIFY CENTER
col status_s      format a08         head 'STATUS|SESSION'     JUSTIFY CENTER
col username      format a12         head 'USERNAME|-'         JUSTIFY CENTER
col used_ublk     format 99999999999 head 'USED UNDO|BLOKS'    JUSTIFY CENTER
col used_urec     format 99999999999 head 'USED UNDO|ROWS'     JUSTIFY CENTER
col roll_in_exec  format a09         head 'ROLLBACK|EXECUTION' JUSTIFY CENTER
col rssize        format a11         head 'SIZE|TRANSACTION'   JUSTIFY CENTER
col status_r      format a08         head 'STATUS|ROLLBACK'    JUSTIFY CENTER
col START_DATE    format a20         head 'START|DATE'        JUSTIFY CENTER
col inst_id       format 999999      head 'INST_ID|-'        JUSTIFY CENTER
SET COLSEP '|'


select inst_id, sum(used_ublk) sum_used_ublk, count(1) total from gv$transaction GROUP BY inst_id
/

SELECT s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",
	   t.xid,
	   s.status status_s,
	   s.username,
	   t.used_ublk,
	   t.used_urec,
	   --rs.segment_name,
	  dbms_xplan.format_size(r.rssize) rssize, 
	   r.status status_r,
	   decode(bitand(t.flag,128),0,'NO','YES') roll_in_exec,
	   START_DATE
FROM   gv$transaction t,
	   gv$session s,
	   gv$rollstat r,
	   dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr AND s.inst_id = T.inst_id
AND    t.xidusn = r.usn AND T.inst_id = R.inst_id
AND   rs.segment_id = t.xidusn   --and s.sid = 2253
ORDER BY roll_in_exec, t.used_ublk DESC
/
	

