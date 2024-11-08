-- -----------------------------------------------------------------------------------
SET TIMING ON
SET VERIFY OFF
PROMPT 
ACCEPT VV CHAR PROMPT 'SCHEMA      = '
ACCEPT XX CHAR PROMPT 'TABLE_NAME  = '
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT |  GRANT ALL BY TABLE                                                    |
PROMPT +------------------------------------------------------------------------+
PROMPT ..
COLUMN GRANTEE             FORMAT A15
COLUMN GRANTOR             FORMAT A15
COLUMN event               FORMAT A35
COLUMN PRIVILEGE           FORMAT A11
COLUMN OWNER               FORMAT A10
COLUMN TABLE_NAME          FORMAT A30


SELECT GRANTEE, PRIVILEGE, OWNER, TABLE_NAME, GRANTOR FROM DBA_TAB_PRIVS 
WHERE owner = upper('&VV')
and table_name = upper('&XX')
order by GRANTEE, PRIVILEGE
/
