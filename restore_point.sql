!ls -ltraSET TERMOUT OFF;
COLUMN X1 NEW_VALUE X1 NOPRINT;
COLUMN X2 NEW_VALUE X2 NOPRINT;
SELECT 'alter database flashback on;' X1 FROM DUAL;
SELECT 'create restore point '||'<RESTORE_POINT_NAME>'||';' X2 FROM DUAL;


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

column name            format  a55
column scn             format  99999999 
column storage_size    format  99999999
column Guar            format  a5     

select name, scn, storage_size, guarantee_flashback_database as Guar from v$restore_point;
/






