-- |----------------------------------------------------------------------------|
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : tbs_projecao_crescimento.sql                                    |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespaces Projecao de Crescimento                         |
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

COLUMN creation_time              FORMAT a20                HEADING 'Create|Time'
COLUMN name                       FORMAT a30                HEADING 'Tablespace|Name'
COLUMN curr_size_mb               FORMAT 9,999,999,999,999.9  HEADING 'Current|Size(mb)'
COLUMN growth_per_day             FORMAT 9,999,999,999,999.9  HEADING 'Growth|Per_Day(mb)'
COLUMN projection_growth_90_days  FORMAT 9,999,999,999,999.9  HEADING 'Projection Growth|90_days(mb)'
COLUMN projection_growth_180_days FORMAT 9,999,999,999,999.9  HEADING 'Projection Growth|180_days(mb)'
COLUMN projection_365_days_mb     FORMAT 9,999,999,999,999.9  HEADING 'Projection Growth|365_days(mb)'


select min(creation_time) creation_time
       ,ts.name
       ,round(sum(df.bytes) / 1024 / 1024) curr_size_mb
       ,round((sum(df.bytes) / 1024 / 1024 / 1024) /
             round(sysdate - min(creation_time))) growth_per_day
       ,round((sum(df.bytes) / 1024 / 1024 / 1024) /
             round(sysdate - min(creation_time)) * 90) projection_growth_90_days
       ,round((sum(df.bytes) / 1024 / 1024 / 1024) /
             round(sysdate - min(creation_time)) * 180) projection_growth_180_days
       ,round((sum(bytes) / 1024 / 1024 / 1024) +
             ((sum(df.bytes) / 1024 / 1024 / 1024) /
             round(sysdate - min(creation_time)) * 365)) projection_365_days_mb
  from v$datafile   df
      ,v$tablespace ts
 where df.ts# = ts.ts#
 group by df.ts#
         ,ts.name
 order by projection_365_days_mb desc ,df.ts#
/

