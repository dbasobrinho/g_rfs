-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : lock00_kill.sql                                                 |
-- | CLASS    :                                                                 |
-- | PURPOSE  :                                                                 |
-- | NOTE     :                                                                 |
-- |                                                                            |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessoes em Locked      [lock00_kill.sql]                    |
PROMPT | Instance : &current_instance                                           |
prompt +------------------------------------------------------------------------+

set echo        off
set feedback    6
set heading     on
set linesize    500
set pagesize    50000
set termout     on
set timing      off
set trimout     on
set trimspool   on
set verify      off

clear columns
clear breaks
clear computes

set lines 400
set pages 100
column sess_tree    format a30
column sopid        format a07
column logon_time   format a20
column idle         format a10
column ST           format a2
column username     format a15
column machine      format a15
column module       format a15
column type         format a4
column dslmode      format a15	
column dsrequest    format a15	
column req          format 999
column command_kill format a74		


select   
lpad (' ', decode (l.request, 0, 0, 3)) || s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end as sess_tree
	   , decode(s.status,'ACTIVE','A','I') ST	
	   , l.type as type
	   ,DECODE (l.lmode,
				0, 'None',
				1, 'Null',
				2, 'Row Share',
				3, 'Row Exlusive',
				4, 'Share',
				5, 'Sh/Row Exlusive',
				6, 'Exclusive'
			   ) dslmode
   	   ,DECODE (l.request,
				0, 'None',
				1, 'Null',
				2, 'Row Share',
				3, 'Row Exlusive',
				4, 'Share',
				5, 'Sh/Row Exlusive',
				6, 'Exclusive'
			   ) dsrequest	   
	   , p.spid as sopid
	   --, to_char(s.logon_time,'dd/mm/yyyy hh24:mi:ss') as logon_time
	   , substr(floor(s.last_call_et/3600)||':'|| floor(mod(s.last_call_et,3600)/60)||':'|| mod(mod(s.last_call_et,3600),60),1,8) idle
       --,substr(nvl(v.username,'(oracle)',1,15) username
	   --, substr(s.machine ,1,15) machine
	   --, substr(s.module  ,1,15) module	   
	   -- , s.action
	   , 'alter system kill session ''' || s.sid || ',' || s.serial# ||case when s.inst_id is not null then ',@' || s.inst_id end||''' immediate;'command_kill
	from gv$lock l, gv$session s , gv$process p
   where l.id1 in (select j.id1
				   from gv$lock j
				  where j.lmode = 0)
	 and l.inst_id = s.inst_id
	 and l.sid = s.sid
	 and p.addr = s.paddr
	 and p.inst_id = s.inst_id
order by id1, l.request, s.inst_id
/





