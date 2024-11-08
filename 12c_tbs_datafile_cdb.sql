-- |----------------------------------------------------------------------------|
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
COLUMN current_instance_nt NEW_VALUE current_instance_nt NOPRINT;
SELECT rpad(instance_name, 17) current_instance, instance_name current_instance_nt FROM v$instance;
SET TERMOUT ON;
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Ver datafiles de todos os containers                        |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET PAGESIZE    1000
SET LINESIZE    500
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR           COLUMNS
CLEAR           BREAKS
CLEAR           COMPUTES
COLUMN FILE_NAME      FORMAT  A90       HEADING 'FILE|NAME'
COLUMN BYTES_MB       FORMAT  99999999  HEADING 'SIZE|MB'
COLUMN MAXBYTES_MB    FORMAT  99999999  HEADING 'MAX SIZE|MB'
COLUMN AUTOEXTENSIBLE FORMAT  A10       HEADING 'EXTENSIBLE|' 
COLUMN INCREMENT_BY   FORMAT  99999999  HEADING 'INCREMENT|MB'
COLUMN ONLINE_STATUS  FORMAT  A10       HEADING 'STATUS'
COLUMN FILE_ID        FORMAT  999999    HEADING 'FILE|ID'
COLUMN CON_ID         FORMAT  999       HEADING 'CONTAINER|ID'
select x.con_id
      ,x.file_id
      ,x.file_name
      ,bytes / (1024 * 1024)      bytes_mb
      ,x.maxbytes / (1024 * 1024) maxbytes_mb
      ,x.autoextensible 
      ,x.increment_by  / (1024 * 1024) increment_by
      ,x.online_status
  from cdb_data_files x
 order by x.con_id, x.file_id
 /
