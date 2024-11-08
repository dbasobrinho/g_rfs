-- |----------------------------------------------------------------------------|
-- | Objetivo   : Oracle Active Sessions Database                               |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 30/04/2020                                                    |
-- | Exemplo    : dg_archived_log_dest_status                                   |
-- | Arquivo    : dg_archived_log_dest_status.sql                               |
-- | Modificacao: V1.0 - rfsobrinho                                             |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
SET TERMOUT ON;
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
col THREEAD      format a07
col SEQ          format a08
col ARCHIVED     format a08
col APPLIED      format a07
col REGISTRAR    format a09
col DEST_ID      format 999999
SET COLSEP '|'
PROMPT
ACCEPT v_dt      NUMBER PROMPT 'SYSDATE -:X >>  : '
ACCEPT 1 CHAR DEFAULT 'ALL' PROMPT 'DEST_ID (<ENTER> DEFAULT ALL):  '

SELECT  to_char(THREAD#)  as THREEAD ,to_char(SEQUENCE#) as SEQ, ARCHIVED, APPLIED, REGISTRAR, DEST_ID, FIRST_TIME, COMPLETION_TIME,  STATUS 
FROM  V$archived_log 
where COMPLETION_TIME > sysdate-&v_dt/24 
and  CASE WHEN '&1' = 'ALL' THEN to_char(DEST_ID) ELSE  '&1' END = to_char(DEST_ID)
ORDER BY DEST_ID, COMPLETION_TIME, THREAD#
-----10/1440  --min
/
rem clear columns
UNDEFINE v_dt
UNDEFINE 1
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT
