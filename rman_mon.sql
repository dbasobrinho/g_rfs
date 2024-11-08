-- # Script para monitorar status atividades do RAM
-- # RMAN Progress

alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss'
/
set lines 1000
set pages 1000
COLUMN START_TIME  FORMAT a21 
COLUMN end_at      FORMAT a21 
COLUMN done      FORMAT a13 HEADING '%_COMPLETE'

COLUMN sofar                  HEADING 'SOFAR'
select SID, to_char(START_TIME,'dd/mm/yyyy hh24:mi:ss') START_TIME ,TOTALWORK, sofar, 
to_char(ROUND((SOFAR/TOTALWORK)*100,2)) ||' %' done,
to_char(sysdate + TIME_REMAINING/3600/24,'dd/mm/yyyy hh24:mi:ss')  end_at
from v$session_longops
where totalwork > sofar
AND opname NOT LIKE '%aggregate%'
AND opname like 'RMAN%'
order by ROUND((SOFAR/TOTALWORK)*100,1) desc 
/

REM RMAN wiats
column sid format 9999
COLUMN SPID      FORMAT a10 
column client_info format a44
column event format a44
column secs format 999999999
SELECT SID, SPID, CLIENT_INFO, event, seconds_in_wait secs, p1, p2, p3
  FROM V$PROCESS p, V$SESSION s
  WHERE p.ADDR = s.PADDR
  and CLIENT_INFO like 'rman channel=%'
/

