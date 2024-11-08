-- |----------------------------------------------------------------------------|
-- | Objetivo   : Identify line that is Locked                                  |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 04/05/2020                                                    |
-- | Exemplo    : lockrow                                                       |
-- | Arquivo    : lockrow.sql                                                   |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Identify line that is Locked        +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col OWNER        format a17  HEADING 'OWNER'
col rw           format a20  HEADING 'ROWID'
col object_name  format a30
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col OBJECT_TYPE  format a15
col machine      format a20
col logon_time   format a10
col hold         format a06
col sessionwait  format a25
col status       format a08
col hash_value   format a10
col sc_wait      format a06 HEADING 'WAIT'
col module       format a08 HEADING 'MODULE'
PROMPT . . .
PROMPT . . 
PROMPT . 
ACCEPT v_sees      char PROMPT 'sid,serial@inst_id >>  : '
SET COLSEP '|'

select s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",
       substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username,
	   to_char(s.seconds_in_wait) as sc_wait,
	   s.status,
       o.OWNER,
       o.object_name,
	   o.OBJECT_TYPE,
       s.row_wait_obj# as row_wait_obj,
       s.row_wait_file# as row_wait_file,
       s.row_wait_block# as row_wait_block,
       s.row_wait_row# row_wait_row,
       dbms_rowid.rowid_create ( 1, o.DATA_OBJECT_ID, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# )as rw
  from gv$session   s,
       dba_objects o 
where s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end = '&&v_sees'
and s.ROW_WAIT_OBJ# = o.OBJECT_ID
/      
rem clear columns
UNDEFINE v_sees
SET FEEDBACK on
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT

