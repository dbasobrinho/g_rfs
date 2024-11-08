--
set pages 5000
set lines 5000
col total_arch    format 999999
col THREAD#       for 999999999  head 'Thread'
col seq           for 999999999  head 'Sequence#'
col first_time    for a20 head 'First Time'
col name          for a20 head 'Name'

column autoextensible  format  a10       heading 'EXTENSIBLE' 

select x.THREAD#
      ,x.SEQUENCE# seq
      ,TO_CHAR(x.first_time, 'DD-MON-YYYY HH24:MI:SS') first_time
      ,x.name
  from gv$archived_log x
  where x.first_time >= sysdate-&days
order by x.THREAD#, seq asc
/

