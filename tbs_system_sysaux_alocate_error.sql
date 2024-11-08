-- |----------------------------------------------------------------------------|
-- |----------------------------------------------------------------------------|
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespace System Sysaux Alocate Error                      |
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

COLUMN tablespace_name FORMAT a30                  HEADING "Tablespace Name"
COLUMN segment_name    FORMAT a30                  HEADING "Segment Name"
COLUMN owner           FORMAT a20                  HEADING "Owner"
COLUMN segment_type    FORMAT a20                  HEADING "Segment Type"
COLUMN bytes           FORMAT 9,999,999,999,999    HEADING "Size (in Bytes)"
COLUMN seg_count       FORMAT 9,999,999,999        HEADING "Segment Count"



BREAK ON report ON tablespace_name SKIP 2

COMPUTE sum LABEL ""                OF seg_count "Size MB" ON tablespace_name
COMPUTE sum LABEL "Grand Total: "   OF seg_count "Size MB" ON report

SELECT tablespace_name
      ,owner
      ,segment_name
      ,segment_type
      ,sum(bytes) / 1024 / 1024 "Size MB"
      ,count(*) seg_count
  FROM dba_segments
 where tablespace_name in ('SYSTEM', 'SYSAUX')
   AND segment_name NOT LIKE '%$%'
   AND segment_name NOT LIKE 'SYS%'
   AND segment_name NOT LIKE 'OLAPI%'
   AND segment_name NOT LIKE 'LOGMN%'
   AND segment_name NOT LIKE 'I_%'
   AND segment_name NOT LIKE 'C_%'
   AND segment_name NOT LIKE 'DBMS%'
   AND segment_name NOT LIKE 'UTL%'
   AND segment_name NOT LIKE 'SMON%'
   AND segment_name NOT LIKE 'PK%'
   AND segment_name NOT IN ('HELP', 'ALERT_QT', 'METASTYLESHEET')
   and segment_type not in ('LOBSEGMENT', 'CLUSTER')
   AND owner NOT IN ('CTXSYS',
                     'DBSNMP',
                     'EXFSYS',
                     'MDSYS',
                     'OLAPSYS',
                     'ORDSYS',
                     'SYSMAN',
                     'XDB',
                     'WMSYS',
                     'TSMSYS')
 GROUP BY tablespace_name
         ,owner
         ,segment_type
         ,segment_name
having sum(bytes) <> 65536
 ORDER BY 1,2,3
/

