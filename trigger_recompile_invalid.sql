SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      ON

COLUMN COMMAND FORMAT A100

select 'alter ' || object_type || ' "' || owner || '"."' || object_name ||'" compile;' AS COMMAND
  from dba_objects
 where object_type in ('TRIGGER')
   and status != 'VALID';
 
