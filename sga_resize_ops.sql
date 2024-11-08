-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/10g/sga_resize_ops.sql
-- Author       : Tim Hall
-- Description  : Provides information about memory resize operations.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @sga_resize_ops
-- Last Modified: 09/05/2017
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy HH24:MI:SS';
select to_char(CURRENT_SIZE/1024/1024/1024) as GB_CURRENT_SIZE  from v$sga_dynamic_free_memory;
/
COLUMN parameter FORMAT A25
COLUMN component FORMAT A30
COLUMN oper_type FORMAT A14
SELECT start_time,
       end_time,
       component,
       oper_type,
       oper_mode,
       parameter,
       ROUND(initial_size/1024/1024) AS initial_size_mb,
       ROUND(target_size/1024/1024) AS target_size_mb,
       ROUND(final_size/1024/1024) AS final_size_mb,
       status
FROM   v$sga_resize_ops
ORDER BY start_time
/