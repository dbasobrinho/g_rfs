col status           format a04 HEADING 'STATUS'
col table_owner      format a15 HEADING 'TABLE OWNER'
col table_name       format a30 HEADING 'TABLE NAME'
col CONS_COLUMNS     format a100 HEADING 'CONSTRAINTS COLUMNS'
col IDX_COLUMNS      format a100 HEADING 'INDEXES COLUMNS'
SET COLSEP '|'

select decode( b.table_name, NULL, '****', 'ok' ) Status, a.table_owner, a.table_name, a.columns CONS_COLUMNS, b.columns IDX_COLUMNS
from
(     select substr(a.OWNER,1,30) table_owner, substr(a.table_name,1,30)      table_name,
             substr(a.constraint_name,1,30) constraint_name,
             max(decode(position, 1,     substr(column_name,1,30),NULL)) ||
             max(decode(position, 2,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 3,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 4,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 5,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 6,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 7,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 8,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position, 9,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,10,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,11,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,12,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,13,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,14,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,15,', '||substr(column_name,1,30),NULL)) ||
             max(decode(position,16,', '||substr(column_name,1,30),NULL)) columns
    from dba_cons_columns a, dba_constraints b
   where a.constraint_name = b.constraint_name
     and a.OWNER           = b.OWNER
     and b.constraint_type = 'R'
   group by substr(a.OWNER,1,30) , substr(a.table_name,1,30), substr(a.constraint_name,1,30) ) a,
( select substr(TABLE_OWNER,1,30) table_owner, substr(table_name,1,30) table_name, substr(INDEX_OWNER,1,30) index_owner, substr(index_name,1,30) index_name,
             max(decode(column_position, 1,     substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 2,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 3,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 4,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 5,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 6,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 7,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 8,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position, 9,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,10,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,11,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,12,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,13,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,14,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,15,', '||substr(column_name,1,30),NULL)) ||
             max(decode(column_position,16,', '||substr(column_name,1,30),NULL)) columns
    from dba_ind_columns
   group by substr(TABLE_OWNER,1,30) , substr(table_name,1,30), substr(INDEX_OWNER,1,30) , substr(index_name,1,30)  ) b
where a.table_name  = b.table_name  (+)
  and a.table_owner = b.table_owner (+)
  and b.columns (+) like a.columns || '%'
  and a.table_owner not in ('PERFSTAT', 'SYS', 'ORDDATA', 'SYSTEM', 'DBSNMP', 'MDSYS')
  ORDER BY Status DESC, a.table_owner, a.table_name
/

