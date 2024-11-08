-- -----------------------------------------------------------------------------------
-- file name    : https://oracle-base.com/dba/monitoring/db_info.sql
-- author       : tim hall
-- description  : displays general information about the database.
-- requirements : access to the v$ views.
-- call syntax  : @db_info
-- last modified: 15/07/2000
-- -----------------------------------------------------------------------------------
prompt ********* ps -ef |grep pmon
!ps -ef |grep pmon
prompt ********* pmon
prompt 
set pagesize 1000
set linesize 150
set feedback off

column name          format a10
column created       format a22
column log_mode      format a15
column open_mode     format a10
column flashback_on  format a10
column platform_name format a30
select name
      ,created
      ,log_mode
      ,open_mode
      ,flashback_on
      ,platform_name
from   v$database;
prompt ********* database
--
col "database Size" format a20
col "free space" format a20
col "used space" format a20
select round(sum(used.bytes) / 1024 / 1024 / 1024) || ' GB' "database Size"
       ,round(sum(used.bytes) / 1024 / 1024 / 1024) -
       round(free.p / 1024 / 1024 / 1024) || ' GB' "used space"
       ,round(free.p / 1024 / 1024 / 1024) || ' GB' "free space"
  from (select bytes
          from v$datafile
        union all
        select bytes
          from v$tempfile
        union all
        select bytes from v$log) used
      ,(select sum(bytes) as p from dba_free_space) free
 group by free.p;
prompt ********* size


column instance_name format a13
column db_status     format a10
column version       format a10
column host_name     format a17
column startup_time  format a22
select upper(instance_name) instance_name
      ,upper(host_name) host_name
      ,version
      ,to_char(startup_time, 'dd-mon-yyyy hh24:mi:ss') startup_time
      ,status
      ,archiver
      ,logins
      ,database_status db_status
  from v$instance;
prompt ********* instance


column banner        format a78
column con_id        format a15
select * from v$version;
prompt ********* version

column name        format a20
column value       format a15
select a.name
      ,lpad(to_char(round(a.value, 5), '99999999990.00'), 15, ' ') value
  from v$sga a;
prompt ********* sga

select substr(c.name, 1, 60) "controlfile"
       ,nvl(c.status, 'unknown') "status"
  from v$controlfile c
 order by 1;
prompt ********* controlfile

select substr(d.name, 1, 60) "datafile"
       ,nvl(d.status, 'unknown') "status"
       ,d.enabled "enabled"
       ,lpad(to_char(round(d.bytes / 1024000, 2), '9999990.00'), 10, ' ') "size(mb)"
  from v$datafile d
 order by 1;
prompt ********* datafile

select l.group# "group"
       ,substr(l.member, 1, 60) "logfile"
       ,nvl(l.status, 'unknown') "status"
  from v$logfile l
 order by 1,2;
prompt ********* logfile

column "tablespace"           format a20
select size_allocated.tablespace_name   "tablespace"
      ,size_allocated.size_allocated_mb as "size_allocated(mb)"
      ,size_used.size_used_mb as "size_used(mb)"
      ,100-round(size_used.size_used_mb / size_allocated.size_allocated_mb * 100,2) "% free"
      ,round(size_used.size_used_mb / size_allocated.size_allocated_mb * 100,2) "% used"
  from (select due.tablespace_name
              ,sum(due.bytes) / 1024 / 1024 as size_used_mb
          from dba_undo_extents due
         group by due.tablespace_name) size_used
      ,(select dt.tablespace_name
              ,sum(ddf.bytes) / 1024 / 1024 size_allocated_mb --, ddf.file_name
          from dba_tablespaces dt
              ,dba_data_files  ddf
         where dt.tablespace_name = ddf.tablespace_name
           and dt.contents = upper('undo')
         group by dt.tablespace_name) size_allocated
 where size_allocated.tablespace_name = size_used.tablespace_name(+)
 order by 1;
prompt ********* undo


column tablespace                format a18
select /* + rule */
 df.tablespace_name "tablespace"
 ,df.bytes / (1024 * 1024) "size(mb)"
 ,sum(fs.bytes) / (1024 * 1024) "free(mb)"
 ,nvl(round(sum(fs.bytes) * 100 / df.bytes,2), 1) "% free"
 ,round((df.bytes - sum(fs.bytes)) * 100 / df.bytes,2) "% used"
  from dba_free_space fs
      ,(select tablespace_name
              ,sum(bytes) bytes
          from dba_data_files
         group by tablespace_name) df
 where fs.tablespace_name(+) = df.tablespace_name
 group by df.tablespace_name
         ,df.bytes;
prompt ********* tablespace


column name          format a25
column value         format a60
select v.name, v.value 
from v$parameter v
where v.name = 'background_dump_dest';
prompt ********* alertlog
prompt
archive log list
prompt ********* archive
prompt
set pagesize 14
set feedback on


