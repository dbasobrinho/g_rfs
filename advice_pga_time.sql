 
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : pga advice time                     +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+ 
SET ECHO        OFF
SET FEEDBACK    6
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
SET FEEDBACK    OFF
col current_size_mb format 99,999 heading "Current|MB"
col pga_target_mb format 99,999 heading "Target|MB"
col estd_seconds_delta format 99,999,999.99 heading "Estimated|time delta (s)"
col estd_extra_mb_rw format 99,999,999 heading "Estimated|extra MB"
set pagesize 1000
set lines 1000 
--set echo on 

SELECT current_size / 1048576 current_size_mb,
       pga_target_for_estimate / 1048576 pga_target_mb,
       (estd_extra_bytes_rw - current_extra_bytes_rw)
          * 0.1279 / 1000000 AS estd_seconds_delta, 
       estd_extra_bytes_rw / 1048576 estd_extra_mb_rw
FROM v$pga_target_advice, 
     (SELECT pga_target_for_estimate current_size,
             estd_extra_bytes_rw current_extra_bytes_rw
        FROM v$pga_target_advice
       WHERE pga_target_factor = 1)
/	  
SET FEEDBACK    ON 