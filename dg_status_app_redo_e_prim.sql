-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg_status_app_redo_e_prim.sql                                   |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DG Detalhes de estatisticas de atraso de aplicacao de redos |
PROMPT |            no standby (executar no Bd primario)                        |                       
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

COLUMN timestamp       FORMAT a19       HEAD 'Date' 
COLUMN facility        FORMAT 99        HEAD 'facility'    
COLUMN dest_id         FORMAT 99        HEAD 'Dest|Id'  
COLUMN message_num     FORMAT 9999999   HEAD 'Message|Num'
COLUMN error_code      FORMAT 999999    HEAD 'Error|Cod'    
COLUMN message         FORMAT a100      HEAD 'Message'

select to_char(timestamp, 'dd/mm/yyyy hh24:mi:ss') timestamp, facility, dest_id, message_num, error_code, message
from  v$dataguard_status
order by  timestamp asc            
/

