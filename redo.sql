--
set pages 1000
set lines 1000
column group format a1
column status     format a16
column STATUS_FILE     format a16
column type       format a10
column member     format a70
column arc        format a4
column THREAD     format 999999
column is_rec     format a10 
select b.THREAD# as THREAD, a.group#, a.type, b.status, a.STATUS as STATUS_FILE,
       a.member, a.is_recovery_dest_file as is_rec,
       b.bytes/1024/1024 mb, b.members, b.ARCHIVED arc
from v$logfile a, v$log b
where a.group# = b.group#
union all
select b.THREAD# as THREAD, a.group#, a.type, b.status, a.STATUS as STATUS_FILE,
       a.member, 
	   a.is_recovery_dest_file as is_rec,
       b.bytes/1024/1024 mb, 
	  null members, 
	   b.ARCHIVED arc
from v$logfile a,  V$STANDBY_LOG b
where a.group# = b.group#
order by type, 1,2
/

