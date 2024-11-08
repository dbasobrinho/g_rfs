-- |----------------------------------------------------------------------------|
-- | Objetivo   : VIZULIZAR SIZE TABELA E SEUS INDEXES                          |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 07/10/2020                                                    |
-- | Exemplo    : @table_size_group_type_by SYS IDL_UB1$                        |
-- | Arquivo    : table_size_group_type_by.sql                                  |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+

set pagesize 1000
set linesize 500
set feedback off
COLUMN owner       FORMAT A12
COLUMN NAME        FORMAT A32
COLUMN OBJECT_NAME FORMAT A32
COLUMN type       FORMAT A32
COLUMN SIZE_MB    FORMAT  9999999.99
COLUMN SIZE_GB    FORMAT  9999999999
COLUMN Percent    FORMAT  999
set verify off

SELECT
   segment_type as type,
   owner, 
   table_name as name, 
   TRUNC(sum(bytes)/1024/1024) SIZE_MB,
   TRUNC(sum(bytes)/1024/1024/1024) SIZE_GB,
   ROUND( ratio_to_report( sum(bytes) ) over () * 100) Percent
FROM
(SELECT segment_type, segment_name table_name, owner, bytes
 FROM dba_segments
 WHERE segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
 UNION ALL
 SELECT s.segment_type, i.table_name, i.table_owner as owner, s.bytes
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
 UNION ALL
 SELECT s.segment_type, l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
 UNION ALL
 SELECT s.segment_type, l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX')
WHERE owner    = nvl(upper('&1'),owner)
and table_name IN ('&2')
GROUP BY table_name, owner, segment_type
HAVING SUM(bytes)/1024/1024 > 0  /* Ignore really small tables */
ORDER BY SUM(bytes) desc
/
UNDEF 1
UNDEF 2
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;