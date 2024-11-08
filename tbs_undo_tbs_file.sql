-- -----------------------------------------------------------------------------------
-- File Name    : 
-- Author       : 
-- Description  : 
-- Requirements : 
-- Call Syntax  : 
-- Last Modified: 
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

SET TERMOUT OFF;
COLUMN X1 NEW_VALUE X1 NOPRINT;
COLUMN X2 NEW_VALUE X2 NOPRINT;
SELECT 'alter database datafile '''||'<FILE_NAME_ID>'||''' resize <SIZE>;' X1 FROM DUAL;
SELECT 'alter tablespace '||'<TBS_NAME>'||' add datafile '''||'<PATH>'||''' size <SIZE> autoextend on NEXT 500M maxsize 32767M;' X2 FROM DUAL;


SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | &X1      
PROMPT | &X2                                        
PROMPT +------------------------------------------------------------------------+

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

COLUMN file_name FORMAT A7
COLUMN size_allocated_mb FORMAT 99999
COLUMN file_name FORMAT A70

SELECT dt.tablespace_name
      ,SUM(ddf.bytes) / 1024 / 1024 size_allocated_mb
      ,ddf.file_name, ddf.file_id
  FROM dba_tablespaces dt
      ,dba_data_files  ddf
 WHERE dt.tablespace_name = ddf.tablespace_name
   AND dt.contents = 'UNDO'
 GROUP BY dt.tablespace_name ,ddf.file_name,  ddf.file_id;
