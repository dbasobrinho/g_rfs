SELECT lh.inst_id Locking_Inst, lh.sid Locking_Sid,lw.inst_id Waiting_Inst, lw.sid Waiter_Sid,
decode ( lh.type, 'MR', 'Media_recovery',
'RT', 'Redo_thread',
'UN', 'User_name',
'TX', 'Transaction',
'TM', 'Dml',
'UL', 'PLSQL User_lock',
'DX', 'Distrted_Transaxion',
'CF', 'Control_file',
'IS', 'Instance_state',
'FS', 'File_set',
'IR', 'Instance_recovery',
'ST', 'Diskspace Transaction',
'IV', 'Libcache_invalidation',
'LS', 'LogStaartORswitch',
'RW', 'Row_wait',
'SQ', 'Sequence_no',
'TE', 'Extend_table',
'TT', 'Temp_table',
'Nothing-' ) Waiter_Lock_Type,
decode ( lw.request, 0, 'None',
1, 'NoLock',
2, 'Row-Share',
3, 'Row-Exclusive',
4, 'Share-Table',
5, 'Share-Row-Exclusive',
6, 'Exclusive',
'Nothing-' ) Waiter_Mode_Req
FROM gv$lock lw, gv$lock lh
WHERE lh.id1=lw.id1
AND lh.id2=lw.id2
AND lh.request=0
AND lw.lmode=0
AND (lh.id1,lh.id2) in (
SELECT id1,id2 FROM gv$lock WHERE request=0
INTERSECT
SELECT id1,id2 FROM gv$lock WHERE lmode=0 );

SELECT count(1), lh.inst_id Locking_Inst, lh.sid Locking_Sid
FROM gv$lock lw, gv$lock lh
WHERE lh.id1=lw.id1
AND lh.id2=lw.id2
AND lh.request=0
AND lw.lmode=0
AND (lh.id1,lh.id2) in (
SELECT id1,id2 FROM gv$lock WHERE request=0
INTERSECT
SELECT id1,id2 FROM gv$lock WHERE lmode=0 )
group by lh.inst_id, lh.sid ;

select c.sid sid, c.serial#,
         substr(c.OSUSER, 1, 30) Username,
         substr(c.ROW_WAIT_BLOCK#, 1, 10) Row_Wait,
  substr(c.module, 1, 20) module,
  SUBSTR(C.USERNAME,1, 20) USERNAME,--, C.USERNAME OS_USER, C.MACHINE,
  substr('alter system kill session '''||c.sid||''||','||c.serial#||''';',1,80) statment
from v$session c
       where sid  in ( SELECT l.SID
                  FROM v$lock l
                  WHERE l.TYPE <> 'MR' and block=1   ) and rownum < 10;

