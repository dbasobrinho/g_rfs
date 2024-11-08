-- |kill -9 $(ps -ef | grep -v grep | grep 'LOCAL=NO' | grep pbackS | awk '{print $2}')
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : CURRENT open_cursors                +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       900
SET PAGES       900
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a16  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a15
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a50
col logon_time   format a13
col TOTAL_CUR    format 9999999999
col MAX_CUR      format 9999999999
col AVG_CUR      format 9999999999
col hash_value   format a10
col sc_wait      format a06 HEADING 'WAIT'
col SQL_ID       format a15 HEADING 'SQL_ID/CHILD'
col module       format a08 HEADING 'MODULE'
SET COLSEP '|'

BREAK ON report ON USERNAME SKIP 1
COMPUTE sum LABEL ""              OF TOTAL_CUR used_mb ON TOTAL_CUR
SELECT SUM(A.VALUE)        TOTAL_CUR, 
       round(AVG(A.VALUE)) AVG_CUR  , 
	   MAX(A.VALUE)        MAX_CUR  ,
	   S.USERNAME , 
	   S.MACHINE
FROM V$SESSTAT A, V$STATNAME B, V$SESSION S
WHERE A.STATISTIC# = B.STATISTIC#  AND S.SID=A.SID
AND upper(B.NAME) = 'OPENED CURSORS CURRENT'
GROUP BY S.USERNAME, S.MACHINE
ORDER BY 1 DESC
/


