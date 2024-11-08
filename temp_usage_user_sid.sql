-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/temp_usage.sql
-- Author       : Tim Hall
-- Description  : Displays temp usage for all session currently using temp space.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @temp_usage_user_sid.sql
-- Last Modified: 12/02/2004
-- -----------------------------------------------------------------------------------


COLUMN temp_used FORMAT 9999999999
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a17  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a20
col client_info  format a23
col machine      format a30
col logon_time   format a10
col hold         format a06
col sessionwait  format a25
col status       format a08
col hash_value   format a10
col sc_wait      format a06 HEADING 'WAIT'

SELECT s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",
       s.sql_id  as sql_id,
	   s.status,
       substr(s.username,1,10)||decode(s.username,'SYS',SUBSTR(nvl2(s.module,' [',null)||UPPER(s.module),1,6)||nvl2(s.module,']',null)) as username,
       ROUND(ss.value/1024/1024, 2) AS temp_used_mb,
substr(s.osuser,1,10)   as osuser,
substr(s.program,1,20)  as program,
substr(s.machine,1,30)  as machine,
to_char(s.logon_time,'ddmmrrhh24mi') as logon_time
FROM   gv$session s, gv$sesstat ss , gv$statname sn 
where  s.sid = ss.sid and s.INST_ID = ss.INST_ID
and  ss.statistic# = sn.statistic# and ss.INST_ID = s.INST_ID
and   sn.name = 'temp space allocated (bytes)'
AND    ss.value > 0
ORDER BY 1;
