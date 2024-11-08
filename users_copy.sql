SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      ON

COLUMN command FORMAT A120
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | GERA SCRIPT PARA COPIAR UM USUARIOS E SEUS ACESSOS                          |
PROMPT +-----------------------------------------------------------------------------+
PROMPT .
PROMPT . .
PROMPT . . .

ACCEPT v_usertocopyfrom char   PROMPT 'QUAL O USERNAME  SERVIRA COMO BASE PARA COPIA = '
ACCEPT v_newusername    char   PROMPT 'QUAL O USERNAME DO NOVO USUARIO               = '
ACCEPT v_newuserpass    char   PROMPT 'QUAL A SENHA DO NOVO USUARIO                  = '

PROMPT .
PROMPT . .
PROMPT . . .
-- Create user, define default tablespace, temporary tablespace and profile
select z.command
from  (
select '-- Create user, define default tablespace, temporary tablespace and profile' as command
  from dual
union all
select 'create user &v_newusername identified by &v_newuserpass' ||
       ' default tablespace ' || default_tablespace ||
       ' temporary tablespace ' || temporary_tablespace || ' profile ' ||
       profile || ';'
  from dba_users
 where username = upper('&v_usertocopyfrom')
union all
select 'alter user &v_newusername password expire;' from dual
union all
-- Grant Roles to new user
select '-- Grant Roles to new user'
  from dual
union all
select 'grant ' || granted_role || ' to &v_newusername' ||
       decode(admin_option, 'YES', ' with admin option') || ';'
  from dba_role_privs
 where grantee = upper('&v_usertocopyfrom')
union all
-- Grant System Privs...
select '-- Grant System Privs'
  from dual
union all
select 'grant ' || privilege || ' to &v_newusername' ||
       decode(admin_option, 'YES', ' with admin option') || ';'
  from dba_sys_privs
 where grantee = upper('&v_usertocopyfrom')
union all
-- Grants on database objects
select '-- Grant on database objects'
  from dual
union all
select 'grant ' || privilege || ' on ' || owner || '.' || table_name ||
       ' to &v_newusername' ||
       decode(grantable, 'YES', ' with admin option') || ';'
  from dba_tab_privs
 where grantee = upper('&v_usertocopyfrom')
union all
-- Grant Column Privs...
select '-- Grant Column Privs'
  from dual
union all
select 'grant ' || privilege || '(' || column_name || ') on ' || owner || '.' ||
       table_name || ' to &v_newusername;'
  from dba_col_privs
 where grantee = upper('&v_usertocopyfrom')
union all
-- Set Default Role...
select '-- Set default role'
  from dual
union all
select 'alter user &v_newusername default role ' || granted_role || ';'
  from dba_role_privs
 where grantee = upper('&v_usertocopyfrom')
   and default_role = 'YES'
union all
-- Set quotas to user
select '-- Set quotas to new user'
  from dual
union all
select 'alter user &v_newusername quota ' || max_bytes || ' on ' ||
       tablespace_name || ';'
  from dba_ts_quotas
 where username = upper('&v_usertocopyfrom') )z;
 
