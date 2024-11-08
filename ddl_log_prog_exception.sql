SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : PROGRAM EXCEPTION DDL_LOG           +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.0                                 +-+-+-+-+-+-+-+-+-+-+   |
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
COLUMN dr_incl        FORMAT a15
COLUMN ddl_type        FORMAT a10 
COLUMN object_type     FORMAT a17 
COLUMN object_name     FORMAT a30
COLUMN osuser          FORMAT a10 
COLUMN terminal        FORMAT a15
COLUMN program         FORMAT a50
COLUMN ipadress        FORMAT a15
COLUMN SQL_ID          FORMAT a16
COLUMN SQL_TEXT        FORMAT a110


select to_char(a.DATE_INC, 'dd/mm/yy hh24:mi')dr_incl,  substr(a.program,1, 50) program 
from DDL_LOG_PROGRAM_EXCEPTION a
/
UNDEF PAR_SYSDATE_MENOS
