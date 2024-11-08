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


select distinct
c.sid || ',' || c.serial#|| case when c.inst_id is not null then ',@' || c.inst_id end  as "SID/SERIAL",
substr(c.osuser,1,10)   as osuser,
c.status,
--'alter system kill session ''' || c.sid || ',' || c.serial# || ''' immediate;' kill_session_cmd,
 to_char(b.pid)          as opid,
 to_char(b.spid)         as sopid,
substr(c.osuser,1,10)   as osuser,
substr(c.program,1,20)  as program,
substr(c.machine,1,30)  as machine,
a.blocks * e.block_size/1024/1024 mb_temp_used  ,
a.tablespace,
 c.sql_id  as sql_id
--d.sql_text
from
gv$tempseg_usage a, /* v$sort_usage */
gv$process b,
gv$session c,
gv$sqlarea d,
dba_tablespaces e
where c.saddr        =a.session_addr   and c.inst_id = a.inst_id
and b.addr           =c.paddr          and b.inst_id = c.inst_id
and a.sqladdr        =d.address(+)     and a.inst_id = d.inst_id(+)
and a.tablespace     = e.tablespace_name   
order by mb_temp_used desc;

