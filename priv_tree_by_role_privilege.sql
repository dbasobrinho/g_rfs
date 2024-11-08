set pages 5000
set lines 5000
column Privilege_Roles_and_Users     format a100

select
  lpad(' ', 4*level) || c Privilege_Roles_and_Users
from
  (
  /* THE PRIVILEGES */
    select 
      null   p, 
      name   c
    from 
      system_privilege_map
    where
      name like upper('%&enter_privliege%')
  /* THE ROLES TO ROLES RELATIONS */ 
  union
    select 
      granted_role  p,
      grantee       c
    from
      dba_role_privs
  /* THE ROLES TO privilege RELATIONS */ 
  union
    select
      privilege     p,
      grantee       c
    from
      dba_sys_privs
  )
start with p is null
connect by p = prior c
/


