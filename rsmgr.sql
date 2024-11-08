-- |----------------------------------------------------------------------------|
-- | Objetivo   : Oracle RESOURCE_MANAGER STATUS                                |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 31/03/2022                                                    |
-- | Exemplo    : rsmgr.sql                                                     |
-- | Arquivo    : rsmgr.sql                                                     |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
-- |kill -9 $(ps -ef | grep -v grep | grep 'LOCAL=NO' | grep pbackS | awk '{print $2}')
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
ALTER SESSION SET nls_date_format='DD-MON-YYYY HH24:MI:SS';
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : STATUS RESOURCE MANAGER             +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     ON
SET LINES       600
SET PAGES       600 
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col NAME         format a28  HEADING 'NAME'
col opid         format a04
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a19
col logon_time   format a13 
col hold         format a06
col sessionwait  format a24
col status       format a08
col hash_value   format a10 
col sc_wait      format a06 HEADING 'WAIT'
col SQL_ID       format a15 HEADING 'SQL_ID/CHILD'
col RESOURCE_group       format a14 HEADING 'RESOURCE_GROUP'
SET COLSEP '|'
set lines 400 pages 99
col name for a35
col value for a40
select NAME,VALUE,ISDEFAULT,ISSES_MODIFIABLE,ISSYS_MODIFIABLE,ISINSTANCE_MODIFIABLE 
from v$parameter 
where (UPPER(name) like UPPER('%RESOURCE%') OR UPPER(name) like UPPER('%CPU%')) AND  (UPPER(name) NOT like UPPER('%PARALLEL%'))
ORDER BY VALUE
/
SELECT  ID,NAME,IS_TOP_PLAN,CPU_MANAGED,INSTANCE_CAGING,PARALLEL_SERVERS_ACTIVE,PARALLEL_SERVERS_TOTAL,PARALLEL_EXECUTION_MANAGED   
FROM   v$rsrc_plan
/
PROMPT
PROMPT===================================================
ACCEPT v_PLAN CHAR PROMPT 'PLAN NAME   (ALL) = ' DEFAULT ALL
PROMPT===================================================
PROMPT
select plan, group_or_subplan, type, cpu_p1, cpu_p2, cpu_p3, cpu_p4, status  
from dba_rsrc_plan_directives 
WHERE  PLAN = DECODE('&&v_PLAN','ALL',PLAN,'&&v_PLAN')
order by PLAN 
/
SET FEEDBACK    ON

SET TERMOUT OFF;
COLUMN X1 NEW_VALUE X1 NOPRINT;
COLUMN X2 NEW_VALUE X2 NOPRINT;
SELECT 'begin DBMS_RESOURCE_MANAGER.SWITCH_PLAN(''FORCE:''); end;' X1 FROM DUAL;
SELECT '... Onde estiver, seja lá como for, tenha fé, porque até no lixão nasce flor ...' X2 FROM DUAL;
SET TERMOUT ON;
PROMPT 
PROMPT +--------------------------------------------------------------------------------------+
PROMPT | &X1      
PROMPT | &X2                                        
PROMPT +--------------------------------------------------------------------------------------+
PROMPT 
PROMPT @s_rsmgr.sql
PROMPT !ls -ltra *rsmgr*
PROMPT