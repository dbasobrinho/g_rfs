-- -----------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 200

COLUMN table_owner FORMAT A15
COLUMN index_owner FORMAT A15
COLUMN index_type FORMAT A10
COLUMN tablespace_name FORMAT A20


SELECT table_owner,
       table_name,
       owner AS index_owner,
       index_name,
       (SELECT TRUNC(sum(s.bytes)/1024/1024) mb
          from dba_segments s
         where s.segment_name = h.index_name
           and   s.owner      = h.owner
           and   s.segment_type in ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')) size_mb,
       tablespace_name,
       num_rows,
       status,
       index_type
FROM   dba_indexes H
WHERE  table_owner = DECODE(UPPER('&owner_ALL'), 'ALL', table_owner, UPPER('&owner_ALL'))
and table_owner not in ('SYS', 'SYSTEM')
ORDER BY table_owner, table_name, index_owner, index_name;


