-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_lock_02.sql                                                |
-- | CLASS    :                                                                 |
-- | PURPOSE  :                                                                 |
-- | NOTE     :                                                                 |
-- |                                                                            |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessoes em locked                                           |
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

SELECT os_user_name "OS User", process "OS Pid",
       oracle_username "Oracle User", l.SID "SID",
       DECODE (TYPE,
               'MR', 'Media Recovery',
               'RT', 'Redo Thread',
               'UN', 'User Name',
               'TX', 'Transaction',
               'TM', 'DML',
               'UL', 'PL/SQL User Lock',
               'DX', 'Distributed Xaction',
               'CF', 'Control File',
               'IS', 'Instance State',
               'FS', 'File Set',
               'IR', 'Instance Recovery',
               'ST', 'Disk Space Transaction',
               'TS', 'Temp Segment',
               'IV', 'Library Cache Invalidation',
               'LS', 'Log Start or Switch',
               'RW', 'Row Wait',
               'SQ', 'Sequence Number',
               'TE', 'Extend Table',
               'TT', 'Temp Table',
               TYPE
              ) "Lock Type",
       DECODE (lmode,
               0, 'None',
               1, 'Null',
               2, 'Row-S (SS)',
               3, 'Row-X (SX)',
               4, 'Share',
               5, 'S/Row-X (SSX)',
               6, 'Exclusive',
               lmode
              ) "Lock Held",
       DECODE (request,
               0, 'None',
               1, 'Null',
               2, 'Row-S (SS)',
               3, 'Row-X (SX)',
               4, 'Share',
               5, 'S/Row-X (SSX)',
               6, 'Exclusive',
               request
              ) "Lock Requested",
       DECODE (l.BLOCK,
               0, 'Not Blocking',
               1, 'Blocking',
               2, 'Global',
               BLOCK
              ) "Status",
       owner "Owner", object_name "Object name"
  FROM v$locked_object lo, dba_objects DO, v$lock l
 WHERE lo.object_id = DO.object_id AND l.SID = lo.session_id;
