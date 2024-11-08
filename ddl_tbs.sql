PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | EXTRACT DDL TABLESPACE                                   [ddl_tbs.sql] |
PROMPT +------------------------------------------------------------------------+
PROMPT

ACCEPT TTTBSSS  char   PROMPT 'TABLESPACE = '

SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('TABLESPACE', tablespace_name)
FROM   dba_tablespaces
WHERE  tablespace_name = DECODE(UPPER('&&TTTBSSS'), 'ALL', tablespace_name, UPPER('&&TTTBSSS'));

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON
UNDEFINE TTTBSSS
---spool off;
set FEED on;
set HEAD on;
set time on;
SET FEEDBACK on   

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF                                                                                      
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 