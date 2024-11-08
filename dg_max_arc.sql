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
PROMPT | Report   : DG MAX ARCHIVE                                              |
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

COLUMN REPLICACAO_DG          FORMAT a28        HEAD 'REPLICACAO DG|CONFIGURACAO' justify CENTER 
COLUMN STANDBY_LAST_RECEIVED  FORMAT 9999999    HEAD 'ULTIMO ARC|RECEBIDO STBY'   justify CENTER 
COLUMN STANDBY_LAST_APPLIED   FORMAT 9999999    HEAD 'ULTIMO ARC|APLICADO STBY'   justify CENTER   
COLUMN STANDBY_DT_LAST_APP    FORMAT a19        HEAD 'ULTIMA DATA|APLICADO STBY'  justify CENTER 
COLUMN data_atual             FORMAT a19        HEAD 'DATA| ATUAL'                justify CENTER 
COLUMN MINUTOS                FORMAT 999999     HEAD 'DIFERENCA|MIN'              justify CENTER 
COLUMN ARC_DIFF               FORMAT 999999     HEAD 'DIFERENCA|ARC'              justify CENTER 
COLUMN DATABASE_ROLE          FORMAT a16        HEAD 'DATABASE|PERFIL'            justify CENTER 
COLUMN PROTECTION_MODE        FORMAT a20        HEAD 'MODO|PROTECAO'              justify CENTER 
COLUMN thread                 FORMAT 99999      HEAD 'THREAD'                     justify CENTER 
COLUMN SWITCHOVER_STATUS      FORMAT a16        HEAD 'SWITCHOVER|STATUS'          justify CENTER 
SET COLSEP '|'
SET FEEDBACK    0
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

select thread#,max(sequence#) from v$archived_log group by thread#;