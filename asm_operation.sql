SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ASM Operation                                               |
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

COLUMN dt                   FORMAT a20 
COLUMN group_number         FORMAT 000 
COLUMN operation            FORMAT a15 
COLUMN state                FORMAT a10 

select to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss') data_hrs
      ,group_number
      ,operation
      ,state
      ,power
      ,actual
      ,sofar
      ,est_work
      ,est_rate
      ,est_minutes
  from v$asm_operation;
