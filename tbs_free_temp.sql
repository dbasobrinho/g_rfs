set pagesize 1000
set linesize 500
set feedback off
column tablespace_name format  A29
column gb_used format   A15
column gb_total format  A15
column perc_used format A11

select a.tablespace_name ,
       to_char(nvl(a.used, 0) / 1024 / 1024 /1024, 'fm999,999,990.00') gb_used,
       to_char(a.total / 1024 / 1024 /1024, 'fm999,999,990.00') gb_total,
       to_char(nvl(used, 0) * 100 / total, 'fm990.00') || '%' perc_used
  from (select tablespace_name,
               block_size,
               (select sum(v$sort_usage.blocks * block_size)
                  from v$sort_usage
                 where v$sort_usage.tablespace =
                       dba_tablespaces.tablespace_name) used,
               (select sum(bytes)
                  from dba_temp_files
                 where tablespace_name = dba_tablespaces.tablespace_name) total
          from dba_tablespaces
         where contents = 'TEMPORARY') a;


