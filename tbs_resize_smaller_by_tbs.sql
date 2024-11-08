set pagesize 1000
set linesize 500
column command          format  a100      heading 'Command Resize'
column mb_datafile_tot  format  a8        heading 'Datafile|Used(MB)'
column mb_datafile_free format  a8        heading 'Datafile|Free(MB)'
column perc_free        format  a8        heading 'Reduce|Size(%)'
--
select a.command, a.mb_datafile_tot, a.mb_datafile_free, a.perc_free||'%' as perc_free
from(
select y.command, to_char(y.mb_datafile_tot)||'mb' mb_datafile_tot, to_char(y.mb_datafile_free)||'mb' mb_datafile_free
     , (trunc((mb_datafile_free*100) / y.mb_datafile_tot)) perc_free, trunc(mb_datafile_free) a, trunc(y.mb_datafile_tot) b
from(
select 'alter database datafile ' || '''' || z.name || '''' || ' resize ' || to_char(z.mb_datafile - z.mbytes) || 'M;' as command,
 z.mb_datafile as mb_datafile_tot , z.mbytes as mb_datafile_free
  from (select /*+ rule */
         a.tablespace_name
        ,a.file_id
        ,c.name
        ,trunc(c.bytes / 1024 / 1024) mb_datafile
        ,trunc(sum(a.bytes / 1024 / 1024)) mbytes
          from dba_free_space a
              ,(select tablespace_name,file_id,max(block_id) blockid
                  from dba_extents
                 where tablespace_name <> 'SYSTEM'
                 group by tablespace_name ,file_id) b
              ,v$datafile c
         --     ,dba_data_files df
         where a.tablespace_name = b.tablespace_name
           and a.tablespace_name <> 'SYSTEM'
           and b.tablespace_name <> 'SYSTEM'
         --  and b.tablespace_name = df.tablespace_name(+)
           and a.file_id         = b.file_id
           and a.block_id        > b.blockid
           and a.bytes / 1024 / 1024 >= 1
           and c.file#           = a.file_id
		   and a.tablespace_name = '&enter_tbs_name'
         group by a.tablespace_name,a.file_id ,c.name ,c.bytes / 1024 / 1024 ) z
 where z.mb_datafile - mbytes > 0
   and z.mbytes      > 10
   and z.mb_datafile > 101) y order by 4 desc) a
 /
 
