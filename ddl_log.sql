SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : AUDIT DDL FULL  | (NO SYS)          +-+-+-+-+-+-+-+-+-+-+   |
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
COLUMN ddl_date        FORMAT a17
COLUMN ddl_type        FORMAT a10 
COLUMN object_type     FORMAT a17  
COLUMN object_name     FORMAT a30
COLUMN osuser          FORMAT a12 
COLUMN terminal        FORMAT a15
COLUMN program         FORMAT a25
COLUMN ipadress        FORMAT a15
COLUMN SQL_ID          FORMAT a16

select --a.DB_USER,a.OBJ_TYPE,substr(a.OBJ_OWNER||'.'||a.OBJ_NAME,1, 11), 
to_char(a.ddl_date, 'dd/mm/yy hh24:mi:ss')ddl_date, substr(a.DB_USER,1, 12) user_name, substr(a.OS_USER,1, 12) osuser, 
substr(a.ddl_type,1,10)ddl_type, substr(a.OBJ_TYPE,1, 17)object_type,
substr(a.OBJ_OWNER||'.'||a.OBJ_NAME,1, 30) object_name, 
substr(a.terminal,1, 15) terminal, substr(a.program,1, 25) program, substr(a.ipadress,1, 15) ipadress , 
SQL_ID 
from ddl_log a
where a.ddl_date >= trunc(sysdate-&PAR_SYSDATE_MENOS)
and a.DB_USER||a.OBJ_OWNER||substr(a.OBJ_NAME,1,8) not in ('TVTSPISYSORA_TEMP')
and a.DB_USER||a.OBJ_TYPE||substr(a.OBJ_OWNER||'.'||a.OBJ_NAME,1, 11)	 not in ('TVTSPISUMMARYSYSFE.VW_FE')
and a.DB_USER||a.OBJ_TYPE||substr(a.OBJ_OWNER||'.'||a.OBJ_NAME,1, 11)	 not in ('TVTSPITRUNCATESYSFE.VW_FE')
AND a.OBJ_OWNER NOT IN 'TVTSPI'
AND substr(a.OBJ_OWNER||'.'||a.OBJ_NAME,1, 30) NOT IN 
('SYSEP.FL_DRIVER_VEHICLE_GROUP_','SYSEP.IDX$$_8A8AF0029','SYSFE.VW_FE_BI_CADASTRO_MOTORI','SYSEP.MVIEW_FL_DRIVER_VEHICLE_')
AND substr(a.OBJ_OWNER||'.'||a.OBJ_NAME,1, 14) NOT IN ('SYS.UTL_RECOMP')
order by a.ddl_date desc
/
 
UNDEF PAR_SYSDATE_MENOS