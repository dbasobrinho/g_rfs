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
PROMPT | Report   : Show received archived logs on physical standby             |
PROMPT | Report   : (Run this query on physical standby)                        |
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
select registrar, creator, thread#, sequence#, first_change#, next_change# from v$archived_log order by first_change#, next_change#
/


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
SELECT c.DATABASE_ROLE, 
       c.PROTECTION_MODE,
	   C.SWITCHOVER_STATUS,
       a.thread# thread, 
       b. last_seq STANDBY_LAST_RECEIVED , 
       a.applied_seq STANDBY_LAST_APPLIED, 
       TO_CHAR(a.last_app_timestamp,'DD/MM/YYYY HH24:MI:SS') as STANDBY_DT_LAST_APP,
	   TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI:SS') as data_atual,
	   (sysdate - a.last_app_timestamp) *24*60  as MINUTOS,
       b.last_seq - a.applied_seq ARC_DIFF ,
      (select value from v$parameter a where name = 'log_archive_config') REPLICACAO_DG   
FROM   (SELECT thread#, 
               Max(sequence#) applied_seq, 
               Max(next_time) last_app_timestamp 
        FROM   gv$archived_log 
        WHERE  applied = 'YES' 
		and resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
        GROUP  BY thread#) a, 
       (SELECT thread#, 
               Max (sequence#) last_seq 
        FROM   gv$archived_log 
		where resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
        GROUP  BY thread#) b,
		(SELECT DATABASE_ROLE, DB_UNIQUE_NAME INSTANCE, OPEN_MODE, PROTECTION_MODE, PROTECTION_LEVEL, SWITCHOVER_STATUS FROM V$DATABASE) c
WHERE  a.thread# = b.thread#
/

