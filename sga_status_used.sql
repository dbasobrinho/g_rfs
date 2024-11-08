set lines 200
set pages 300
BREAK ON x SKIP 2 ON REPORT 
COMPUTE SUM OF  MB   ON report
col name format a40 
select name, (bytes/1024/1024) as MB 
from v$sgastat 
order by bytes
/ 
set head off
select 'total of SGA MB  '||to_char(sum(bytes)/1024/1024 )
from v$sgastat
/
set head on