-- -----------------------------------------------------------------------------------
-- Call Syntax  : @advice_db_cache
-- -----------------------------------------------------------------------------------
 
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : db_cache_size advice                +-+-+-+-+-+-+-+-+-+-+   |
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
COLUMN block_size FORMAT 999,999
COLUMN Cache_Size                 FORMAT 999,999         heading 'Cache Size|(GB)'          justify CENTER
COLUMN estd_physical_read_factor  FORMAT 999.90          heading 'Read|Factor'              justify CENTER
COLUMN buffers_for_estimate       FORMAT 999,999,999     heading 'Buffers|Estimate'         justify CENTER
COLUMN estd_physical_reads        FORMAT 999,999,999,999 heading 'Physical Reads|Estimate'  justify CENTER
COLUMN estd_physical_reads        FORMAT 999,999,999,999 heading 'Physical Reads|Estimate'  justify CENTER
COLUMN block_sizes                FORMAT a05             heading 'Block|Size'               justify CENTER
COLUMN ESTD_PCT                   FORMAT 999             heading 'Read|Disk%'               justify CENTER
SELECT size_for_estimate        as Cache_Size, --name,
       estd_physical_read_factor,SIZE_FACTOR,
       buffers_for_estimate,
       estd_physical_reads,
	   ESTD_PCT_OF_DB_TIME_FOR_READS as ESTD_PCT,
	   block_size/1024||' KB'  block_sizes
FROM   v$db_cache_advice
WHERE  name          = 'DEFAULT'
AND    block_size    = (SELECT value
                        FROM   v$parameter
                        WHERE  name = 'db_block_size')
AND    advice_status = 'ON'
order by SIZE_FACTOR
/
SET FEEDBACK    ON