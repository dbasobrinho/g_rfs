--
set pages 5000
set lines 5000
column user_name     format a20
column privilege     format a40
column success       format a10
column failure       format a10
select user_name, privilege, success, failure 
 from dba_priv_audit_opts 
where  user_name = nvl(upper('&username'),user_name)
order by 1
/


