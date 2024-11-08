-- alert.sql
-- Script criado por Lilian Barroso em 12-05-2015
-- Objetivo: analisar o alert.log da instncia.
-- Observao: o sinnimo v$alert_log tem de ter sido criado previamente.
-- 1 = Trace, 2 = Alert, 3 Ambos
-- EXEC dbms_system.ksdwrt(3, 'ORA-00600: internal error code, arguments: Where is the malboro?'); 


  -- COMANDOS PARA CRIAO DO SINONIMO:
  -- CREATE VIEW v_alert_log AS SELECT * FROM x$dbgalertext;
  -- CREATE PUBLIC SYNONYM v_alert_log FOR sys.v_alert_log;
  -- GRANT SELECT ON v_alert_log TO system;
--   script para ver se houve erros no alert.log ultimos 2 dias.
col data         for a22
col message_text for a142
PROMPT *****  ULTIMAS 300 LINHAS ********
PROMPT
 select to_char (ORIGINATING_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') data, message_text
                from v_alert_log
                where indx > (select count(*)-300 from v_alert_log );
 prompt
 promPT  **Erros Encontrados ultimos 2 dias**
 prompt
 select to_char (ORIGINATING_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') data, message_text
                from v_alert_log
                where trunc(ORIGINATING_TIMESTAMP) >  trunc((SYSDATE) -2)
                  and (message_text like '%ORA-%'
                       or message_text like '%cannot allocate new log%'
                           or message_text like 'TNS-%');
