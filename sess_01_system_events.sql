-- -----------------------------------------------------------------------------------
-- ARQUIVO      : https://GUINA
-- AUTOR        : rfsobrinho
-- DESCRICAO    : EVENTOS DESDE A INICIALIZAÇÃO DA INSTANCIA
-- REQUERIMENTO : ACESSO AS V$
-- CHAMADA      : @sess_01_system_events
-- MODIFICAOES  : 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN username FORMAT A20
COLUMN event    FORMAT A50
PROMPT +------------------------------------------------------------------------+
PROMPT | V$SYSTEM_EVENT  ## EVENTOS DESDE A INICIALIZAÇÃO DA INSTANCIA ##       |
PROMPT +------------------------------------------------------------------------+
PROMPT ..
SELECT event,
       total_waits,
       total_timeouts,
       time_waited/100 time_waited_seg,
       average_wait,
       time_waited_micro
FROM v$system_event
where time_waited/100 > 2
ORDER BY time_waited_seg desc 
/
