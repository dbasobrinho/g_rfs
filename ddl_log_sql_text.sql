SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : AUDIT DDL FULL SQL TEXT | (NO SYS)  +-+-+-+-+-+-+-+-+-+-+   |
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
COLUMN ddl_date        FORMAT a15
COLUMN ddl_type        FORMAT a10 
COLUMN object_type     FORMAT a17 
COLUMN object_name     FORMAT a30
COLUMN osuser          FORMAT a10 
COLUMN terminal        FORMAT a15
COLUMN program         FORMAT a15
COLUMN ipadress        FORMAT a15
COLUMN SQL_ID          FORMAT a16
COLUMN SQL_TEXT        FORMAT a110

select to_char(a.ddl_date, 'dd/mm/yy hh24:mi')ddl_date, substr(a.OS_USER,1, 10) OS_USER,  substr(a.DB_USER,1, 12) , substr(a.program,1, 15) program , substr(SQL_TEXT ,1,130) as SQL_TEXT
from ddl_log a
where a.ddl_date >= trunc(sysdate-&PAR_SYSDATE_MENOS)
order by a.ddl_date desc
/
UNDEF PAR_SYSDATE_MENOS
