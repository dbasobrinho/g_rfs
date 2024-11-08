-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : arch_det_p_dia                                                  |
-- | CREATOR  : ROBERTO FERNANDES SOBRINHO                                      |
-- | DATE     : 31/03/2020 [QUARENTENA DO CORONA VIRUS]                         |
-- +----------------------------------------------------------------------------+
-- | REF      : 
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Detail Destination Archive                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT...
ACCEPT v_20200331  NUMBER   PROMPT '[first_time >= sysdate -:X] >> [DEFAULT=1] >> = ' DEFAULT 1 
PROMPT...


SET PAGESIZE            1000 
SET LINESIZE            230
column total_arch     format 999999
col THREAD#       for a9  'Thread'
col SEQUENCE#     for a9  'SEQUENCE#'
col first_time    for a20 'First_time'
col name          for a20 'name'

select x.THREAD#
      ,x.SEQUENCE#
      ,TO_CHAR(x.first_time, 'DD-MON-YYYY HH24:MI:SS') first_time
      ,x.name
  from v$archived_log x
  where x.first_time >= sysdate -&v_20200331
order by first_time asc, 1, x.SEQUENCE# asc
/