-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/temp_io.sql
-- Author       : Tim Hall
-- Description  : Displays the amount of IO for each tempfile.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @temp_io
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET PAGESIZE 1000
COLUMN tablespace_name FORMAT A20
COLUMN file_name FORMAT A60

SELECT f.INST_ID,
       SUBSTR(t.name,1,50) AS file_name,
       f.phyblkrd AS blocks_read,
       f.phyblkwrt AS blocks_written,
       f.phyblkrd + f.phyblkwrt AS total_io
FROM   gv$tempstat f,
       gv$tempfile t
WHERE  t.file# = f.file# and t.INST_ID = f.INST_ID
ORDER BY f.phyblkrd + f.phyblkwrt DESC;

SET PAGESIZE 18