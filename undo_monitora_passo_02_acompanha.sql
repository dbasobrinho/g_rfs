PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | BLOCK_CHANGES > 99                                                           |
PROMPT +-----------------------------------------------------------------------------+
PROMPT

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
col hash_value   format a10
col mb_changes   format a18
col block_changes   format 999999999999
col sc_wait      format a06 HEADING 'WAIT'
col DT_INI       format a21
col DT_FIM       format a21
col SEGUNDOS     format a10

 SELECT  esu.sid || ',' || esu.serial#|| case when esu.inst_id is not null then ',@' || esu.inst_id end  as "SID/SERIAL"
,	 substr(esu.username,1,10) as username
,    substr(esu.osuser,1,10)   as osuser       
,    substr(esu.program,1,10)  as program
,    substr(esu.machine,1,20)  as machine
,    esu.status
,	 esu.sql_id  as sql_id
,    esu.block_changes - bsu.block_changes block_changes
,    to_char(round(((esu.block_changes - bsu.block_changes) * (select to_number(VALUE) from v$parameter where UPPER(name) = UPPER('db_block_size'))) /1024/1024,2),'99999999990.99') mb_changes
,    (select TO_CHAR(dt,'DD/MM/YYYY HH24:MI:SS') x1 FROM sys.begin_set_undo_xxyzzzzz1234 where rownum = 1) DT_INI
,    TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') DT_FIM
,    trunc((select (SYSDATE-DT)*24*60*60 x1 FROM sys.begin_set_undo_xxyzzzzz1234 where rownum = 1))||'_SEC' SEGUNDOS
    FROM sys.begin_set_undo_xxyzzzzz1234 bsu,
         (  SELECT s.inst_id, s.sql_id, s.osuser, s.machine,
                   s.sid,
                   s.serial#,
                   s.username,
                   s.program,
				   s.status,
                   i.block_changes
              FROM gv$session s, gv$sess_io i
             WHERE s.inst_id = i.inst_id AND s.sid = i.sid
          ORDER BY 6 DESC,
                   s.inst_id,
                   s.sid,
                   s.serial#,
                   s.username,
                   s.program) esu
   WHERE     bsu.inst_id = esu.inst_id
         AND bsu.sid = esu.sid
         AND bsu.serial# = esu.serial#
		 and esu.block_changes - bsu.block_changes > 99
ORDER BY block_changes asc
/
TTITLE OFF
UNDEF DATA_INI