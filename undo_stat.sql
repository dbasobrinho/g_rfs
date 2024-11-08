-- -----------------------------------------------------------------------------------
COLUMN begin_time FORMAT A21

select TO_CHAR(begin_time, 'DD/MM/YYYY HH24:MI:SS') begin_time
      ,UNXPSTEALCNT  "#UnexpiredBlksTaken"
       ,EXPSTEALCNT   "#ExpiredBlksTaken"
       ,NOSPACEERRCNT "SpaceRequests"
  from v$undostat
 order by begin_time;