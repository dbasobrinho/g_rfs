-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : tbs_quotas_by_user.sql                                          |
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
PROMPT | Report   : Tablespace Quotas by User                                   |
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

COLUMN tablespace_name FORMAT a30                  HEADING "Tablespace Name"
COLUMN username        FORMAT a20                  HEADING "username"
COLUMN max_bytes       FORMAT 9,999,999,999,999    HEADING "max_bytes (in Bytes)"

select tablespace_name
      ,username
      ,max_bytes
  from dba_ts_quotas
 where username = '&username';

