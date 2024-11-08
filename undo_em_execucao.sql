-- -----------------------------------------------------------------------------------
set pages 1000
set lines 1000
col "SID/SERIAL" format a13 
col user_name format a20
col opid format a4
col sql_text format a108

select b.sid || ',' || b.serial# "sid/serial"
      ,c.user_name
      ,a.used_ublk
      ,b.status
      ,c.sql_text
  from v$transaction a
  join v$session b on a.ses_addr = b.saddr
  join v$open_cursor c on b.saddr = c.saddr
