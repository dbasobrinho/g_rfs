set pagesize 1000 
set linesize 500
set feedback off
column tablespace_name format  a30       heading 'Tablespace Name'
column size_mb         format  99999999  heading 'Size(MB)' 
column used_mb         format  99999999  heading 'Used(MB)' 
column free_mb         format  99999999  heading 'Free(MB)' 
column perc_free       format  99999999  heading '% Free' 
column perc_used       format  99999999  heading '% Used'
column resize_tot      format  99999999  heading 'ResizeTot(MB)'  
column resize_more     format  99999999  heading 'Resize+(MB)'       
select z.*
     , case when z.perc_used > 69 then ((z.used_mb*100) /64) end as resize_tot
	 , case when z.perc_used > 69 then ((z.used_mb*100) /64)-size_mb end as resize_more
from(
select df.tablespace_name
      ,df.bytes / (1024 * 1024) size_mb
      ,(df.bytes / (1024 * 1024)) - (sum(fs.bytes) / (1024 * 1024)) used_mb
      ,sum(fs.bytes) / (1024 * 1024) free_mb 
      ,nvl(round(sum(fs.bytes) * 100 / df.bytes), 1) perc_free
      ,round((df.bytes - sum(fs.bytes)) * 100 / df.bytes) perc_used
 from dba_free_space fs
    ,(select tablespace_name
            ,sum(bytes) bytes
       from dba_data_files
      group by tablespace_name) df
 where fs.tablespace_name(+) = df.tablespace_name
   and df.tablespace_name    = '&TABLESPACE_NAME'
 group by df.tablespace_name ,df.bytes) z
 /