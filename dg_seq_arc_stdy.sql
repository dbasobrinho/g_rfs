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
PROMPT | Report   : DG Status Replicacao                                        |
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
SET FEEDBACK    6
SELECT thread#,applied, 
               Max(sequence#) MAX_applied_seq, 
               Max(next_time) MAX_last_app_timestamp ,
               MIN(sequence#) MIN_applied_seq, 
               MIN(next_time) MIN_last_app_timestamp ,
			   Max(sequence#) - MIN(sequence#) DIFF
        FROM   gv$archived_log 
        WHERE  applied = 'NO' 
		and resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
        GROUP  BY thread#, applied


SELECT thread#,applied, 
               (sequence#) ARC_seq, 
               (next_time) next_time 
        FROM   gv$archived_log 
        WHERE  applied = 'NO' 
		and resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
        ORDER BY   thread#,  ARC_seq, next_time


set serveroutput on
set feedback off
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
declare
  c number;
begin
  select count (0) into c from v$ARCHIVED_LOG where RESETLOGS_CHANGE# = (SELECT MAX(RESETLOGS_CHANGE#) FROM v$ARCHIVED_LOG) and standby_dest='YES' and APPLIED='NO';
if c > 2 then
   dbms_output.put_line('###############################');
   dbms_output.put_line('VERIFICAR O SINCRONISMO DO DATAGUARD, EXISTEM PROBLEMAS');
   dbms_output.put_line('###############################');
else
     dbms_output.put_line('###############################');
     dbms_output.put_line('O DATAGUARD ESTA SINCRONIZADO!');
     dbms_output.put_line('###############################');
  end if;

end;
/
