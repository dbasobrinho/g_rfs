-- |----------------------------------------------------------------------------|
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
COLUMN current_instance_nt NEW_VALUE current_instance_nt NOPRINT;
SELECT rpad(instance_name, 17) current_instance, instance_name current_instance_nt FROM v$instance;
SET TERMOUT ON;
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Parametros PDB                                              |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET PAGESIZE    1000
SET LINESIZE    500
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR           COLUMNS
CLEAR           BREAKS
CLEAR           COMPUTES
COLUMN name      FORMAT  A40     
COLUMN value     FORMAT  A50   
SELECT  name, value
FROM    v$parameter
WHERE   ispdb_modifiable='TRUE'
ORDER BY name
/

