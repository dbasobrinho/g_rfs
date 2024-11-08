SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Audit DDL Version                                           |
PROMPT | Instance : &current_instance                                           |
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

COLUMN owner           FORMAT a12 
COLUMN ddl_date        FORMAT a17
COLUMN ddl_oper        FORMAT a10 
COLUMN object_type     FORMAT a17 
COLUMN object_name     FORMAT a30
COLUMN osuser          FORMAT a12 
COLUMN terminal        FORMAT a15
COLUMN program         FORMAT a25
COLUMN ipadress        FORMAT a15

select substr(a.owner,1,12) owner, to_char(a.ddl_date, 'dd/mm/yy hh24:mi:ss') ddl_date,
substr(a.ddl_oper,1,10) ddl_oper, a.obj_id, substr(a.obj_name,1, 25) obj_name,
substr(a.obj_type,1, 17) obj_type, a.version_counter, substr(a.osuser,1, 12) osuser,
substr(a.terminal,1, 15) terminal, substr(a.program,1, 25) program, substr(a.ipadress,1, 15) ipadress 
from ddl_log_version a
where a.ddl_date > sysdate-&days
order by a.ddl_date desc
/


