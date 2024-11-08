--
set pages 5000
set lines 5000
column username     format a20
column audit_option format a40
column success      format a10
column failure      format a10
select user_name, audit_option, success, failure 
 from dba_stmt_audit_opts 
where  user_name = nvl(upper('&username'),user_name)
order by 1
/
