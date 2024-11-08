-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg_recovery_progress.sql                                                   |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DG Recovery Progress                                        |
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

COLUMN START_TIME   FORMAT a22           HEAD 'START_TIME'
COLUMN TYPE         FORMAT a20           HEAD 'TYPE'
COLUMN ITEM         FORMAT a35           HEAD 'ITEM'
COLUMN UNITS        FORMAT a22           HEAD 'UNITS'
COLUMN SOFAR        FORMAT 999999        HEAD 'SOFAR'
COLUMN TOTAL        FORMAT 999999        HEAD 'TOTAL'
COLUMN TIMESTAMP    FORMAT a22           HEAD 'TIMESTAMP'

SELECT to_char(START_TIME,'dd/mm/yyyy hh24:mi:ss') START_TIME, 
       TYPE, substr(ITEM,1,35) ITEM, UNITS, SOFAR TOTAL, to_char(TIMESTAMP,'dd/mm/yyyy hh24:mi:ss')  TIMESTAMP
  FROM v$recovery_progress
/
