-- -----------------------------------------------------------------------------------
set pages 1000
set lines 1000
BREAK ON REPORT
COMPUTE SUM OF MB ON REPORT
COMPUTE SUM OF PERC ON REPORT
COMPUTE SUM OF FULL ON REPORT

select --A.TBS,B.TBS,C.TBS, 
       C.INST_ID, A.TBS, status,
 round(sum_bytes / (1024*1024), 0) as MB,
 round((sum_bytes / undo_size) * 100, 0) as PERC,
 decode(status, 'UNEXPIRED', round((sum_bytes / undo_size * factor) * 100, 0),
                'EXPIRED',   0,
                             round((sum_bytes / undo_size) * 100, 0)) FULL
from
(
 select TABLESPACE_NAME TBS, status, sum(bytes) sum_bytes
 from dba_undo_extents
 group by status, TABLESPACE_NAME
 order by TABLESPACE_NAME, status
) a,
(
 select sum(a.bytes) undo_size, c.tablespace_name TBS
 from dba_tablespaces c
 join v$tablespace b on b.name = c.tablespace_name
 join v$datafile a on a.ts# = b.ts#
 where c.contents = 'UNDO'
 and c.status = 'ONLINE'
 group by c.tablespace_name
) b,
(
 select us.INST_ID, tuned_undoretention, u.value, u.value/tuned_undoretention factor
 ,(select x.value from gv$parameter x where x.name = 'undo_tablespace' and x.INST_ID = us.INST_ID) TBS
 from gv$undostat us
 join (select INST_ID, max(end_time) end_time from gv$undostat group by INST_ID) usm on usm.end_time = us.end_time 
 and usm.INST_ID = us.INST_ID
 join (select y.INST_ID, y.name, y.value, (select x.value from gv$parameter x where x.name = 'undo_tablespace' and x.INST_ID = y.INST_ID ) tbs
 from gv$parameter y where y.name = 'undo_retention') u on u.INST_ID = us.INST_ID
) c
where A.TBS = B.TBS AND B.TBS = C.TBS
ORDER BY 1,2,3
/