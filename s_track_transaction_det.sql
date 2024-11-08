-- |----------------------------------------------------------------------------|
-- | Objetivo   : Traking Transaction                                           |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 17/03/2021                                                    |
-- | Exemplo    : s_track_transaction_det.sql                                   |
-- | Arquivo    : s_track_transaction_det.sql                                   |
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
PROMPT | Report   : Traking Transacrion Det             +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    on
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
col operation     format a09         head 'OPERATION|-'        JUSTIFY CENTER  
col TBLE          format a40         head 'OWNER.TABLE|-'      JUSTIFY CENTER 
col START_SCN     format a13         head 'START_SCN|-'        JUSTIFY CENTER 
col COMMIT_SCN    format a13         head 'COMMIT_SCN|-'       JUSTIFY CENTER 
col logon_user    format a12         head 'USERNAME|-'         JUSTIFY CENTER
col ROW_ID           format a19         head 'ROWID|-'            JUSTIFY CENTER
col UNDO_SEQ         format 99999       head 'ROLLBACK|SEQ'       JUSTIFY CENTER
col START_TIMESTAMP  format a20         head 'START|TIMESTAMP'       JUSTIFY CENTER
col START_TIMESTAMP  format a20         head 'START|TIMESTAMP'       JUSTIFY CENTER
COLUMN undo_sql    FORMAT a150 word_wrapped  head 'UNDO|SQL'       JUSTIFY CENTER

col xid           format a16         head 'XID|TRANSACTION'    JUSTIFY CENTER
col status_s      format a08         head 'STATUS|SESSION'     JUSTIFY CENTER
col username      format a12         head 'USERNAME|-'         JUSTIFY CENTER
col used_ublk     format 99999999999 head 'USED UNDO|BLOKS'    JUSTIFY CENTER
col used_urec     format 99999999999 head 'USED UNDO|ROWS'     JUSTIFY CENTER
col roll_in_exec  format a09         head 'ROLLBACK|EXECUTION' JUSTIFY CENTER
col rssize        format a11         head 'SIZE|TRANSACTION'   JUSTIFY CENTER
col status_r      format a08         head 'STATUS|ROLLBACK'    JUSTIFY CENTER
col START_DATE    format a20         head 'START|DATE'         JUSTIFY CENTER
col inst_id       format a07         head 'INST_ID|-'          JUSTIFY CENTER
SET COLSEP '|'
SELECT operation,  UNDO_CHANGE# UNDO_SEQ, ROW_ID , --, TO_CHAR(start_scn) AS start_scn ,  TO_CHAR(commit_scn) commit_scn, 
SUBSTR(logon_user, 1,12) logon_user,
undo_sql
--SUBSTR(TABLE_OWNER||'.'||TABLE_OWNER,1,40) as TBLE, ROW_ID, UNDO_CHANGE# UNDO_SEQ, START_TIMESTAMP
FROM   flashback_transaction_query
WHERE  xid = HEXTORAW('&XID')
ORDER BY UNDO_SEQ DESC
/
UNDEF XID