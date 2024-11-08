--
set pages 5000
set lines 5000
column total_arch     format 999999

select trunc(x.first_time) first_time
      ,count(x.SEQUENCE#) total_arch
  from v$archived_log x
 group by trunc(x.first_time)
 order by trunc(x.first_time) asc;
/

