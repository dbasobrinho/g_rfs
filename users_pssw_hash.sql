SET PAGESIZE 1000
SET LINESIZE 220
SET TIMING ON
SET TIME ON
COLUMN version          FORMAT A11
COLUMN username         FORMAT A30
COLUMN HASH             FORMAT A20
COLUMN command          FORMAT A80
PROMPT 
ACCEPT USERNAME CHAR PROMPT 'USERNAME = '
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : HASH SENHA DE USUARIO                                       |
PROMPT | alter user <USERNAME> identified by values '<HASH>';                   |
PROMPT +------------------------------------------------------------------------+
PROMPT 
select 'ORACLE-10g' as version, username,password AS HASH, 'alter user '||username ||' identified by values '''||password||''''||';' as command from dba_users where username = upper('&USERNAME');
PROMPT
select 'ORACLE-11g', name as username, password AS HASH, 'alter user '||name ||' identified by values '''||password||''''||';' as command from user$ where name = upper('&USERNAME');
PROMPT
PROMPT
