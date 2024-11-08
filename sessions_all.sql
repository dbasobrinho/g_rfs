--> Purpose:    Script to show you all sessions. 
-->             
--> Parameters: none
--> To Run:     @sessions_all.sql
--> Example:    @sessions_all.sql
--> 
--> Copyright 2019@dbaparadise.com


clear columns
col instance for a8
col sid for 9990
col "serial#" for 99990 print
col user for a20
col osuser for a20
col machine for A20
col program for a10 word_wrapped
col locks for a4
col status for a6 trunc
col "hh:mm:ss" for a8
col SQL_ID for a13
col seq# for 99990
col event head 'current/last event' for a25 trunc
col state for a14

set lines 299


select inst_id instance
  , sid 
  , serial# 
  , username 
  , osuser 
  , machine  
  , program 
  , decode(lockwait,NULL,' ','L') locks
  , status 
  , to_char(to_date(mod(last_call_et,86400), 'sssss'), 'hh24:mi:ss') "hh:mm:ss"
  , sql_id
  , seq#
  , event
  , decode(state,'WAITING','WAITING '||lpad(to_char(mod(SECONDS_IN_WAIT,86400),'99990'),6)
    ,'WAITED SHORT TIME','ON CPU','WAITED KNOWN TIME','ON CPU',state) state
  , substr(module,1,18) module
  , substr(action,1,18) action
from GV$SESSION s
-- where type = 'USER'
-- and s.audsid != 0  -- 0 is for internal processes
-- and (status = 'ACTIVE' or SQL_HASH_VALUE <> 0 or s.lockwait is not null)
order by username;






from GV$SESSION s
--where s.type = 'USER'
--and s.audsid != 0  --it's 0 for internal processes
--and (s.status = 'ACTIVE' or SQL_HASH_VALUE <> 0 or s.lockwait is not null)
order by 4
/
