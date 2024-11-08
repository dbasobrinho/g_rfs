-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/index_monitoring_status.sql
-- Author       : Tim Hall
-- Description  : Shows the monitoring status for the specified table indexes.
-- Call Syntax  : @index_monitoring_status (table-name) (index-name or all)
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

SELECT table_name,
       index_name,
       monitoring
FROM   v$object_usage
WHERE  table_name = UPPER('&1')
AND    index_name = DECODE(UPPER('&2'), 'ALL', index_name, UPPER('&2'));
