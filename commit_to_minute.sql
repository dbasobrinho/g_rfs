-- |----------------------------------------------------------------------------|
-- | Objetivo   : Oracle Active Sessions Database                               |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 19/12/2019                                                    |
-- | Exemplo    : commit_to_minute.sql                                          |
-- | Arquivo    : commit_to_minute.sql                                          |
-- | Modificacao: V1.0 - 03/08/2019 - rfsobrinho -                              |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : COMMIT POR MINUTO                   +-+-+-+-+-+-+-+-+-+-+   |
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
col program      format a70
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

col STAT_NAME for a20
col VALUE_DIFF for 9999,999,999
col STAT_PER_MIN for 9999,999,999
set lines 200 pages 1500 long 99999999
col BEGIN_INTERVAL_TIME for a30
col END_INTERVAL_TIME for a30
set pagesize 40
set pause on
 
 
select hsys.SNAP_ID,
       hsnap.BEGIN_INTERVAL_TIME,
       hsnap.END_INTERVAL_TIME,
           hsys.STAT_NAME,
           hsys.VALUE,
           hsys.VALUE - LAG(hsys.VALUE,1,0) OVER (ORDER BY hsys.SNAP_ID) AS "VALUE_DIFF",
           round((hsys.VALUE - LAG(hsys.VALUE,1,0) OVER (ORDER BY hsys.SNAP_ID)) /
           round(abs(extract(hour from (hsnap.END_INTERVAL_TIME - hsnap.BEGIN_INTERVAL_TIME))*60 +
           extract(minute from (hsnap.END_INTERVAL_TIME - hsnap.BEGIN_INTERVAL_TIME)) +
           extract(second from (hsnap.END_INTERVAL_TIME - hsnap.BEGIN_INTERVAL_TIME))/60),1)) "STAT_PER_MIN"
from dba_hist_sysstat hsys, dba_hist_snapshot hsnap
 where hsys.snap_id = hsnap.snap_id
 and hsnap.instance_number in (select instance_number from v$instance)
 and hsnap.instance_number = hsys.instance_number
 and hsys.STAT_NAME='user commits'
 order by 1;
SET FEEDBACK on
--SET COLSEP ' '
