
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Rebuild Index UNUSABLE                                      |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+


SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     OFF
SET LINESIZE    180
SET PAGESIZE    0
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES


SELECT 'set timing on' from dual
UNION
SELECT 'set echo on' from dual
UNION
SELECT 'ALTER INDEX ' || OWNER || '.' ||
INDEX_NAME || ' REBUILD ' ||
' TABLESPACE ' || TABLESPACE_NAME || ' online;'
FROM DBA_INDEXES
WHERE STATUS='UNUSABLE'
UNION
SELECT 'ALTER INDEX ' || INDEX_OWNER || '.' ||
INDEX_NAME ||
' REBUILD PARTITION ' || PARTITION_NAME ||
' TABLESPACE ' || TABLESPACE_NAME || ' online;'
FROM DBA_IND_PARTITIONS
WHERE STATUS='UNUSABLE'
UNION
SELECT 'ALTER INDEX ' || INDEX_OWNER || '.' ||
INDEX_NAME ||
' REBUILD SUBPARTITION '||SUBPARTITION_NAME||
' TABLESPACE ' || TABLESPACE_NAME || ' online;'
FROM DBA_IND_SUBPARTITIONS
WHERE STATUS='UNUSABLE';

--set echo on
--set timing on

PROMPT
