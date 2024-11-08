set lines 400
set pages 100
col command format a140
--col lw for a2
select '!'||'ps -ef | grep oracle'||instance_name||' | grep LOCAL=NO| grep -v YES| grep -v grep | awk ''{print "kill -9 "$2}'' ' command
from v$instance
/
