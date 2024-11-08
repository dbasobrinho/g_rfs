-- |----------------------------------------------------------------------------|
-- | Objetivo   : VER PROPRIEDADES DA UMA TABELA                                |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 05/05/2015                                                    |
-- | Exemplo    : @dba_table_info                                               |
-- | Arquivo    : dba_table_info.sql                                            |
-- | Modificacao: 06/10/2020 - AJUSTES DE HISTORAN                              |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Relatorio: Informacoes de Tabela                                       |
PROMPT | Instancia: &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
--      dba_table_info.sql
PROMPT
ACCEPT schema     CHAR PROMPT 'Enter table owner : '
ACCEPT table_name CHAR PROMPT 'Enter table name  : '

SET ECHO        OFF
SET FEEDBACK    off
SET HEADING     ON
SET LINESIZE    600
SET LONG        9000
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | INFORMACOES BASICAS DA TABELA                                          |
PROMPT +------------------------------------------------------------------------+

COLUMN owner               FORMAT a20                   HEADING "Owner"
COLUMN table_name          FORMAT a30                   HEADING "Table Name"
COLUMN tablespace_name     FORMAT a30                   HEADING "Tablespace"
COLUMN last_analyzed       FORMAT a20                   HEADING "Last Analyzed"
COLUMN num_rows            FORMAT 9,999,999,999,999     HEADING "# of Rows"
COLUMN BLOCKS              FORMAT 9,999,999,999,999     HEADING "# of Blocks"
COLUMN PCT_FREE            FORMAT 9999                  HEADING "Pct Free"
COLUMN PCT_USED            FORMAT 9999                  HEADING "Pct Used"
COLUMN INI_TRANS           FORMAT 9999                  HEADING "Ini Trans"
COLUMN MAX_TRANS           FORMAT 9999                  HEADING "Max Trans"
COLUMN DEGREE              FORMAT a06                   HEADING "Degree"

SELECT
    owner
  , table_name
  , tablespace_name
  , num_rows
  , BLOCKS
  , PCT_FREE
  , PCT_USED
  , INI_TRANS
  , MAX_TRANS
  , trim(DEGREE) DEGREE
  , TO_CHAR(last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed  
FROM
    dba_tables
WHERE
      owner      = UPPER('&schema')
  AND table_name = UPPER('&table_name')
/

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | INFORMACOES DO OBJETO                                                  |
PROMPT +------------------------------------------------------------------------+

COLUMN object_id                                     HEADING "Object ID"
COLUMN data_object_id                                HEADING "Data Object ID"
COLUMN created             FORMAT A23                HEADING "Created"
COLUMN last_ddl_time       FORMAT A23                HEADING "Last DDL"
COLUMN status                                        HEADING "Status"

SELECT
    object_id
  , data_object_id
  , TO_CHAR(created, 'DD-MON-YYYY HH24:MI:SS')        created
  , TO_CHAR(last_ddl_time, 'DD-MON-YYYY HH24:MI:SS')  last_ddl_time
  , status
FROM
    dba_objects
WHERE
      owner       = UPPER('&schema')
  AND object_name = UPPER('&table_name')
  AND object_type = 'TABLE'
/

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | INFORMACOES DO SEGMENTO                                                |
PROMPT +------------------------------------------------------------------------+

COLUMN segment_name        FORMAT a30                HEADING "Segment Name"
COLUMN partition_name      FORMAT a30                HEADING "Partition Name"
COLUMN segment_type        FORMAT a16                HEADING "Segment Type"
COLUMN tablespace_name     FORMAT a30                HEADING "Tablespace"
COLUMN num_rows            FORMAT 9,999,999,999,999  HEADING "Num Rows"
COLUMN num_BLOCKS          FORMAT 9,999,999,999,999  HEADING "Num Blocks"
COLUMN bytes               FORMAT 9,999,999,999,999  HEADING "Bytes"
COLUMN SIZES               FORMAT A10                HEADING  "Seg_Size"    
COLUMN last_analyzed       FORMAT a23                HEADING "Last Analyzed"

SELECT
    seg.segment_name      segment_name
  , null                  partition_name
  , seg.segment_type      segment_type
  , seg.tablespace_name   tablespace_name
  , tab.num_rows          num_rows
  , tab.BLOCKS            num_BLOCKS
  , dbms_xplan.format_size(seg.bytes)             SIZES
  , TO_CHAR(tab.last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed
from
    dba_segments seg
  , dba_tables tab
WHERE
      seg.owner = UPPER('&schema')
  AND seg.segment_name = UPPER('&table_name')
  AND seg.segment_name = tab.table_name
  AND seg.owner = tab.owner
  AND seg.segment_type = 'TABLE'
UNION ALL
SELECT
    seg.segment_name      segment_name
  , seg.partition_name    partition_name
  , seg.segment_type      segment_type
  , seg.tablespace_name   tablespace_name
  , part.num_rows         num_rows
  , part.BLOCKS            num_BLOCKS
  , dbms_xplan.format_size(seg.bytes)             SIZES
  , TO_CHAR(part.last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed
FROM
    dba_segments seg
  , dba_tab_partitions part
WHERE
      part.table_owner = UPPER('&schema')
  AND part.table_name = UPPER('&table_name')
  AND part.partition_name = seg.partition_name
  AND seg.segment_type = 'TABLE PARTITION'
ORDER BY
    segment_name
  , partition_name
/


PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | COLUNAS DA TABELA                                                      |
PROMPT +------------------------------------------------------------------------+

COLUMN column_name         FORMAT a30                HEADING "Column Name"
COLUMN data_type           FORMAT a25                HEADING "Data Type"
COLUMN nullable            FORMAT a13                HEADing "Null?"

SELECT
    column_name
  , DECODE(nullable, 'Y', ' ', 'NOT NULL') nullable
  , DECODE(data_type
               , 'RAW',      data_type || '(' ||  data_length || ')'
               , 'CHAR',     data_type || '(' ||  data_length || ')'
               , 'VARCHAR',  data_type || '(' ||  data_length || ')'
               , 'VARCHAR2', data_type || '(' ||  data_length || ')'
               , 'NUMBER', NVL2(   data_precision
                                 , DECODE(    data_scale
                                            , 0
                                            , data_type || '(' || data_precision || ')'
                                            , data_type || '(' || data_precision || ',' || data_scale || ')'
                                   )
                                 , data_type)
               , data_type
    ) data_type
FROM
    dba_tab_columns
WHERE
      owner      = UPPER('&schema')
  AND table_name = UPPER('&table_name')
ORDER BY
    column_id
/ 

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | HISTOGRAMA DE COLUNAS                                                  |
PROMPT +------------------------------------------------------------------------+
COLUMN column_name         FORMAT a30                HEADING "Column|Name"             JUSTIFY CENTER
COLUMN HISTOGRAM           FORMAT a16                HEADING "Histogram|-"              JUSTIFY CENTER
COLUMN NUM_DISTINCT        FORMAT 9999999999         HEADing "Distinct|-"               JUSTIFY CENTER
COLUMN LOW_VALUE           FORMAT a5                 HEADing "Low|Value"              JUSTIFY CENTER
COLUMN HIGH_VALUE          FORMAT a5                 HEADing "High|Value"             JUSTIFY CENTER
COLUMN NUM_NULLS           FORMAT 99999999999        HEADing "Num|Nulls"              JUSTIFY CENTER
COLUMN NUM_BUCKETS         FORMAT 999999             HEADing "Num|Buckets"            JUSTIFY CENTER
COLUMN avg_col_len         FORMAT 9999               HEADing "Agv|Len"            JUSTIFY CENTER
COLUMN LAST_ANALYZED       FORMAT a19                HEADING "Last|Analyzed"           JUSTIFY CENTER
COLUMN SAMPLE_SIZE         FORMAT 99999999999        HEADING "Sample|Size"             JUSTIFY CENTER
COLUMN DENSITY             FORMAT a35                HEADING "Density|Selectivity"              JUSTIFY CENTER
col ENDPOINT_ACTUAL_VALUE      format a40            HEADING "Endpoint|Actual Value"   JUSTIFY CENTER
col TABLE_NAME                 format a18            HEADING "Table Name|-"   JUSTIFY CENTER
col OWNER                      format a08            HEADING "Owner|-"   JUSTIFY CENTER
col QTDE                       format 9999999999     HEADING "Qtde|-"   JUSTIFY CENTER
col ENDPOINT_NUMBER            format 9999999999     HEADING "Endpoint|Number" JUSTIFY CENTER
col ENDPOINT_REPEAT_COUNT      format 9999999999     HEADING "Endpoint|Repeat Count" JUSTIFY CENTER
col PERCENT                    format 000.00          HEADING "%|-" JUSTIFY CENTER

 

SELECT C.COLUMN_NAME, C.HISTOGRAM, C.NUM_DISTINCT, substr(C.LOW_VALUE,1,5) LOW_VALUE, substr(C.HIGH_VALUE,1,5) HIGH_VALUE,
           C.NUM_NULLS,
           C.NUM_BUCKETS,
		   c.avg_col_len,
           to_char(C.LAST_ANALYZED,'dd/mm/yyyy hh24:mi:ss') LAST_ANALYZED,
           C.SAMPLE_SIZE,
           TO_CHAR(C.DENSITY) AS DENSITY
  FROM dba_tab_col_statistics c --dba_TAB_COLUMNS C
 WHERE C.OWNER        = UPPER('&schema')
   AND C.TABLE_NAME  = UPPER('&table_name')
 ORDER BY 1, 2, 4
/
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | COLETA HISTOGRAMA DE COLUNAS                                           |
PROMPT +------------------------------------------------------------------------+
COLUMN COMMAND            FORMAT a170              HEADING "Command" newline
select 'exec dbms_stats.gather_table_stats (ownname=> ''&schema'',tabname=> ''&table_name'',estimate_percent =>100,method_opt=>''FOR COLUMNS <<NOME_COL>> SIZE 254'',cascade=> true,degree => 16);' COMMAND
from dual
UNION ALL
select 'exec dbms_stats.gather_table_stats (ownname=> ''&schema'',tabname=> ''&table_name'',estimate_percent =>100,method_opt=>''FOR ALL COLUMNS SIZE 254'',cascade=> true,degree => 16);' COMMAND
from dual
/


--------PROMPT
--------PROMPT +------------------------------------------------------------------------+
--------PROMPT | COLUMNS HISTOGRAM DETAILS                                              |
--------PROMPT +------------------------------------------------------------------------+
--------PROMPT
--------
--------select z.COLUMN_NAME, z.HISTOGRAM, z.NUM_DISTINCT, z.LOW_VALUE, z.HIGH_VALUE, z.ENDPOINT_NUMBER, z.ENDPOINT_NUMBER - z.lag as QTDE, 
--------TRUNC(((z.ENDPOINT_NUMBER - z.lag) * 100 )/((select max(g.ENDPOINT_NUMBER) MAX_ENDPOINT_NUMBER  from DBA_TAB_HISTOGRAMS g where g.TABLE_NAME = z.TABLE_NAME AND G.OWNER = Z.OWNER AND COLUMN_NAME = z.COLUMN_NAME)
-------- ),2)AS PERCENT
--------,
--------Z.ENDPOINT_ACTUAL_VALUE--, Z.ENDPOINT_REPEAT_COUNT
--------FROM(
--------SELECT H.OWNER, H.TABLE_NAME, H.COLUMN_NAME, C.HISTOGRAM, C.NUM_DISTINCT, C.LOW_VALUE, C.HIGH_VALUE, H.ENDPOINT_NUMBER,  LAG( ENDPOINT_NUMBER,1,0 ) OVER  ( PARTITION BY H.COLUMN_NAME ORDER BY ENDPOINT_NUMBER ) lag,
--------       H.ENDPOINT_ACTUAL_VALUE--, H.ENDPOINT_REPEAT_COUNT 
--------  FROM DBA_TAB_HISTOGRAMS H, DBA_TAB_COLUMNS C 
--------WHERE H.TABLE_NAME  = C.TABLE_NAME 
--------  AND H.COLUMN_NAME = C.COLUMN_NAME 
--------  AND H.OWNER       = C.OWNER   
-------- AND H.OWNER       = UPPER('&schema')
--------  AND h.TABLE_NAME  = UPPER('&table_name')
--------  AND HISTOGRAM    <> 'NONE' ORDER BY H.COLUMN_NAME,H.ENDPOINT_NUMBER)Z
--------/
 

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | INDEXES                                                                |
PROMPT +------------------------------------------------------------------------+

COLUMN index_name          FORMAT a45            HEADING "Index|Name"      JUSTIFY CENTER
COLUMN TABLESPACE_NAME     FORMAT a19            HEADING "Tablespace|Name"      JUSTIFY CENTER
COLUMN BLEVEL              FORMAT a05            HEADING "B|Level"          JUSTIFY CENTER
COLUMN LEAF_BLOCKS         FORMAT 999999999    HEADING "Leaf|Blocks"     JUSTIFY CENTER
COLUMN DISTINCT_KEYS       FORMAT 99999999999    HEADING "Distinct|Keys"   JUSTIFY CENTER
COLUMN PCT_FREE            FORMAT 9999           HEADING "Pct|Free"        JUSTIFY CENTER
COLUMN PCT_USED            FORMAT 9999           HEADING "Pct|Used"        JUSTIFY CENTER
COLUMN INI_TRANS           FORMAT 9999           HEADING "Ini|Trans"       JUSTIFY CENTER
COLUMN MAX_TRANS           FORMAT 9999           HEADING "Max|Trans"       JUSTIFY CENTER
COLUMN DEGREE              FORMAT A06            HEADING "Degree|"          JUSTIFY CENTER
COLUMN CLUSTERING_FACTOR   FORMAT 99999999       HEADING "Cluster|Factor"       JUSTIFY CENTER
COLUMN num_BLOCKS          FORMAT 9999999999     HEADING "Num|Blocks"     JUSTIFY CENTER
COLUMN NUM_ROWS            FORMAT 9999999999       HEADING "Num|Rows"        JUSTIFY CENTER
COLUMN LAST_ANALYZED       FORMAT a19            HEADING "Last|Analyzed"           JUSTIFY CENTER
COLUMN status              FORMAT a10            HEADING "Status|"  JUSTIFY CENTER

SELECT 
    SUBSTR(OWNER || '.' || index_name,1,45)  index_name
  , STATUS
  , substr(TABLESPACE_NAME,1,19) TABLESPACE_NAME
  , to_char(BLEVEL) BLEVEL
  , LEAF_BLOCKS
  , DISTINCT_KEYS
  , PCT_FREE
 -- , PCT_USED
  , INI_TRANS
  , MAX_TRANS
  , NUM_ROWS
  , CLUSTERING_FACTOR
  ,(select G.BLOCKS FROM DBA_TABLES G WHERE G.owner = I.table_owner AND G.TABLE_NAME = I.table_name)  AS num_BLOCKS
  , trim(DEGREE)  as DEGREE
  , to_char(LAST_ANALYZED,'dd/mm/yyyy hh24:mi:ss') LAST_ANALYZED
FROM
    dba_indexes I
WHERE
      table_owner  = UPPER('&schema')
  AND table_name   = UPPER('&table_name')
ORDER BY
    index_name
/


PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | INDEXES COLUNAS                                                        |
PROMPT +------------------------------------------------------------------------+

COLUMN index_name          FORMAT a50                HEADING "Index Name"
COLUMN column_name         FORMAT a30                HEADING "Column Name"
COLUMN column_length       FORMAT 99999999           HEADING "Column Length"
COLUMN column_position     FORMAT 99999999           HEADING "Column Position"

BREAK ON index_name SKIP 1

SELECT
    index_owner || '.' || index_name  index_name
  , column_name
  , column_length
  , column_position
FROM
    dba_ind_columns
WHERE table_owner  = UPPER('&schema')
  AND table_name   = UPPER('&table_name')
ORDER BY
    index_name
  , column_position
/

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | CONSTRAINTS                                                            |
PROMPT +------------------------------------------------------------------------+

COLUMN constraint_name     FORMAT a30                HEADING "Constraint Name"
COLUMN constraint_type     FORMAT a13                HEADING "Constraint|Type"
COLUMN search_condition    FORMAT a40                HEADING "Search Condition"
COLUMN r_constraint_name   FORMAT a40                HEADING "R / Constraint Name"
COLUMN delete_rule         FORMAT a12                HEADING "Delete Rule"
COLUMN status                                        HEADING "Status"

BREAK ON constraint_name ON constraint_type

SELECT
    a.constraint_name
  , DECODE(a.constraint_type
             , 'P', 'Primary Key'
             , 'C', 'Check'
             , 'R', 'Referential'
             , 'V', 'View Check'
             , 'U', 'Unique'
             , a.constraint_type
    ) constraint_type
  , b.column_name
  , a.search_condition
  , NVL2(a.r_owner, a.r_owner || '.' ||  a.r_constraint_name, null) r_constraint_name
  , a.delete_rule
  , a.status
FROM
    dba_constraints  a
  , dba_cons_columns b
WHERE
      a.owner            = UPPER('&schema')
  AND a.table_name       = UPPER('&table_name')
  AND a.constraint_name  = b.constraint_name
  AND b.owner            = UPPER('&schema')
  AND b.table_name       = UPPER('&table_name')
ORDER BY
    a.constraint_name
  , b.position
/


PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | PARTICOES (TABLE)                                                      |
PROMPT +------------------------------------------------------------------------+

COLUMN partition_name                                HEADING "Partition Name"
COLUMN column_name         FORMAT a30                HEADING "Column Name"
COLUMN tablespace_name     FORMAT a30                HEADING "Tablespace"
COLUMN composite           FORMAT a9                 HEADING "Composite"
COLUMN subpartition_count                            HEADING "Sub. Part.|Count"
COLUMN logging             FORMAT a7                 HEADING "Logging"
COLUMN high_value          FORMAT a13                HEADING "High Value" TRUNC

BREAK ON partition_name

SELECT
    a.partition_name
  , b.column_name
  , a.tablespace_name
  , a.composite
  , a.subpartition_count
  , a.logging
FROM
    dba_tab_partitions    a
  , dba_part_key_columns  b
WHERE
      a.table_owner        = UPPER('&schema')
  AND a.table_name         = UPPER('&table_name')
  AND RTRIM(b.object_type) = 'TABLE'
  AND b.owner              = a.table_owner
  AND b.name               = a.table_name
ORDER BY
    a.partition_position
  , b.column_position
/


PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | PARTICOES (INDEX)                                                      |
PROMPT +------------------------------------------------------------------------+

COLUMN index_name              FORMAT a50               HEADING "Index Name"
COLUMN partitioning_type       FORMAT a9                 HEADING "Type"
COLUMN partition_count         FORMAT 99999              HEADING "Part.|Count"
COLUMN partitioning_key_count  FORMAT 99999              HEADING "Part.|Key Count"
COLUMN locality                FORMAT a8                 HEADING "Locality"
COLUMN alignment               FORMAT a12                HEADING "Alignment"

SELECT
    a.owner || '.' || a.index_name   index_name, x.status
  , b.column_name
  , a.partitioning_type
  , a.partition_count
  , a.partitioning_key_count
  , a.locality
  , a.alignment
FROM
    dba_part_indexes      a, dba_IND_PARTITIONS X
  , dba_part_key_columns  b
WHERE
      a.owner              = UPPER('&schema')
  AND a.table_name         = UPPER('&table_name')
  AND RTRIM(b.object_type) = 'INDEX'
  AND b.owner              = a.owner      
  AND b.name               = a.index_name
  AND a.owner              = x.INDEX_OWNER    
  AND a.INDEX_NAME         = x.INDEX_NAME
ORDER BY
    a.index_name
  , b.column_position
/
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | TRIGGERS                                                               |
PROMPT +------------------------------------------------------------------------+

COLUMN trigger_name            FORMAT a40                HEADING "Trigger Name"
COLUMN trigger_type            FORMAT a16                HEADING "Type"
COLUMN status                  FORMAT a08                HEADING "Status"
COLUMN triggering_event        FORMAT a9                 HEADING "Trig.|Event"
COLUMN referencing_names       FORMAT a40                HEADING "Referencing Names" 
COLUMN when_clause             FORMAT a50                HEADING "When Clause"
COLUMN trigger_body            FORMAT a170              HEADING "Trigger Body" newline
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);
SELECT
    owner || '.' || trigger_name  trigger_name
  , trigger_type
  , triggering_event
  , status
  , referencing_names
  , when_clause
  , trigger_body
FROM
    dba_triggers
WHERE
      table_owner = UPPER('&schema')
  AND table_name  = UPPER('&table_name')
ORDER BY
     trigger_name
/


PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | TABELAS FILHAS                                                         |
PROMPT +------------------------------------------------------------------------+

COLUMN LEVEL                   FORMAT 999999999
COLUMN TABELAS                 FORMAT a150                HEADING "TABELAS"

SELECT LEVEL, LPAD(' ', LEVEL*4) || T.FILHA TABELAS FROM (
                SELECT DISTINCT A.TABLE_NAME PAI, B.TABLE_NAME FILHA
                FROM dba_CONSTRAINTS A
                INNER JOIN dba_CONSTRAINTS B ON A.CONSTRAINT_NAME = B.R_CONSTRAINT_NAME
                WHERE B.OWNER LIKE 'SYS__' AND A.TABLE_NAME <> B.TABLE_NAME
                UNION
                SELECT DISTINCT NULL PAI, C.TABLE_NAME FILHA
                FROM DBA_TABLES C
                WHERE C.TABLE_NAME = UPPER('&table_name')
                                AND C.OWNER = UPPER('&schema')
) T
START WITH T.PAI IS NULL
CONNECT BY PRIOR T.FILHA = T.PAI
/

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | TABELAS PAI                                                            |
PROMPT +------------------------------------------------------------------------+

COLUMN LEVEL                   FORMAT 999999999
COLUMN TABELAS                 FORMAT a150                HEADING "TABELAS"

-- TABELAS PAIS DADA UMA TABELA FILHA.
SELECT LEVEL, LPAD(' ', LEVEL*4) || T.PAI TABELAS FROM (
                SELECT DISTINCT A.TABLE_NAME PAI, B.TABLE_NAME FILHA
                FROM DBA_CONSTRAINTS A
                INNER JOIN DBA_CONSTRAINTS B ON A.CONSTRAINT_NAME = B.R_CONSTRAINT_NAME
                WHERE B.OWNER LIKE 'SYS__' AND A.TABLE_NAME <> B.TABLE_NAME
                UNION
                SELECT DISTINCT C.TABLE_NAME PAI, NULL FILHA
                FROM DBA_TABLES C
                WHERE C.TABLE_NAME = UPPER('&table_name')
                                AND C.OWNER = UPPER('&schema')
) T
START WITH T.FILHA IS NULL
CONNECT BY PRIOR T.PAI = T.FILHA
/

----PROMPT
----PROMPT +------------------------------------------------------------------------+
----PROMPT | DEPENDENCIES                                                           |
----PROMPT | $ORACLE_HOME/rdbms/admin/utldtree.sql                                  |
----PROMPT +------------------------------------------------------------------------+
----
----SET FEEDBACK    off
----execute deptree_fill('table', '&schema', '&table_name');
----
----COLUMN NESTED_LEVEL   FORMAT 99999999       JUSTIFY CENTER
----COLUMN TYPE           FORMAT a30            JUSTIFY CENTER
----COLUMN NAME           FORMAT a50            JUSTIFY CENTER
----COLUMN SCHEMA         FORMAT a30            JUSTIFY CENTER
----COLUMN SEQ#           FORMAT 99999999       JUSTIFY CENTER
----select NESTED_LEVEL, TYPE,SCHEMA,NAME, SEQ# from deptree order by seq#
----/



SET FEEDBACK    on
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT     O GUINA NAO TINHA DÓ, SE REGIR, BUMMM! VIRA PÓ . . . 




--@$ORACLE_HOME/rdbms/admin/utldtree.sql

