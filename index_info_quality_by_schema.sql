/**********************************************************************
 * File:        Index_Info.sql
 * Type:        SQL*Plus script
 * Author:      Dan Hotka
 * Date:        04-16-2009
 *
 * Description:
 *      SQL*Plus script to display Index Statistics in relation to clustering factor
 *      Script originated from Jonathan Lewis bug I have heavily modified it
 * Modifications:
 * 
 *********************************************************************/
 
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | SHOWS INDEX DISPLAY INDEX STATISTICS IN RELATION TO CLUSTERING FACTOR       |
PROMPT +-----------------------------------------------------------------------------+
PROMPT
ACCEPT 1 char   PROMPT 'SCHEMA       = '


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
col TABLE_NAME         for a35            heading 'Table Name'
col INDEX_NAME         for a35            heading 'Index Name'
col num_rows           for 9999999999     heading 'Num Rows'
col blocks             for 9999999999     Heading 'Blocks'
col clustering_factor  for 9999999999     heading 'C. Factor'
col Index_Quality      for a13            heading 'Idx Quality'
col avg_data_blocks_per_key  for 9999999999     heading 'Avg Data|Blocks Key'
col avg_leaf_blocks_per_key  for 9999999999     heading 'Avg Data|Leaf Key'
col Created             for a19            heading 'Created'

col MB                 for 999G999G990D90  Heading 'Index|Size MB' justify  right
 
SELECT i.table_name, i.index_name, t.num_rows, t.blocks, i.clustering_factor, 
case when nvl(i.clustering_factor,0) = 0                       then 'No Stats'
     when nvl(t.num_rows,0) = 0                                then 'No Stats'
     when (round(i.clustering_factor / t.num_rows * 100)) < 6  then 'Excellent    '
     when (round(i.clustering_factor / t.num_rows * 100)) between 7 and 11 then 'Good'
     when (round(i.clustering_factor / t.num_rows * 100)) between 12 and 21 then 'Fair'
     else                                                           'Poor'
     end  Index_Quality,
i.avg_data_blocks_per_key, i.avg_leaf_blocks_per_key, 
to_char(o.created,'DD/MM/YYYY HH24:MI:SS') Created
from dba_indexes i, dba_objects o, dba_tables t
where i.index_name   = o.object_name
  and i.OWNER        = o.OWNER
  and i.TABLE_OWNER  = t.OWNER
  and i.table_name   = t.table_name  
  and i.OWNER        =  '&&1'
order by 1
/
 
