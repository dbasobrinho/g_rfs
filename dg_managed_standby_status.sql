-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg_managed_standby_status.sql                                   |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DG Service Managed Standby Status                           |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT |No BD primario vc deverá ver o processo LNS escrevendo para o ultimo log|
PROMPT |No BD standby vc deverá ver 1 ou mais processos RFS e o processo MRPn   |
PROMPT |aplicando o log (APPLYING_LOG) de mesmo numero que o LNS esta escrevendo| 
PROMPT |no primario                                                             |
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

select process, status, sequence#, block# from v$managed_standby
/
