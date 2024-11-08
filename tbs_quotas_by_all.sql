-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : tbs_quotas_by_all.sql                                          |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  :                                                                 |
-- |                                                                            |
-- | NOTE     :                                                                 |
-- |                                                                            |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespace Quotas all                                       |
PROMPT | Instance : &current_instance                                           |
PROMPT | alter user <username> quota <size> on <tablespace>                     |
PROMPT | alter user <username> quota unlimited on <tablespace>                  |
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

COLUMN dropped FORMAT a9                  HEADING "DROPPED"

select tablespace_name, username, 
case when max_bytes > 0 then (bytes / 1024 ) else bytes end mb, 
case when max_bytes > 0 then (max_bytes / 1024 ) else max_bytes end max_mb, 
blocks, max_blocks, dropped 
from dba_ts_quotas order by username
/
