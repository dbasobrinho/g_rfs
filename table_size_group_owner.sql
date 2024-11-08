--
set pagesize 1000
set linesize 500
set feedback off
COLUMN TABLE_NAME FORMAT  A50
COLUMN OBJECT_NAME FORMAT A32
COLUMN OWNER FORMAT       A20
COLUMN Percent FORMAT     999
COLUMN Meg     FORMAT     99999999

SELECT
   owner, 
   TRUNC(sum(bytes)/1024/1024) Meg,
   ROUND( ratio_to_report( sum(bytes) ) over () * 100) Percent
FROM
(SELECT segment_name table_name, owner, bytes
 FROM dba_segments
 WHERE segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
 UNION ALL
 SELECT i.table_name, i.owner, s.bytes
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX')
         where owner not IN ('OUTLN', 'CTXSYS', 'XDB', 'WMSYS', 'SYSTEM', 'TSMSYS', 'SYSMAN', 'SYS', 'OLAPSYS', 'MDSYS', 'EXFSYS',
                             'DBSNMP', 'DMSYS', 'DW_LINK', 'SCOTT')
GROUP BY owner
HAVING SUM(bytes)/1024/1024 > 10  /* Ignore really small tables */
ORDER BY SUM(bytes) desc, 1
/
