-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Uso de Memoria por SID                                      |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN mem_used_in_mb   FORMAT 99999,999
COLUMN mem_percent      FORMAT 9999
COLUMN username         FORMAT a30
COLUMN sid              FORMAT 9999999


select
   sid,
   username,
   round(total_user_mem/1024/1024,2) mem_used_in_mb,
   round(100 * total_user_mem/total_mem,2) mem_percent
from
   (select
      b.sid sid,
      nvl(b.username,p.name) username,
      sum(value) total_user_mem
   from
      sys.v_$statname c,
      sys.v_$sesstat a,
      sys.v_$session b,
      sys.v_$bgprocess p
   where
      a.statistic#=c.statistic# and
      p.paddr (+) = b.paddr and
      b.sid=a.sid and
      c.name in ('session pga memory','session uga memory')
   group by
      b.sid, nvl(b.username,p.name)),
   (select
      sum(value) total_mem
   from
      sys.v_$statname c,
      sys.v_$sesstat a
   where
      a.statistic#=c.statistic# and
      c.name in ('session pga memory','session uga memory'))
order by 3 desc
/