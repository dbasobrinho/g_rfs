set pages 5000
set lines 5000
column arvore_previlegios     format a100

select
  lpad(' ', 4*level) || granted_role arvore_previlegios
from
  (
  /* THE USERS */
    select 
      null     grantee, 
      username granted_role
    from 
      dba_users
    where
      username = upper('&enter_username')
  /* THE ROLES TO ROLES RELATIONS */ 
  union
    select 
      grantee,
      granted_role
    from
      dba_role_privs
  /* THE ROLES TO PRIVILEGE RELATIONS */ 
  union
    select
      grantee,
      privilege
    from
      dba_sys_privs
  )
start with grantee is null
connect by grantee = prior granted_role
/ 


