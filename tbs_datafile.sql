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

column file_name       format  a60
column bytes_mb        format  999999999 
column maxbytes_mb     format  999999999
column autoextensible  format  a10       heading 'EXTENSIBLE' 
column increment_by_mb format  999999999
column online_status   format  a10       heading 'STATUS'
column file_id         format  999999999
column command         format  a50  

ACCEPT tbs CHAR PROMPT 'TABLESPACE_NAME (ALL) = ' DEFAULT ALL

select x.file_id
      ,x.file_name
      ,to_char(CREATION_TIME,'DD-MM-RRRR HH24:MM:SS') dt_create
      ,x.bytes / (1024 * 1024)      bytes_mb
      ,x.maxbytes / (1024 * 1024)   maxbytes_mb
      ,x.autoextensible 
      ,(x.increment_by * (select to_number(value) from v$parameter where NAME = 'db_block_size')) /(1024 * 1024) increment_by_mb
      ,x.online_status
  from dba_data_files x, v$datafile d
  where d.FILE# (+) = x.file_id 
 AND tablespace_name = DECODE('&&tbs','ALL',tablespace_name,'&&tbs')
 order by x.file_id
/
UNDEF tbs






