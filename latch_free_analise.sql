select * from gv$event_name where name = 'latch free'

   INST_ID|    EVENT#|  EVENT_ID|NAME        |PARAMETER1 |PARAMETER2 |PARAMETER3 |WAIT_CLASS_ID|WAIT_CLASS#|WAIT_CLASS
----------|----------|----------|------------|-----------|---------- |-----------|-------------|-----------|-----------
         1|       412|3474287957|latch free  |address    |number     |tries      |   1893977003|          0|Other
         2|       412|3474287957|latch free  |address    |number     |tries      |   1893977003|          0|Other

The address of the latch for which the process is waiting.
The latch number that indexes in the V$LATCHNAME view.To find more information on the latch, use this SQL command:
A count of the number of times the process tried to get the latch (slow with spinning) and the process has to sleep.

  select INST_ID,p2, count(*)
   from gv$active_session_history
   where event='latch free'
   group by p2, INST_ID
/   

  select INST_ID,p2, count(*)
   from gv$session
   where event='latch free'
   group by p2, INST_ID
/  
   INST_ID|        P2|  COUNT(*)
----------|----------|----------
         1|       414|         3
         2|       129|         2
         2|       414|         3

 SELECT * FROM gv$latchname WHERE latch#=186;
 
 

    LATCH#|NAME                                                            |      HASH
----------|----------------------------------------------------------------|----------
       127|KJC global resend message queue                                 |2445723444
       414|query server process                                            |3658666727

select name,gets,misses,wait_time from v$latch where upper(name) like upper('%simulator hash latch%') order by wait_time;

NAME                                                            |      GETS|    MISSES| WAIT_TIME
----------------------------------------------------------------|----------|----------|----------
query server process                                            |  10929492|     42202|2625999883

--bug 9951190, descreve algumas mudanças na pesquisa de scn
--mostly latch-free SCN
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
column EVENT       FORMAT a15           HEAD 'EVENT'
column Latch_name  FORMAT a30           HEAD 'Latch_name'
column ADDRESS     FORMAT a20           HEAD 'ADDRESS' 
column sql_id      FORMAT a13           HEAD 'sql_id' 
select  a.sid || ',' || a.serial#|| case when a.inst_id is not null then ',@' || a.inst_id end  as "SID/SERIAL",
B.EVENT, d.name Latch_name, A.USERNAME, A.STATUS, a.sql_id 
,A.MACHINE, substr(A.PROGRAM,1,10) PROGRAM, B.P1, B.P2, substr(c.SQL_TEXT,1,10) SQL_TEXT, c.address
from gv$session A, gV$SESSION_WAIT B, gv$sql c, gV$LATCH D
where
A.SID=B.sid AND
a.INST_ID=b.INST_ID and
a.SQL_ADDRESS=c.address AND
a.INST_ID=c.INST_ID and
b.p2=d.LATCH# and
b.INST_ID=d.INST_ID and
b.event not like '%SQL*Net%'
and d.name like '%latch-free%'
order by username, machine
/


SID/SERIAL@I   |EVENT          |Latch_name                    |USERNAME  |STATUS  |sql_id       |MACHINE            |PROGRAM   |        P1|        P2|SQL_TEXT  |ADDRESS
---------------|---------------|------------------------------|----------|--------|-------------|-------------------|----------|----------|----------|----------|--------------------
2644,28311,@1  |latch free     |mostly latch-free SCN         |FPS_BO    |ACTIVE  |f36knvx60mmud|FNIS-BR\SRVALESP07 |PayTrue.Pa|1610722128|       166|SELECT irq|0000001BB163EED0
364,11499,@2   |latch free     |mostly latch-free SCN         |FPS_BO    |ACTIVE  |f36knvx60mmud|FNIS-BR\SRVWEBSP24 |PayTrue.Pa|1610722128|       166|SELECT irq|0000001BCD38FF28



select sid, p1raw, p2, p3, seconds_in_wait, wait_time, state 
from   v$session_wait 
where  event = 'latch free'
order by p2, p1raw
/

https://blog.toadworld.com/categoryreducing_contention_for_the_cache_buffer_chains_latch
column event format a20 
column username format a12 
column state format a20 trunc 
column p1 format 999999999999 heading "P1" 
column p2 format 999999999999 heading "P2" 
column p3 format 99999 heading "P3" 
set lin 600 
SELECT V$SESSION.username, V$SESSION_WAIT.sid, V$SESSION_WAIT.event, V$SESSION_WAIT.seq#,
     V$SESSION_WAIT.seconds_in_wait sec_wait, V$SESSION_WAIT.wait_time, V$SESSION_WAIT.p1 , V$SESSION_WAIT.p2, V$SESSION_WAIT.p3,
     V$SESSION_WAIT.state, V$SESSION_WAIT.p1raw, V$SESSION_WAIT.p2raw, V$SESSION_WAIT.p3raw
   FROM V$SESSION_WAIT, V$SESSION 
WHERE V$SESSION_WAIT.SID = V$SESSION.SID 
  AND NOT(V$SESSION_WAIT.event like 'SQL%') 
  AND NOT(V$SESSION_WAIT.event like '%message%') 
  AND NOT(V$SESSION_WAIT.event like '%timer%') 
  AND NOT(V$SESSION_WAIT.event like '%pipe get%') 
  AND NOT(V$SESSION_WAIT.event like '%jobq slave wait%') 
  AND NOT(V$SESSION_WAIT.event like '%null event%') 
  AND NOT(V$SESSION_WAIT.event like '%wakeup time%') 
  and V$SESSION_WAIT.event = 'latch free'
  ORDER BY wait_time desc, event 
/

SELECT owner,segment_name,segment_type,tablespace_name
  FROM dba_extents
 WHERE file_id = &p1
 AND &p2 between block_id and block_id+blocks-1
/


SELECT /*+ ordered */
       e.owner ||'.'|| e.segment_name segment_name,
       e.extent_id extent#,
       x.dbablk - e.block_id + 1 block#,
       x.tch,
       l.child#
  FROM sys.v$latch_children l,
       sys.x$bh x,
       sys.dba_extents e
 WHERE l.name = 'latch free' 
  -- AND l.sleeps > 1
   AND x.hladdr = l.addr 
   AND e.file_id = x.file# 
   AND x.dbablk between e.block_id and e.block_id + e.blocks – 1
/


f36knvx60mmud


latch-free