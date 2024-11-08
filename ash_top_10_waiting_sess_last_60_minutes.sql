--ash_find session_detail_by_sid.sql
select  serial#,
 username,
 osuser,
 machine,
 program,
 resource_consumer_group,
 client_info
from v$session where sid=&sid
/
