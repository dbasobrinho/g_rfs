prompt ##############################################################################################
prompt #################################### INSTALLATION ############################################
prompt ##############################################################################################

prompt version
select * from v$version;

prompt options
select * from v$option;

prompt database
select NAME, CREATED, RESETLOGS_TIME, LOG_MODE, DATABASE_ROLE, FORCE_LOGGING from v$database;

prompt incarnation
select * from v$database_incarnation;

prompt instance
col instance_name for a20
col host_name for a20
select * from gv$instance;

prompt parameters
select inst_id, name, value from gv$parameter where ISDEFAULT='FALSE' order by inst_id, name;

prompt ##############################################################################################
prompt #################################### FILES AND PATCHES #######################################
prompt ##############################################################################################

prompt registry
select * from dba_registry;

prompt registry history
select * from dba_registry_history;

prompt registry history
select * from dba_registry_sqlpatch;

prompt controlfiles
select * from v$controlfile;

prompt recovery area usage
column Name format a17
set line 200
set pages 200
SELECT Name, (SPACE_LIMIT/1024/1024/1024) Space_Limit_GB, round(SPACE_USED/1024/1024/1024) Space_Used_GB, round(SPACE_USED/SPACE_LIMIT*100,1) "% Used", SPACE_RECLAIMABLE, NUMBER_OF_FILES 
FROM V$RECOVERY_FILE_DEST;


SELECT (100 - sum(percent_space_used)) + sum(percent_space_reclaimable) "% Available"
FROM v$flash_recovery_area_usage;

select * from v$flash_recovery_area_usage;

prompt diskgroups
set line 200
set pages 200
col host_name format a30
col name format a30
col COMPATIBILITY for a15
col DATABASE_COMPATIBILITY for a20
select  i.host_name
,       d.name
,       d.STATE
, d.type
,       d.total_mb
,       d.free_mb
,       round(decode(d.free_mb,0,1,d.free_mb)/decode(d.free_mb,0,1,d.total_mb)*100,2) free_pct
,       100-round((decode(d.free_mb,0,1,d.free_mb)/decode(d.free_mb,0,1,d.total_mb))*100,2) used_pct
,       d.offline_disks
, d.compatibility
, d.DATABASE_COMPATIBILITY
, VOTING_FILES
from    v$asm_diskgroup d, v$instance i
where d.total_mb>0
order by name;

prompt asm disks
col path for a80
col name for a40
select GROUP_NUMBER, LABEL, PATH,  NAME, FAILGROUP, DISK_NUMBER, INCARNATION, MOUNT_STATUS, HEADER_STATUS, MODE_STATUS, STATE, REDUNDANCY, OS_MB, TOTAL_MB, FREE_MB, HOT_USED_MB, COLD_USED_MB,CREATE_DATE, MOUNT_DATE, REPAIR_TIMER, PREFERRED_READ, VOTING_FILE, FAILGROUP_TYPE
from v$asm_disk
order by HEADER_STATUS, GROUP_NUMBER, NAME;


prompt database size
select (select round(sum(bytes)/1024/1024/1024) from dba_data_files) datafiles, 
(select round(sum(bytes)/1024/1024/1024) from dba_temp_files) tempfiles, 
(select round(sum(bytes/1024/1024/1024))
from v$log l, v$logfile f
where l.GROUP#=f.GROUP#) redo_logs,
(select round(sum(bytes)/1024/1024/1024) from dba_data_files) + (select round(sum(bytes)/1024/1024/1024) from dba_temp_files) 
+(select round(sum(bytes/1024/1024/1024)) from v$log l, v$logfile f where l.GROUP#=f.GROUP#) "Size in GB" 
from dual;

prompt datafiles
select name from v$datafile;

prompt tablespaces
select v.*, d.logging, d.force_logging from v$tablespace v, dba_tablespaces d
where d.TABLESPACE_NAME=v.name;

prompt redo logs
select * from v$log;

prompt redo log files
select * from v$logfile;

prompt tablespace size and usage
col "Tablespace" for a30
set line 200 pages 200
col "Used (G)" for 999,999,990.00
col "Size (G)" for 999,999,990.00
col "Max Size (G)" for 999,999,990.00
col "Free Max (GB)" for 999,999,990.00
col "Used (Max Size) %" for 990.00
col "Used (Size) %" for 990.00
select "Tablespace","Size (G)","Used (G)", round("Used (G)"/decode("Size (G)",0,1)*100,2) "Used (Size) %","Max Size (G)",
("Size (G)"-"Used (G)") "Free GB", ("Max Size (G)"-"Used (G)") "Free Max (GB)",
       round("Used (G)"/decode("Max Size (G)",0,decode("Size (G)",0,1),"Max Size (G)")*100,2)  "Used (Max Size) %"
from (	
SELECT /*+ ordered no_merge(v) */ --v.status "Status", substr(d.file_name,1,70) "Name", d.tablespace_name "Tablespace", TO_CHAR(NVL(d.bytes / 1024 / 1024, 0), '9999990.00') "Size (G)",
     d.tablespace_name "Tablespace",substr(d.file_name,1,70) "Name",
     round((sum(d.bytes)/1024/1024/1024),2) "Size (G)",
     round(sum(NVL((d.bytes - NVL(s.bytes, 0))/1024/1024/1024, 0)),2) "Used (G)",
     round(sum(NVL((d.bytes - NVL(s.bytes, 0)) / d.bytes * 100, 0)),2) "Used %" ,
     round(sum(NVL((nvl(d.bytes,0) - NVL(s.bytes, 0)) / decode(d.maxbytes,0,(nvl(d.bytes,0) - NVL(s.bytes, 0))  ,null,1,d.maxbytes) * 100, 0)),2) "Used2 %" ,
     round(sum(NVL(decode(d.maxbytes,0,d.bytes,d.maxbytes)/1024/1024/1024, 0)),2) "Max Size (G)",
     round(sum(NVL(d.increment_by*v.BLOCK_SIZE/1024, 0)),2) "Next Size (G)"
  FROM sys.dba_data_files d, v$datafile v,
   (SELECT file_id, SUM(bytes) bytes
   FROM sys.dba_free_space
   GROUP BY file_id) s
  WHERE (s.file_id (+)= d.file_id)
AND (d.file_name = v.name)
	group by rollup(d.tablespace_name,d.file_name)
union
SELECT /*+ ordered no_merge(v) */ 
     d.tablespace_name "Tablespace",
     substr(d.file_name,1,70) "Name",
     round((sum(d.bytes)/1024/1024/1024),2) "Size (G)",
     round(sum(NVL(s.bytes,0))/1024/1024/1024,2) "Used (G)" ,
     round(sum(s.bytes / d.bytes) * 100,2) "Used %" ,
     --round(sum(NVL((nvl(d.bytes,0) - NVL(s.bytes, 0)) / decode(d.maxbytes,0,(nvl(d.bytes,0) - NVL(s.bytes, 0)), null, 1, d.maxbytes) * 100, 0)),2) "Used2 %" ,
     round(sum(NVL((NVL(s.bytes, 0)) / decode(nvl(d.maxbytes,nvl(d.bytes,1)),0,1,d.maxbytes) * 100, 0)),2) "Used2 %" ,
     round(sum(NVL(decode(d.maxbytes,0,d.bytes,d.maxbytes)/1024/1024/1024, 0)),2) "Max Size (G)",
     round(sum(NVL(d.increment_by*v.BLOCK_SIZE/1024/1024/1024, 0)),2) "Next Size (G)"
  FROM dba_temp_files d, v$tempfile v,
       (select file_id, sum(bytes_cached) bytes
          from v$temp_extent_pool 
         group by file_id) s
 WHERE (s.file_id (+) = d.file_id)
   AND (d.file_name = v.name)
group by rollup (d.TABLESPACE_NAME, d.FILE_NAME))
where "Name" is null 
	and "Tablespace" is not null
	order by 1;
	
Prompt SYSAUX components usage
col OCCUPANT_NAME for a40
select OCCUPANT_NAME, OCCUPANT_DESC, SCHEMA_NAME, round(SPACE_USAGE_KBYTES/1024,2) SPACE_USAGE_MB from V$SYSAUX_OCCUPANTS;


prompt datafile size
set line 200
set pages 200
col "Status" for a9
col "Name" format a70
col "Tablespace" format a25
col size_mb format 999,999,990.00
col "Used (M)" format 999,999,990.00
col "Used %" format 990.00
col "Next Size (M)" format 999,999,990.00
col "Max Size (M)" format 999,999,990.00
col "Autoextend" for a4
col size_mb format 999,999,990.00
col used_mb format 999,999,990.00
COL FILE_NAME FOR A80
select * from (
 SELECT /*+ ordered no_merge(v) */ v.status , substr(d.file_name,1,70) file_name, d.tablespace_name , round(NVL(d.bytes / 1024 / 1024, 0),2) size_mb , 
        round(NVL((d.bytes - NVL(s.bytes, 0))/1024/1024, 0),2) used_mb, 
        round(NVL((d.bytes - NVL(s.bytes, 0)) / d.bytes * 100, 0),2) "Used %" ,
        round(NVL(d.maxbytes/1024/1024, 0),2) "Max Size (M)", 
        round(NVL(d.increment_by*v.BLOCK_SIZE/1024/1024, 0),2) "Next Size (M)" , 
        NVL(d.autoextensible, 'NO') Autoextend
 FROM sys.dba_data_files d, v$datafile v, 
      (SELECT file_id, SUM(bytes) bytes  
      FROM sys.dba_free_space  
      GROUP BY file_id) s 
 WHERE (s.file_id (+)= d.file_id) 
   AND (d.file_name = v.name) 
 UNION ALL 
 SELECT /*+ ordered no_merge(v) */ v.status , substr(d.file_name,1,70) file_name, d.tablespace_name "Tablespace", round(NVL(d.bytes / 1024 / 1024, 0),2) size_mb , 
        round(NVL(t.bytes_used/1024/1024, 0),2)  used_mb, 
        round(NVL(t.bytes_used / d.bytes * 100, 0), 2) "Used %" ,
        round(NVL(d.maxbytes/1024/1024, 0),2) "Max Size (M)", 
        round(NVL(d.increment_by/1024/1024, 0),2) "Next Size (M)"  , 
        NVL(d.autoextensible, 'NO') Autoextend
   FROM sys.dba_temp_files d, v$temp_extent_pool t, v$tempfile v 
  WHERE (t.file_id (+)= d.file_id) AND (d.file_id = v.file#))
  order by tablespace_name, file_name;

prompt archive volume
col "Size (MB)" format 999,999,999,999,999
SELECT trunc(first_time) data , thread#,  count(1) qtd, round(sum(blocks*block_size)/1024/1024) "Size (MB)"
        FROM gv$archived_log
        WHERE dest_id = 1
        GROUP BY trunc(first_time), thread#
       ORDER BY 1 DESC ,2 ;


prompt ##############################################################################################
prompt ########################################### BACKUP ###########################################
prompt ##############################################################################################
prompt Block change tracking
SELECT * FROM v$block_change_tracking;

prompt corrupted blocks
select FILE#, BLOCK#, BLOCKS from v$database_block_corruption;

prompt unrecoverable backup
col name for a100
select df.name, df.unrecoverable_time 
from v$datafile df, v$backup bk
where df.file#=bk.file# 
and df.unrecoverable_change# <> 0
and df.unrecoverable_time > (select max(end_time)
                               from v$rman_backup_job_details
                              where input_type in ('DB FULL' ,'DB INCR') );

prompt unrecoverable file before last full backup
select df.name, df.unrecoverable_time 
from v$datafile df, v$backup bk 
where df.file#=bk.file# 
and df.unrecoverable_change# <> 0;


prompt nologging objects
col OWNER for a20
col TABLE_NAME for a30
select 'TABLE' TTYPE, OWNER, TABLE_NAME
FROM DBA_TABLES
WHERE LOGGING='NO'
ORDER BY  OWNER, TABLE_NAME;
--
select 'TAB PARTITION' TYPE, TABLE_OWNER, TABLE_NAME, PARTITION_NAME
FROM DBA_TAB_PARTITIONS
WHERE LOGGING='NO'
ORDER BY TABLE_OWNER, TABLE_NAME, PARTITION_NAME;
--
select 'TAB SUBPARTITION' TYPE, TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME
FROM DBA_TAB_SUBPARTITIONS
WHERE LOGGING='NO'
ORDER BY  TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME;
--
select 'INDEX' TYPE, TABLE_OWNER, TABLE_NAME, OWNER, INDEX_NAME
FROM DBA_INDEXES
WHERE LOGGING='NO'
ORDER BY TABLE_OWNER, TABLE_NAME, OWNER, INDEX_NAME;
--
select 'INDEX PARTITION' TYPE, INDEX_OWNER, INDEX_NAME, PARTITION_NAME
FROM DBA_IND_PARTITIONS
WHERE LOGGING='NO'
ORDER BY INDEX_OWNER, INDEX_NAME, PARTITION_NAME;
--
select 'INDEX SUBPARTITION' TYPE, INDEX_OWNER, INDEX_NAME, PARTITION_NAME
FROM DBA_IND_SUBPARTITIONS
WHERE LOGGING='NO'
ORDER BY INDEX_OWNER, INDEX_NAME, PARTITION_NAME;
--
select 'LOB' TYPE, OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME
FROM DBA_LOBS
WHERE LOGGING='NO'
ORDER BY OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME;
--
select 'LOB PARTITION' TYPE, TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, PARTITION_NAME
FROM DBA_LOB_PARTITIONS
WHERE LOGGING='NO'
ORDER BY TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, PARTITION_NAME;
--
select 'LOB' TYPE, TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_PARTITION_NAME, SUBPARTITION_NAME
FROM DBA_LOB_SUBPARTITIONS
WHERE LOGGING='NO'
ORDER BY TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_PARTITION_NAME, SUBPARTITION_NAME;



prompt backup
col INSTANCE for a20
col ELAPSED for a30
col output_mb for a15
col MB_S for a10
col ELAPSED for a15
col STATUS for a20
col INPUT_TYPE for a15
        SELECT (  SELECT   instance_name FROM v$instance)
              || ' '
              || (  SELECT   instance_number FROM v$instance)
                 instance,
       to_date (start_time, 'DD-MM-YYYY HH24:MI:SS') start_time,
       end_time,
              TO_CHAR (output_bytes / 1048576, '999,999,999.9') output_mb,
              TO_CHAR (output_bytes_per_sec / 1048576, '999,999.9') mb_S,
              time_taken_display elapsed,input_type,status
         FROM v$rman_backup_job_details
         ORDER BY start_time;


prompt ##############################################################################################
prompt ######################################## PERFORMANCE #########################################
prompt ##############################################################################################

prompt memory parameters
select name, value from gv$parameter where name like '%target%';

prompt pga advice 
select pga_target_for_estimate,pga_target_factor,estd_extra_bytes_rw from v$pga_target_advice;


prompt sga advice
select sga_size,sga_size_factor,estd_db_time from v$sga_target_advice;


prompt memory advice
select memory_size,memory_size_factor,estd_db_time from v$memory_target_advice;

col perc_time_waited for 90.00
prompt wait class statistics
SELECT inst_id,
    wait_class,
    begin_time, 
  ROUND(AVG(time_waited_sec / total_time_waited_sec) * 100, 2) perc_time_waited
FROM
  (SELECT h.inst_id,
    c.wait_class,
    begin_time,
    h.dbtime_in_wait,
    h.time_waited    /100 time_waited_sec,
    SUM(h.time_waited/100) OVER (PARTITION BY h.inst_id, h.end_time) total_time_waited_sec
  FROM gv$system_wait_class c
  JOIN gv$waitclassmetric_history h
  ON (c.inst_id       = h.inst_id
  AND c.wait_class_id = h.wait_class_id)
  WHERE
    h.begin_time >= (sysdate - interval '120' minute)
    and h.begin_time <= (sysdate - interval '0' minute)
    order by h.inst_id, begin_time, c.wait_class
  ) wc
  group by inst_id,begin_time, cube (wait_class)
   order by inst_id,begin_time,wait_class;

prompt processes and sessions
SELECT inst_id, resource_name, CURRENT_UTILIZATION, MAX_UTILIZATION, LIMIT_VALUE, round(100*DECODE(initial_allocation, ' UNLIMITED', 0, current_utilization)/limit_value,2) "Current Utilization %", round(100*DECODE(MAX_UTILIZATION, ' UNLIMITED', 0, MAX_UTILIZATION)/limit_value,2) "Max Utilization %" 
from Gv$resource_limit r
where 100*DECODE(initial_allocation, ' UNLIMITED', 0, current_utilization) != '0' 
    AND resource_name in ('processes','sessions');

col BEGIN_INTERVAL_TIME for a30
col END_INTERVAL_TIME for a30
col RESOURCE_NAME for a20
select a.instance_number,
   a.begin_interval_time,
   a.end_interval_time,
   b.resource_name,
   b.current_utilization,
   b.max_utilization,
   round(b.current_utilization/b.max_utilization*100,2) pct_utilization
from
   dba_hist_resource_limit b,
   dba_hist_snapshot a
where  a.snap_id = b.snap_id
  and lower(b.resource_name) in ('processes','sessions')
  and a.instance_number=b.instance_number
  and a.begin_interval_time >= sysdate-30
  and b.current_utilization/b.max_utilization > 0.9
order by b.current_utilization/b.max_utilization;

prompt ##############################################################################################
prompt ########################################### OTHER ############################################
prompt ##############################################################################################

prompt partitioned objects
col tablespace_name format a20
col num_rows format 999,999,999
select * from (
select	p.partition_name
,	p.tablespace_name
,	p.num_rows
,	ceil(s.bytes / 1024 / 1204) mb
from	dba_tab_partitions p
,	dba_segments s
where	p.table_owner = s.owner
and	p.partition_name = s.partition_name
and 	p.table_name = s.segment_name
order by bytes desc)
where rownum < 50;

prompt segments size
select * from (
select sum(bytes)/1024/1024/1024 size_gb, segment_type, segment_name 
from dba_segments
group by segment_type, segment_name 
order by sum(bytes))
where rownum < 50;

prompt invalid objects
select owner, object_name, object_type, status from dba_objects where status <> 'VALID';


prompt recycle bin
select  OWNER, OBJECT_NAME, ORIGINAL_NAME, OPERATION, TYPE, TS_NAME, CREATETIME, DROPTIME
from dba_recyclebin
order by droptime;



prompt ##############################################################################################
prompt ########################################### ERRORS ###########################################
prompt ##############################################################################################

prompt database erros on log from last 60 days

col "inst_name" for a10
col MESSAGE_TEXT for a70
col "DATE" for a18
select i.instance_number as inst_id, i.instance_name as inst_name, x.MESSAGE_TEXT
,	to_char(x.ORIGINATING_TIMESTAMP, 'yyyy/mm/dd hh24:mi') "DATE"
from X$DBGALERTEXT x, GV$INSTANCE i
where trunc(x.ORIGINATING_TIMESTAMP) >=  trunc(sysdate-90)
and x.MESSAGE_TEXT like '%ORA-%' or message_text like '%cannot allocate%'
order by i.inst_id, x.ORIGINATING_TIMESTAMP ;


exit;
