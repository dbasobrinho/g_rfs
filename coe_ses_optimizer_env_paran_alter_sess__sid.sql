-- |----------------------------------------------------------------------------|
-- | DATABASE :                                                                 |
-- | FILE     :                                                                 |
-- | CLASS    :                                                                 |
-- | PURPOSE  :                                                                 |
-- | NOTE     :                                                                 |
-- |                                                                            |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Verificar parâmetros alterados em uma sessão                |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT ..
PROMPT .
ACCEPT QQ_SID CHAR PROMPT 'ENTER_SID     (ALL) = ' DEFAULT ALL
PROMPT .
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    1000
SET PAGESIZE    10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES


col "SID/SERIAL" format a13 
col opid format a4
col sopid format a8
col username format a10
col osuser format a10
col call_et for a7
col program for a10
col client_info for a23
col machine for a18
col logon_time for a10
col hold for a6
col sessionwait for a25
col sc_wait for a9 HEADING 'sc_wt'
col STATUS  for a9 HEADING 'STATUS'
col sql_id for a13 
col HASH_VALUE for a10
col "SID/SERIAL" format a13  HEADING 'SID/SERIAL@I'
col "SLAVE"      format a13
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
col sc_wait      format a06 HEADING 'WAIT'
SET COLSEP '|'

col name for a40
col username for a30
col value for a40

	select a.INST_ID, a.sid, c.username, a.name, a.value
	  from gv$ses_optimizer_env a
	  join gv$sys_optimizer_env b on a.id = b.id and a.INST_ID = b.INST_ID
	  join gv$session c on a.sid = c.sid and a.INST_ID = c.INST_ID
	 where a.value <> b.value
	   and c.username is not null
	   and c.username not in ('SYS', 'SYSTEM', 'DBSNMP')
	   and c.sid      = DECODE('&&QQ_SID'   ,'ALL',c.sid   ,'&&QQ_SID')
	 order by a.sid, a.name
/





