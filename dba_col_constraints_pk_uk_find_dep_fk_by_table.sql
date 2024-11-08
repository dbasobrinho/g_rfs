-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_col_constraints_pk_uk_find_dep_fk_by_table.sql              |
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
COLUMN constraint_type  FORMAT a05          HEADING 'Constraint|Type'
COLUMN status           FORMAT a8           HEADING 'Status'
COLUMN owner            FORMAT a20          HEADING 'Owner'
COLUMN table_name       FORMAT a30          HEADING 'Table|Name'
COLUMN column_name      FORMAT a25          HEADING 'Column|Name'

BREAK ON report ON owner ON table_name SKIP 1

select a.owner
      ,a.table_name
      ,b.constraint_name
      ,a.constraint_type
      ,a.status
      ,b.COLUMN_NAME
  from dba_constraints  a
      ,DBA_CONS_COLUMNS b
 where a.OWNER           = b.OWNER
   and a.CONSTRAINT_NAME = b.CONSTRAINT_NAME
   and a.TABLE_NAME = b.TABLE_NAME
   and a.owner||a.r_constraint_name in
       (select aa.owner||aa.constraint_name
          from dba_constraints  aa
              ,DBA_CONS_COLUMNS bb
         where aa.constraint_type in ('P', 'U')
           and aa.owner       = upper('&schema')
           and aa.table_name  = upper('&table_name')
           and aa.OWNER       = bb.OWNER
           and aa.CONSTRAINT_NAME = bb.CONSTRAINT_NAME
           and aa.TABLE_NAME = bb.TABLE_NAME)
 order by 1,2
 /




