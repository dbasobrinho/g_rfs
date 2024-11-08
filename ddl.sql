-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : ddl.sql                                                         |
-- | CREATOR  : ROBERTO FERNANDES SOBRINHO                                      |
-- | DATE     : 21/02/2019 (amanha e meu aniversario, VIVA!)                    |
-- +----------------------------------------------------------------------------+
set linesize 2000;
set pagesize 1000;
set long 9999999;
set TRIMS on;
set ECHO off;
set FEED off; 
set HEAD off;
COLUMN DDL FORMAT a9999;
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | EXTRACT DDL OBJETC                                           [ddl.sql] |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT obj_type  char   PROMPT 'OBJETC_TYPE = '
ACCEPT obj_owner char   PROMPT 'OWNER       = '
ACCEPT obj_name  char   PROMPT 'OBJETC_NAME = '
--spool &dir_saida/PR_TESTE.bkp;
select dbms_metadata.get_ddl(upper('&obj_type'), upper('&obj_name'), upper('&obj_owner')) "DDL" from dual;
---spool off;
set FEED on;
set HEAD on;
set time on;
SET FEEDBACK on                                                                                         
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 



