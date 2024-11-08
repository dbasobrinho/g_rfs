SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : MODIFIED OBJECTS IN THE LAST :[X] DAYS                      |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
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

COLUMN objet           FORMAT A70    HEADING "Objet"
COLUMN object_name     FORMAT A45    HEADING "Object Name"
COLUMN object_type     FORMAT A18    HEADING "Object Type"
COLUMN createdx         FORMAT A22    HEADING "Created"
COLUMN modified        FORMAT A22    HEADING "Last_DDL_TIME"
COLUMN days            FORMAT 9999.99               HEADING "days"

SELECT owner||'.'||object_name objet, object_type, 
to_char(created,'dd/mm/yyyy hh24:mi:ss')   as createdx,
to_char(last_ddl_time,'dd/mm/yyyy hh24:mi:ss') as modified, 
ROUND(sysdate - last_ddl_time,2) days
FROM dba_objects
WHERE sysdate - last_ddl_time < &DAYS AND
      subobject_name IS NULL
ORDER BY created DESC
/





