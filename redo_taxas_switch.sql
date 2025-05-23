--Script: REDO_TAXAS_SWITCH (REDO LOG SWITCH RATES)
--Data:   31/07/2012
--Autor: Marcio Guimaraes
--Finalidade: Lista TAXAS DE SWITCHES DE REDO LOG.
--Vers�o: 1.0 





col min_minutes format 999.99 
col max_minutes format 999.99 
col avg_minutes format 999.99 
set pagesize 1000
set lines 70
set echo on 

WITH log_history AS
       (SELECT thread#, first_time,
               LAG(first_time) OVER (ORDER BY thread#, sequence#)
                  last_first_time,
               (first_time
                - LAG(first_time) OVER (ORDER BY thread#, sequence#))
                    * 24* 60   last_log_time_minutes,
               LAG(thread#) OVER (ORDER BY thread#, sequence#)
                   last_thread#
        FROM v$log_history)
SELECT ROUND(MIN(last_log_time_minutes), 2) min_minutes,
       ROUND(MAX(last_log_time_minutes), 2) max_minutes,
       ROUND(AVG(last_log_time_minutes), 2) avg_minutes
FROM log_history
WHERE     last_first_time IS NOT NULL
      AND last_thread# = thread#
      AND first_time > SYSDATE - 1; 