set echo on
SET TIMING ON
EXEC dbms_application_info.set_module( module_name => 'coe_Y_frag! WORKING -> ', action_name =>  'coe_Y_frag');
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
col fn new_value banco;
SELECT 'coe_Y_frag_'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS')||'.csv' as fn from dual;
spool &BANCO;


SELECT table_name,round((BLOCKS*8),0) "size (kb)" , 
                            round((num_rows*avg_row_len/1024),0) "actual_data (kb)",
                            (round((BLOCKS*8),0) - round((num_rows*avg_row_len/1024),0)) "wasted_space (kb)"
FROM dba_tables
WHERE (round((BLOCKS*8),0) > round((num_rows*avg_row_len/1024),0))
AND (round((BLOCKS*8),0) - round((num_rows*avg_row_len/1024),0)) > 100000
ORDER BY 4 DESC;
spool off