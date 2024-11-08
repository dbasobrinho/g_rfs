SET LINESIZE 500
SET PAGESIZE 1000
COLUMN username FORMAT A10
COLUMN osuser FORMAT A10
COLUMN spid FORMAT A10
COLUMN service_name FORMAT A15
COLUMN module FORMAT A45
COLUMN machine FORMAT A30
COLUMN logon_time FORMAT A20
COLUMN inst_id FORMAT 99
COLUMN pga_used_mem_mb FORMAT 99990.00
COLUMN pga_alloc_mem_mb FORMAT 99990.00
COLUMN pga_freeable_mem_mb FORMAT 99990.00
COLUMN pga_max_mem_mb FORMAT 99990.00
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
BREAK ON report ON isnt SKIP 1
COMPUTE sum LABEL ""              OF pga_used_mem_mb pga_alloc_mem_mb pga_freeable_mem_mb pga_max_mem_mb ON isnt
COMPUTE sum LABEL "Global: " OF pga_used_mem_mb pga_alloc_mem_mb pga_freeable_mem_mb pga_max_mem_mb ON report



---BREAK ON report ON isnt SKIP 1
---COMPUTE sum LABEL ""              OF total_mb used_mb ON disk_group_name
---COMPUTE sum LABEL ""              OF mb_disk  mb_disk ON disk_group_name
---COMPUTE sum LABEL "Grand Total: " OF total_mb used_mb ON report	


SELECT  s.inst_id isnt,
      s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end  as "SID/SERIAL",
      substr(NVL(s.username, '(oracle)'),1,10) AS username,
      substr(s.osuser,1,10) as osuser,
      p.spid,
      ROUND(p.pga_used_mem/1024/1024,2) AS pga_used_mem_mb,
      ROUND(p.pga_alloc_mem/1024/1024,2) AS pga_alloc_mem_mb,
      ROUND(p.pga_freeable_mem/1024/1024,2) AS pga_freeable_mem_mb,
      ROUND(p.pga_max_mem/1024/1024,2) AS pga_max_mem_mb,
    --  s.lockwait,
      s.status,
     -- s.service_name,
  --    s.module,
   --   s.machine,
 --     s.program,
      TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
      --s.last_call_et AS last_call_et_secs
FROM   gv$session s,
      gv$process p
Where s.paddr       = p.addr    --(+)
  and s.inst_id     = p.inst_id --(+)
ORDER BY s.inst_id, s.username, s.osuser;
SET PAGESIZE 14