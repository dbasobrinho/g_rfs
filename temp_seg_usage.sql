-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/tempseg_usage.sql
-- Author       : Tim Hall
-- Description  : Displays temp segment usage for all session currently using temp space.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @temp_seg_usage.sql
-- Last Modified: 01/04/2006
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN username FORMAT A20

SELECT INST_ID,
       username,
       session_addr,
       session_num,
       sqladdr,
       sqlhash,
       sql_id,
       contents,
       segtype,
       extents,
       blocks
FROM   gv$tempseg_usage
ORDER BY username, INST_ID;