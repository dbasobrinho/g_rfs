-- -----------------------------------------------------------------------------------
-- File Name    : 
-- Author       : 
-- Description  : 
-- Requirements : 
-- Call Syntax  : 
-- Last Modified: 
-- -----------------------------------------------------------------------------------

COLUMN NAME            FORMAT A70
COLUMN PHYSICAL_READS  FORMAT 999999999
COLUMN PERC_READS      FORMAT A10
COLUMN PHYSICAL_WRITES FORMAT 999999999
COLUMN PERC_WRITES     FORMAT A10
COLUMN TOTAL           FORMAT 999999999999 
SET PAGESIZE 1000
SET LINESIZE 220
SET TIMING ON
SET TIME ON

SELECT NAME,
         PHYRDS PHYSICAL_READS,
         lpad(ROUND ( (RATIO_TO_REPORT (PHYRDS) OVER ()) * 100, 2),4,'0') || '%' PERC_READS,
         PHYWRTS PHYSICAL_WRITES,
         lpad(ROUND ( (RATIO_TO_REPORT (PHYWRTS) OVER ()) * 100, 2),4,'0')  || '%' PERC_WRITES,
         PHYRDS + PHYWRTS TOTAL
    FROM V$DATAFILE DF, V$FILESTAT FS
   WHERE DF.FILE# = FS.FILE#
ORDER BY PHYRDS DESC
/