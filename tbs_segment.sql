set pagesize 1000 
set linesize 500
COLUMN owner        FORMAT a9                HEADING 'Owner'
COLUMN segment_name FORMAT a30               HEADING 'Segment Name'
COLUMN segment_type FORMAT a15               HEADING 'Segment Type'
COLUMN blocks       FORMAT 999999999            HEADING 'Blocks'
COLUMN extents      FORMAT 999999999            HEADING 'Extents'
COLUMN mb           FORMAT 9,999,999,999,999  HEADING 'Size (MB)'
break on report 
compute sum of blocks on report 
compute sum of extents on report 
compute sum of mb on report 
 select owner
       ,segment_name
	   ,segment_type
       ,blocks
       ,extents
       ,bytes / (1024 * 1024) mb
   from dba_segments
  where tablespace_name = TRIM(UPPER('&TABLESPACE_NAME'))
  order by mb DESC, segment_type
/