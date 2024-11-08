-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg_status.sql                                                   |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Exibir informações atuais de status para processos          |
PROMPT | Report   : physical standby database background processes              |
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

COLUMN FACILITY          FORMAT a13       
COLUMN SEVERITY          FORMAT a08
COLUMN DEST_ID           FORMAT 99        HEAD 'DEST' justify CENTER 
COLUMN MESSAGE_NUM       FORMAT 999999    HEAD 'MSG|NUM' justify CENTER      
COLUMN ERROR_CODE        FORMAT 999999    HEAD 'ERROR|COD' justify CENTER            
COLUMN CALLOUT           FORMAT a3           
COLUMN MESSAGE           FORMAT a110      
     
SET COLSEP '|'
SET FEEDBACK    0
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
SET FEEDBACK    6
SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY 
/