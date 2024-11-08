SET TERMOUT OFF;
COLUMN X1 NEW_VALUE X1 NOPRINT;
COLUMN X2 NEW_VALUE X2 NOPRINT;
COLUMN X3 NEW_VALUE X3 NOPRINT;
COLUMN X4 NEW_VALUE X4 NOPRINT;
--COLUMN X5 NEW_VALUE X5 NOPRINT;
SELECT 'alter database tempfile '''||'<FILE_NAME_ID>'||''' resize <SIZE>;' X1 FROM DUAL;
SELECT 'alter tablespace '||'<TBS_TEMP_NAME>'||' add tempfile '''||'<PATH>'||''' size <SIZE> autoextend off;' X2 FROM DUAL;
SELECT 'create temporary tablespace '||'<TBS_TEMP_NAME>'||' tempfile '''||'<PATH>'||''' size <SIZE> reuse;' X3 FROM DUAL;
SELECT 'alter database default temporary tablespace <TBS_TEMP_NAME>;' X4 FROM DUAL;
--SELECT 'alter database tempfile '''||'<PATH>'||''' offline;' X5 FROM DUAL
--SELECT 'alter database tempfile '''||'<PATH>'||''' drop including datafiles;;' X6 FROM DUAL

SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | &X1      
PROMPT | &X2   
PROMPT | &X3
PROMPT | &X4        
--PROMPT | &X5                                
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

column file_name      format  a55
column bytes_mb       format  99999999 
column maxbytes_mb    format  99999999
column autoextensible format  a10       heading 'EXTENSIBLE' 
column increment_by   format  99999999
column STATUS         format  a10       heading 'STATUS'
column file_id        format  99999999
column command        format  a50  

select x.file_name
      ,bytes / (1024 * 1024)      bytes_mb
      ,x.maxbytes / (1024 * 1024) maxbytes_mb
      ,x.autoextensible 
      ,x.increment_by
      ,x.file_id
	  ,x.STATUS
  from DBA_TEMP_FILES x
 --where tablespace_name = '&tablespace_name'
 order by x.file_id
/




