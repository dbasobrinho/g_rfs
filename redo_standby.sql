--
set pages 1000
set lines 1000
column group format a1
column status     format a16
column STATUS_FILE     format a16
column type       format a10
column member     format a50
column arc        format a4
column THREAD     format 999999
column is_rec     format a10 
SELECT THREAD#,GROUP#,SEQUENCE#,ARCHIVED,STATUS FROM V$STANDBY_LOG
order by 1,2
/


