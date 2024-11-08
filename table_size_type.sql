--A

SET PAGESIZE            1000 
SET LINESIZE            230
set feedback off
COLUMN TABLE_NAME FORMAT  A32
COLUMN OBJECT_NAME FORMAT A32
COLUMN OWNER FORMAT       A10
COLUMN TIPO  FORMAT       A12
COLUMN SIZES FORMAT A10   HEADING  "SIZE"   


SELECT Y.TIPO, Y.owner, Y.table_name, dbms_xplan.format_size(Y.bytes_OBJ) SIZES, Y.Percent
FROM(
SELECT
   Z.tp AS TIPO,
   Z.owner, 
   Z.table_name, 
   sum(Z.bytes) bytes_OBJ,
   ROUND( ratio_to_report( sum(bytes) ) over () * 100) Percent
FROM
(SELECT 'SEGMENT' as tp, segment_name table_name, owner, bytes
 FROM dba_segments
 WHERE segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
 UNION ALL
 SELECT 'INDEX' as tp, i.table_name, i.table_owner as owner, s.bytes
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
 UNION ALL
 SELECT 'LOBSEGMENT' as tp, l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
 UNION ALL
 SELECT 'LOBINDEX' as tp, l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX') Z
WHERE owner    = nvl(upper('&owner'),owner)
and table_name IN ('&table_name') 
GROUP BY Z.table_name, Z.owner, Z.tp
ORDER BY SUM(bytes) desc ) Y
/

