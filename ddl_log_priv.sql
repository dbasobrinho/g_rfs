SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : AUDIT ALL GRANT / REVOKE            +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    ON
SET HEADING     ON 
SET LINESIZE    200
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

COLUMN PRIV_DATE       FORMAT a19
COLUMN PRIV_NAME       FORMAT a08   HEADING 'PRIV'
COLUMN PRIVILEGE       FORMAT a25 
COLUMN OBJECT_OWNER    FORMAT a12
COLUMN OBJECT_NAME     FORMAT a30
COLUMN PRIV_TO_USER    FORMAT a13 
COLUMN USER_NAME       FORMAT a13 
COLUMN OSUSER          FORMAT a13 
COLUMN OSUSER          FORMAT a13 
COLUMN terminal        FORMAT a15
COLUMN program         FORMAT a18
COLUMN ipadress        FORMAT a15

select
 TO_CHAR(PRIV_DATE,'DD/MM/YYYY HH24:MI:SS')  AS PRIV_DATE  
,OSUSER      
,USER_NAME        
,PRIV_NAME     
,PRIVILEGE     
,OBJECT_OWNER  
,OBJECT_NAME   
,PRIV_TO_USER 
,substr(a.terminal,1, 15) terminal
,substr(a.program ,1, 18) program  
from DDL_LOG_PRIV a
where a.PRIV_DATE >= trunc(sysdate-&PAR_SYSDATE_MENOS)
order by a.PRIV_DATE desc, OBJECT_OWNER, PRIV_TO_USER
/
UNSET PAR_SYSDATE_MENOS
--grant SELECT on sys.V_$SESSION to LC5585266;
--revoke SELECT on sys.V_$SESSION from LC5585266;

