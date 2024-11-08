SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Audit DDL NO SYS E ADM                                      |
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

COLUMN user_name       FORMAT a12 
COLUMN ddl__date        FORMAT a17
COLUMN ddl_type        FORMAT a10 
COLUMN object_type     FORMAT a17 
COLUMN object_name     FORMAT a30
COLUMN osuser          FORMAT a12 
COLUMN terminal        FORMAT a15
COLUMN program         FORMAT a25
COLUMN ipadress        FORMAT a15

select substr(a.user_name,1, 12) user_name, to_char(a.ddl_date, 'dd/mm/yy hh24:mi:ss')ddl__date,
substr(a.ddl_type,1,10)ddl_type, substr(a.object_type,1, 17)object_type,
substr(a.owner||'.'||a.object_name,1, 30) object_name, substr(a.osuser,1, 12) osuser, 
substr(a.terminal,1, 15) terminal, substr(a.program,1, 25) program, substr(a.ipadress,1, 15) ipadress 
from ddl_log a
where a.ddl_date > sysdate-&days
and nvl(upper(a.user_name),'SYS') not in ('SYS', 'SYSTEM')
AND NVL(UPPER(a.program),'TNS') NOT LIKE '%TNS%' 
order by a.ddl_date desc
/

