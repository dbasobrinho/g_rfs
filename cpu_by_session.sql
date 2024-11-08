SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'

COLUMN username FORMAT A30
COLUMN sid FORMAT 999,999,999
COLUMN serial# FORMAT 999,999,999
COLUMN "cpu usage (seconds)"  FORMAT 999,999,999.0000

select  t.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",
   s.username,
   SUM(VALUE/100) as "cpu usage (seconds)"
FROM
   gv$session s,
   gv$sesstat t,
   gv$statname n
WHERE
   t.STATISTIC# = n.STATISTIC# and t.INST_ID = n.INST_ID
AND
   NAME like '%CPU used by this session%'
AND
   t.SID = s.SID and   t.INST_ID = s.INST_ID
AND
   s.status='ACTIVE'
AND
   s.username is not null
GROUP BY username, t.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end
having SUM(VALUE/100) >1 
order by 3 desc 
/
SET PAUSE off