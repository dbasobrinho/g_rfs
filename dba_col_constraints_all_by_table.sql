-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_col_constraints_all_by_table.sql                            |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Column Constraints for a Specified Table                    |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT schema     CHAR PROMPT 'Enter schema     : '
ACCEPT table_name CHAR PROMPT 'Enter table name : '

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN owner            FORMAT a20          HEADING 'Owner'
COLUMN constraint_name  FORMAT a30          HEADING 'Constraint|Name'
COLUMN CONSTRAINT_TYPE  FORMAT a05          HEADING 'Constraint|Type'
COLUMN status           FORMAT a8           HEADING 'Status'
COLUMN owner            FORMAT a20          HEADING 'Owner'
COLUMN table_name       FORMAT a30          HEADING 'Table|Name'
COLUMN column_name      FORMAT a25          HEADING 'Column|Name'

BREAK ON report ON owner ON table_name SKIP 1

select  cons.owner
       ,cols.table_name
       ,cols.column_name
       ,cols.position
       ,cons.status
	   ,cons.constraint_type
  from all_constraints  cons
      ,all_cons_columns cols
 where cols.owner = upper('&schema')
   and cols.table_name = upper('&table_name')
   and cons.constraint_name = cols.constraint_name
   and cons.owner = cols.owner
 order by cols.table_name
         ,cols.position
/





