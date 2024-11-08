-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/index_monitoring_on.sql
-- Author       : Tim Hall
-- Description  : Sets monitoring on for the specified table indexes.
-- Call Syntax  : @index_monitoring_on (schema) (table-name or all)
-- Last Modified: 04/02/2005
-- -----------------------------------------------------------------------------------
SET ECHO        OFF
SET FEEDBACK    on
SET HEADING     ON
SET LINES       10000
SET PAGES       10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
SET COLSEP '|'

col OWNER noprint
col TABLE_NAME      for a35            heading 'Table name'
col INDEX_NAME      for a35            heading 'Index name'
col INDEX_TYPE      for a10            heading 'Index type'
col INDEX_OPERATION for a32            Heading 'Index operation'
col NR_EXEC         for 9G999G990      heading 'Executions'
col MB              for 999G999G990D90 Heading 'Index|Size MB' justify  right

SELECT 'ALTER INDEX "' || i.owner || '"."' || i.index_name || '" MONITORING USAGE;' cmd
FROM   dba_indexes i
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'));


