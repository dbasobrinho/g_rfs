--> Purpose:    Script to show you active sessions. 
-->             
--> Parameters: none
--> To Run:     @sessions.sql
--> Example:    @sessions.sql
--> 
--> Copyright 2019@dbaparadise.com


clear columns
col inst for 9999
col sid for 9990
col serial# for 99990 print
col username for a12
col osuser for a10
col machine for a15
col program for a10 trunc
col locks for a5
col status for a1 trunc
col "hh:mm:ss" for a8
col SQL_ID for a13
col seq# for 99990
col event head 'current/last event' for a25 trunc
col state  head 'state    (sec)' for a14

set linesize 180

select inst_id inst
  , sid 
  , serial# 
  , username 
  , osuser 
  , machine  
  , program 
  , decode(lockwait,NULL,' ','L') as locks
  , status 
  , to_char(to_date(mod(last_call_et,86400), 'sssss'), 'hh24:mi:ss') "hh:mm:ss"
  , sql_id
  , seq#
  , event
  , decode(state,'WAITING','WAITING '||lpad(to_char(mod(SECONDS_IN_WAIT,86400),'99990'),6)
    ,'WAITED SHORT TIME','ON CPU','WAITED KNOWN TIME','ON CPU',state) state
  , substr(module,1,18) module
from GV$SESSION s
where type = 'USER'
and s.audsid != 0  -- 0 is for internal processes
and (status = 'ACTIVE' or SQL_HASH_VALUE <> 0 or s.lockwait is not null)
order by username;


/*Sample Output

INST  SID   SERIAL# USER         OSUSER     MACHINE              PROGRAM    L S hh:mm:ss SQL_ID         SEQ#  CURRENT/LAST EVENT        STATE    (SEC) MODULE             
----  ----- ------- ------------ ---------- -------------------- ---------- - - -------- ------------- ------ ------------------------- -------------- ------------------ 
1     101   32919   SYS          oracle     dbaparadise1         sqlplus      A 00:00:00 4k5zbcsnj53gb    861 PX Deq: Execute Reply     WAITING      0 sqlplus@dbaparadise
1     861   40827   SYS          oracle     dbaparadise1         oracle       A 00:00:00 4k5zbcsnj53gb      2 PX Deq: Execution Msg     ON CPU         sqlplus@dbaparadise
1      67       5   SYS          oracle     dbaparadise1         oraagent.b   I 14:24:46 4qm8a3w6a1rfd   1890 SQL*Net message from clie WAITING  51886 oraagent.bin
1     790   12789   SYS          oracle     dbaparadise1         oracle       A 00:00:00 4k5zbcsnj53gb     16 PX Deq: Execution Msg     ON CPU         sqlplus@dbaparadise

*/

