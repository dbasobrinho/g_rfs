SET TERMOUT OFF; 
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : shared pool advice                  +-+-+-+-+-+-+-+-+-+-+   |
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
 
column c1 FORMAT 999,900.00         heading 'Pool |Size(GB)'               justify CENTER
column c2 FORMAT 999.00             heading 'Size|Factor'                  justify CENTER  
column c3 FORMAT 999,999.00         heading 'Estimate|LC(GB)'              justify CENTER
column c4                           heading 'Estimate|LC Mem.Obj.'         justify CENTER
column c5                           heading 'Estimate Time|Saved (HRS)'    justify CENTER
column c8 FORMAT 999,999.00         heading 'Estimate|Load Time'           justify CENTER
column c6                           heading 'Estimate|Parse Factor'        justify CENTER
column c7 format 999,999,999,999    heading 'Estimate|Object Hits'         justify CENTER
column c3 FORMAT 999,999.00         heading 'Estimate|Load Time'           justify CENTER
 
SELECT
   shared_pool_size_for_estimate/1024    c1,
   ROUND(shared_pool_size_factor,2)      c2,
   estd_lc_size/1024                     c3,
   estd_lc_memory_objects                c4,
   ROUND(estd_lc_time_saved/60/60)        c5,
  -- ROUND(ESTD_LC_LOAD_TIME_FACTOR,2)     c8,
   estd_lc_time_saved_factor             c6,
   estd_lc_memory_object_hits            c7
FROM
   v$shared_pool_advice
/
SET FEEDBACK    ON
--- SHARED_POOL_SIZE_FOR_ESTIMATE		NUMBER	Shared pool size for the estimate (in megabytes)
--- SHARED_POOL_SIZE_FACTOR				NUMBER	Size factor with respect to the current shared pool size
--- ESTD_LC_SIZE						NUMBER	Estimated memory in use by the library cache (in megabytes)
--- ESTD_LC_MEMORY_OBJECTS				NUMBER	Estimated number of library cache memory objects in the shared pool of the specified size
--- ESTD_LC_TIME_SAVED					NUMBER	Estimated elapsed parse time saved (in seconds), owing to library cache memory objects being found in a shared pool of the specified size. This is the time that would have been spent in reloading the required objects in the shared pool had they been aged out due to insufficient amount of available free memory.
--- ESTD_LC_TIME_SAVED_FACTOR			NUMBER	Estimated parse time saved factor with respect to the current shared pool size
--- ESTD_LC_LOAD_TIME					NUMBER	Estimated elapsed time (in seconds) for parsing in a shared pool of the specified size
--- ESTD_LC_LOAD_TIME_FACTOR			NUMBER	Estimated load time factor with respect to the current shared pool size
--- ESTD_LC_MEMORY_OBJECT_HITS			NUMBER	Estimated number of times a library cache memory object was found in a shared pool of the specified size