--
set pages 5000
set lines 5000
column username       format a19
column privilege      format a50
column object         format a60
column granted_role   format a27

select distinct z.username, granted_role, 
       case when granted_role not in ('DBA') then z.object end object, 
       case when granted_role not in ('DBA') then z.privilege end privilege
from (
select a.grantee username 
      ,a.granted_role
      ,b.owner || '.' || b.table_name object
      ,listagg(b.privilege, ',') within group(order by b.privilege) as privilege
  from dba_role_privs a
      ,role_tab_privs b
 where a.grantee      =  upper('&enter_username')
  -- and a.granted_role = 'SCHEDULER_ADMIN'
   and a.granted_role = b.role
group by a.grantee, a.granted_role, b.owner || '.' || b.table_name
union all
 SELECT upper('tvt_rfs'), ' ',g.owner||'.'||g.table_name as object, listagg(g.privilege, ',') within group (order by g.privilege) as privilege 
   from dba_tab_privs g
 where grantee  = upper('&enter_username')
 group by g.owner||'.'||g.table_name )z
 order by 2 desc, 3
/


