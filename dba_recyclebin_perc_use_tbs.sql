col "User" format a20
col "Tablespace Name" format a20
set lines 150
with rec_bytes as
(select (sum(space)*(select value from v$parameter where name='db_block_size'))/1024/1024/1024 gb,owner,ts_name from dba_recyclebin group by owner,ts_name order by 1 desc)
select owner "User", ts_name "Tablespace Name",bytes_in_kb "Space Consumption(KB)",(select sum(a.bytes)/1024 from dba_data_files a where a.tablespace_name=ts_name) "Size of Tablespace(KB)",
ceil((gb/(select sum(a.bytes)/1024/1024/1024 from dba_data_files a where a.tablespace_name=ts_name))*100) "Percent Usage(%)"
from rec_bytes where gb>0 order by 3 desc
/

