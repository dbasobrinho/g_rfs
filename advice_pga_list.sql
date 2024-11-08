
 
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : pga advice list                     +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   | 
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     ON
SET LINES       600
SET PAGES       500
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

col pga_target_mb format 99,999 heading "Pga |MB"
col pga_target_factor_pct format 9,999 heading "Pga Size|Pct"
col estd_time format 999,999,999,999,999 heading "Estimated|Time (s)"
col estd_extra_mb_rw format 99,999,999 heading "Estd extra|MB"
col estd_pga_cache_hit_percentage format 999.99 heading "Estd PGA|Hit Pct"
col estd_overalloc_count format 999,999 heading "Estd|Overalloc"
set pagesize 1000
set lines 1000
--set echo on 

SELECT ROUND(pga_target_for_estimate / 1048576) pga_target_mb,
       pga_target_factor * 100 pga_target_factor_pct, estd_time,
       ROUND(estd_extra_bytes_rw / 1048576) estd_extra_mb_rw,
       estd_pga_cache_hit_percentage, estd_overalloc_count
FROM v$pga_target_advice
ORDER BY pga_target_factor
/
SET FEEDBACK    ON