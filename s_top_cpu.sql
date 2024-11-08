--sess_top_cpu.sql
set pages 1000 
set lines 1000
col session_status   format a9 
col oracle_username  format a20
col os_username      format a20 
col os_pid           format a15 
col session_program  format a35 
col session_machine  format a25 

select z.*
from(
SELECT s.sid sid
      ,s.serial# serial_id
      ,lpad(s.status, 9) session_status
      ,lpad(s.username, 20) oracle_username
      ,lpad(s.osuser, 20) os_username
      ,lpad(p.spid, 15) os_pid
      ,lpad(s.program, 35) session_program
      ,lpad(s.machine, 25) session_machine
      ,sstat.value cpu_value
  FROM v$process  p
      ,v$session  s
      ,v$sesstat  sstat
      ,v$statname statname
 WHERE p.addr = s.paddr
   AND s.sid = sstat.sid
   AND statname.statistic# = sstat.statistic#
   AND statname.name = 'CPU used by this session'
 ORDER BY s.status, cpu_value DESC ) z
 where rownum <= &menor_igual_rownum
/

