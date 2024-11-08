-- |----------------------------------------------------------------------------|
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
COLUMN current_instance_nt NEW_VALUE current_instance_nt NOPRINT;
SELECT rpad(instance_name, 17) current_instance, instance_name current_instance_nt FROM v$instance;
SET TERMOUT ON;
PROMPT  
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : CPU E ESPERA / CLASSE EVENTOS CADA MINUTO ULTIMAS 2 HORAS   |
PROMPT |          :                                     +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET PAGESIZE    1000
SET LINESIZE    500
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR           COLUMNS
CLEAR           BREAKS
CLEAR           COMPUTES
set lines 400
col sample_time for a14
col CONFIGURATION head "CONFIG" for 99.99
col ADMINISTRATIVE head "ADMIN" for 99.99
col OTHER for 99.99
 
SELECT INST_ID,
       TO_CHAR(SAMPLE_TIME, 'HH24:MI ') AS SAMPLE_TIME,
       ROUND(OTHER / 60, 3) AS OTHER,
       ROUND(CLUST / 60, 3) AS CLUST,
       ROUND(QUEUEING / 60, 3) AS QUEUEING,
       ROUND(NETWORK / 60, 3) AS NETWORK,
       ROUND(ADMINISTRATIVE / 60, 3) AS ADMINISTRATIVE,
       ROUND(CONFIGURATION / 60, 3) AS CONFIGURATION,
       ROUND(COMMIT / 60, 3) AS COMMIT,
       ROUND(APPLICATION / 60, 3) AS APPLICATION,
       ROUND(CONCURRENCY / 60, 3) AS CONCURRENCY,
       ROUND(SIO / 60, 3) AS SYSTEM_IO,
       ROUND(UIO / 60, 3) AS USER_IO,
       ROUND(SCHEDULER / 60, 3) AS SCHEDULER,
       ROUND(CPU / 60, 3) AS CPU,
       ROUND(BCPU / 60, 3) AS BACKGROUND_CPU
  FROM (SELECT TRUNC(SAMPLE_TIME, 'MI') AS SAMPLE_TIME,
               DECODE(SESSION_STATE,
                      'ON CPU',
                      DECODE(SESSION_TYPE, 'BACKGROUND', 'BCPU', 'ON CPU'),
                      WAIT_CLASS) AS WAIT_CLASS, INST_ID
          FROM GV$ACTIVE_SESSION_HISTORY
         WHERE SAMPLE_TIME > SYSDATE - INTERVAL '2' HOUR AND SAMPLE_TIME <= TRUNC(SYSDATE, 'MI')) ASH PIVOT(COUNT(*) 
FOR WAIT_CLASS IN('ON CPU' AS CPU,'BCPU' AS BCPU,
'Scheduler' AS SCHEDULER,
'User I/O' AS UIO,
'System I/O' AS SIO,
'Concurrency' AS CONCURRENCY,
'Application' AS  APPLICATION,
'Commit' AS  COMMIT,
'Configuration' AS CONFIGURATION,
'Administrative' AS   ADMINISTRATIVE,
'Network' AS  NETWORK,
'Queueing' AS   QUEUEING,
'Cluster' AS   CLUST,
'Other' AS  OTHER))
order by SAMPLE_TIME, INST_ID
/
 
