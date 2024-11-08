
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    200
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES



--> 1) Basic information of database (primary or standby)
PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 1) Basic information of database (primary or standby)                                                                               |
PROMPT |          :                                                                                                                                     |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
COLUMN REPLICACAO_DG          FORMAT a31        HEAD 'REPLICACAO DG|CONFIGURACAO' justify CENTER
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
SELECT DATABASE_ROLE, DB_UNIQUE_NAME INSTANCE, OPEN_MODE, PROTECTION_MODE, PROTECTION_LEVEL, SWITCHOVER_STATUS FROM V$DATABASE
/
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
PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 2) Check for messages/errors Last 7 days                                                                                            |
PROMPT |          :                                                                                                                                     |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 2) Check for messages/errors
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
SELECT SUBSTR(FACILITY,1,13) FACILITY,  SUBSTR(SEVERITY,1,7)SEVERITY, DEST_ID, MESSAGE_NUM, ERROR_CODE, CALLOUT, TIMESTAMP, ' '||MESSAGE MESSAGE
FROM V$DATAGUARD_STATUS where TIMESTAMP > sysdate - 8 ORDER BY MESSAGE_NUM desc
/

PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   :3) To display current status information for specific physical standby database background processes                                 |
PROMPT |          :                                                                                                                                     |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 3) To display current status information for specific physical standby database background processes.
SELECT PID, PROCESS, STATUS, CLIENT_PROCESS,  CLIENT_PID, THREAD#, SEQUENCE# SEQ#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY ;

PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 4) Show received archived logs on physical standby last 50 rows                                                                     |
PROMPT |          :                                                                                                                                     |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 4) Show received archived logs on physical standby (Run this query on physical standby)
select * from(
select registrar, creator, thread#, sequence#, first_change#, next_change# from v$archived_log order by first_change# desc , next_change# desc
) where rownum < 51 order by first_change# , next_change# 
/

PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 5) To check the log status                                                                                                          |
PROMPT |          :                                                                                                                                     |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 5) To check the log status
select 'Last Log applied : ' Logs, to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time
from v$archived_log
where sequence# = (select max(sequence#) from v$archived_log where applied='YES')
union
select 'Last Log received : ' Logs, to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time
from v$archived_log
where sequence# = (select max(sequence#) from v$archived_log);

PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 6) To display various information about the redo data. includes redo data generated by the primary database that is not yet         |
PROMPT |          :    available on the standby database and how much redo has not yet been applied to the standby database.                            |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 6) To display various information about the redo data. This includes redo data generated by the primary database that is not yet available on the standby database and how much redo has not yet been applied to the standby database.
column lag_time format a17
column datum_time format a28
column TIME_COMP  format a28
column UNIQUE_NAME  format a11
column NAME         format a25
SELECT SOURCE_DBID           DBID
     , SOURCE_DB_UNIQUE_NAME UNIQUE_NAME
         , NAME                  NAME
         , VALUE                                 LAG_TIME
         , DATUM_TIME                    DATUM_TIME
         , TIME_COMPUTED         TIME_COMP
         , UNIT                  UNIT
from V$DATAGUARD_STATS
/
PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 7) to monitor efficient recovery operations as well as to                                                                           |
PROMPT |          :    estimate the time required to complete the current operation in progress:                                                        |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 7) to monitor efficient recovery operations as well as to estimate the time required to complete the current operation in progress:
select to_char(start_time, 'DD-MON-RR HH24:MI:SS') start_time, item, SOFAR || ' ' || UNITS Sofar
from v$recovery_progress
where  ITEM IN ('Active Apply Rate', 'Average Apply Rate', 'Redo Applied');

PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 8) To find last applied log [SEQUENCE#]                                                                                             |
PROMPT |          :                                                                                                                                     |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 8) To find last applied log [SEQUENCE#]
select to_char(max(FIRST_TIME),'hh24:mi:ss dd/mm/yyyy') FROM V$ARCHIVED_LOG where applied='YES';

PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 9) To see if standby redo logs have been created. The standby redo logs should be the same size as the online redo logs.            |
PROMPT |          :    There should be (( # of online logs per thread + 1) * # of threads) standby redo logs.                                           |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 9) To see if standby redo logs have been created. The standby redo logs should be the same size as the online redo logs. There should be (( # of online logs per thread + 1) * # of threads) standby redo logs. A value of 0 for the thread# means the log has never been allocated.
SELECT thread#, group#, sequence#, bytes, archived, status FROM v$standby_log order by thread#, group#;

PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 10) To produce a list of defined archive destinations. It shows if they are enabled, what process is servicing that destination,    |
PROMPT |          :     if the destination is local or remote, and if remote what the current mount ID is. For a physical standby we should have        |
PROMPT |          :     least one remote destination that points the primary set.                                                                       |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--> 10) To produce a list of defined archive destinations. It shows if they are enabled, what process is servicing that destination, if the destination is local or remote, and if remote what the current mount ID is. For a physical standby we should have at least one remote destination that points the primary set.
column destination format a35 wrap
column process format a7
column ID format 99
column mid format 99
column ERROR format 50
SELECT thread#, dest_id, destination, gvad.status,  substr(gvad.ERROR,1,50)ERROR,  target, schedule, process, mountid mid FROM gv$archive_dest gvad, gv$instance gvi WHERE gvad.inst_id = gvi.inst_id AND destination is NOT NULL ORDER BY thread#, dest_id;

PROMPT ..
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT | Report   : 11) Verify the last sequence# received and the last sequence# applied to standby database.                                          |
PROMPT |          :                                                                                                                                     |
PROMPT +------------------------------------------------------------------------------------------------------------------------------------------------+
PROMPT ..
--11) Verify the last sequence# received and the last sequence# applied to standby database.
 SELECT al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied" FROM (select thread# thrd, MAX(sequence#) almax FROM v$archived_log WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v$database) GROUP BY thread#) al, (SELECT thread# thrd, MAX(sequence#) lhmax FROM v$log_history WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v$database) GROUP BY thread#) lh WHERE al.thrd = lh.thrd;

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

