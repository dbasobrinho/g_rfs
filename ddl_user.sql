-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : ddl_user                                                        |
-- | CREATOR  : ROBERTO FERNANDES SOBRINHO                                      |
-- | DATE     : 21/02/2020 (amanha e meu aniversario, VIVA!)                    |
-- +----------------------------------------------------------------------------+
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

COLUMN username                    FORMAT A20
COLUMN account_status              FORMAT A16
COLUMN lock_date                   FORMAT A16
COLUMN expiry_date                 FORMAT A16
COLUMN default_tbs                 FORMAT A18
COLUMN temp_tbs                    FORMAT A13
COLUMN created                     FORMAT A16
COLUMN profile                     FORMAT A19
COLUMN consumer_group              FORMAT A20 

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | EXTRACT DDL / PRIV USER                                 [ddl_user.sql] |
PROMPT +------------------------------------------------------------------------+
PROMPT

ACCEPT user_parx  char   PROMPT 'USUARIO ORACLE PRA DDL = '

SELECT username,
       account_status,
       TO_CHAR(lock_date, 'DD/MM/YYYY HH24:MI') AS lock_date,
       TO_CHAR(expiry_date, 'DD/MM/YYYY HH24:MI') AS expiry_date,
       default_tablespace   as default_tbs,
       temporary_tablespace as temp_tbs,
       TO_CHAR(created, 'DD/MM/YYYY HH24:MI') AS created,
       profile,
       SUBSTR(initial_rsrc_consumer_group,1,20) AS consumer_group
FROM   dba_users
WHERE  username LIKE UPPER('%&&user_parx%')
ORDER BY username;

SET VERIFY ON
set linesize 2000;
set pagesize 1000;
set long 9999999;
set TRIMS on;
set ECHO off;
set FEED off; 
set HEAD off;
COLUMN DDL FORMAT a9999;
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT dbms_metadata.get_ddl('USER',UPPER('&&user_parx')) FROM dual
/
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT',UPPER('&&user_parx')) from dual
/
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT',UPPER('&&user_parx')) from dual
/
SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT',UPPER('&&user_parx')) from dual
/
UNDEFINE user_parx
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







