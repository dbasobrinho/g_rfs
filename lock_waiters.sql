SET LINESIZE 500
SET PAGESIZE 1000
col WAITING_SESSION format 999999
col HOLDING_SESSION format 999999
col LOCK_TYPE       format A20
col MODE_HELD       format A30
col MODE_REQUESTED  format A30
col LOCK_ID1        format 999999
col LOCK_ID2        format 999999

select * from dba_waiters
/
