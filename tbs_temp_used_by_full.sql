--
COL username     FORMAT A15
COL osuser       FORMAT A15
COL "SID/SERIAL" FORMAT A14
COL unix_pid     FORMAT A8
COL program      FORMAT A33
COL mb_temp_used FORMAT 9G999G999G999
COL machine      FORMAT A30
COL tablespace   FORMAT A15
COL sql_text     FORMAT A100
set pages 1000
set lines 1000
select distinct c.username 
                ,c.osuser
				,c.sid || ',' || c.serial#  "SID/SERIAL"
                ,b.spid "unix_pid"
                ,c.machine
                ,c.program 
                ,a.blocks * e.block_size / 1024 / 1024 mb_temp_used
                ,a.tablespace
                ,d.sql_id
				--,d.sql_text
  from v$sort_usage    a
      ,v$process       b
      ,v$session       c
      ,v$sqlarea       d
      ,dba_tablespaces e
 where c.saddr = a.session_addr
   and b.addr = c.paddr
   and c.sql_address = d.address(+)
   and a.tablespace = e.tablespace_name
/   