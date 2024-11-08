------
set pages 5000
set lines 5000
column username format a30
column owner    format a15
column obj_name format a33
column extended_timestamp format a35
column dt_extended_time format a21
select username,
       to_char(extended_timestamp,'dd/mm/yyyy hh24:mi:ss') dt_extended_time,
       nvl(owner,'-') owner,
       nvl(obj_name,'-') obj_name,
       action_name
from   dba_audit_trail
where extended_timestamp > sysdate -1
order by extended_timestamp
/