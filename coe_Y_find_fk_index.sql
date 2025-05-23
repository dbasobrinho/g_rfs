set pagesize 5000
set linesize 350
column status        format a10
column table_name    format a30
column fk_name       format a30
column fk_columns    format a30
column index_name    format a30
column index_columns format a30

set echo on
SET TIMING ON
EXEC dbms_application_info.set_module( module_name => 'coe_Y_find_fk_index! WORKING -> ', action_name =>  'coe_Y_find_fk_index');
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
col fn new_value banco;
SELECT 'coe_Y_find_fk_index_'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS')||'.csv' as fn from dual;
spool &BANCO;



select
case
   when b.table_name is null then
      'unindexed'
   else
      'indexed'
end as status,
   a.table_name      as table_name,
   a.constraint_name as fk_name,
  a.fk_columns      as fk_columns,
  b.index_name      as index_name,
  b.index_columns   as index_columns
from
(
   select 
    a.table_name,
   a.constraint_name,
   listagg(a.column_name, ',') within
group (order by a.position) fk_columns
from
   dba_cons_columns a,
   dba_constraints b
where
   a.constraint_name = b.constraint_name
and 
   b.constraint_type = 'R'
and 
   a.owner = b.owner
group by 
   a.table_name, 
   a.constraint_name
) a
,(
select 
   table_name,
   index_name,
   listagg(c.column_name, ',') within
group (order by c.column_position) index_columns
from
   dba_ind_columns c
group by
   table_name, 
   index_name
) b
where
   a.table_name = b.table_name(+)
and 
   b.index_columns(+) like a.fk_columns || '%'
order by 
   1 desc, 2;
spool off