--
set pages 5000
set lines 5000
column username       format a19
column privilege      format a50
column object         format a60
column granted_role   format a27

select GRANTEE, PRIVILEGE, OWNER, TABLE_NAME
from   dba_tab_privs tp
where  tp.TABLE_NAME = '&ENTER_OBJECT_NAME'
order by OWNER, TABLE_NAME
/