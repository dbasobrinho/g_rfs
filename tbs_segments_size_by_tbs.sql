-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 2020 Roberto Fernandes Sobrinho                         |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : tbs_segments_size_by_tbs.sql                                    |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Size segments by TBS                                            |
-- | NOTE     :                                                                 |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Size Segment by Tablespace          +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT
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

PROMPT
ACCEPT tbsnamexxxxx CHAR PROMPT 'Enter TABLESPACE_NAME  : '
PROMPT
COLUMN segment_type        FORMAT A20                HEADING 'Segment Type'
COLUMN owner               FORMAT A15                HEADING 'Owner'
COLUMN segment_name        FORMAT A30                HEADING 'Segment Name'
COLUMN partition_name      FORMAT A30                HEADING 'Partition Name'
COLUMN tablespace_name     FORMAT A20                HEADING 'Tablespace Name'
COLUMN bytes               FORMAT 9,999,999,999,999  HEADING 'Size (in bytes)'
COLUMN extents             FORMAT 999,999,999        HEADING 'Extents'
column SEGMENT_NAME     format a30
column SEGMENT_TYPE     format a15
column TABLESPACE_NAME  format a30
column seg_size         format a30
SELECT * FROM
 (select
 SEGMENT_NAME,
 SEGMENT_TYPE,
 dbms_xplan.format_size(BYTES) seg_size,
 TABLESPACE_NAME
 from
 dba_segments
 order by BYTES desc ) 
WHERE TABLESPACE_NAME = upper('&&tbsnamexxxxx')
/ 


