-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : tbs_all_12c.sql                                                  |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on all tablespaces including size and usage. This       |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespaces 12                                              |
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

COLUMN con_id      FORMAT 999                HEADING 'Con Id'
COLUMN con_name    FORMAT a10                HEADING 'Con Name'
COLUMN tablespace_name FORMAT a23            HEADING 'TBS Name'
COLUMN extent_mgt  FORMAT a10                HEADING 'Ext. Mgt.'
COLUMN segment_mgt FORMAT a10                HEADING 'Seg. Mgt.'
COLUMN total_size  FORMAT 9,999,999,999,999  HEADING 'Size (MB)'
COLUMN used        FORMAT 9,999,999,999,999  HEADING 'Used (MB)'
COLUMN free_size   FORMAT 9,999,999,999,999  HEADING 'Free (MB)'
COLUMN pct_used    FORMAT 999                HEADING 'Pct. Used'

BREAK ON report

COMPUTE sum OF total_size  ON report
COMPUTE sum OF used        ON report
COMPUTE sum OF free_size   ON report
COMPUTE avg OF pct_used    ON report

WITH x AS
 (SELECT c1.con_id
        ,cf1.tablespace_name
        ,SUM(cf1.bytes) / 1024 / 1024 fsm
    FROM cdb_free_space cf1
    JOIN v$containers c1 ON cf1.con_id = c1.con_id
   GROUP BY c1.con_id
           ,cf1.tablespace_name),
y AS
 (SELECT c2.con_id
        ,cd.tablespace_name
        ,SUM(cd.bytes) / 1024 / 1024 apm
    FROM cdb_data_files cd
    JOIN v$containers c2 ON cd.con_id = c2.con_id
   GROUP BY c2.con_id
           ,cd.tablespace_name)
SELECT x.con_id          as con_id
      ,v.name            as con_name
      ,x.tablespace_name as tablespace_name
      ,y.apm             as total_size
      ,x.fsm             as free_size
  FROM x
  JOIN y ON x.con_id = y.con_id
        AND x.tablespace_name = y.tablespace_name
  JOIN v$containers v ON v.con_id = y.con_id
UNION
SELECT vc2.con_id          as con_id
      ,vc2.name            as con_name
      ,tf.tablespace_name  as tablespace_name
      ,SUM(tf.bytes) / 1024 / 1024 as total_size
      ,null                as free_size
  FROM v$containers vc2
  JOIN cdb_temp_files tf ON vc2.con_id = tf.con_id
 GROUP BY vc2.con_id
         ,vc2.name
         ,tf.tablespace_name
 ORDER BY 1,2
/
