-- -----------------------------------------------------------------------------------
-- ARQUIVO      : https://GUINA
-- AUTOR        : rfsobrinho
-- DESCRICAO    : EVENTOS DESDE A INICIALIZAÇÃO DA INSTANCIA
-- REQUERIMENTO : ACESSO AS V$
-- CHAMADA      : @sess_01_system_events_count
-- MODIFICAOES  : 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN username FORMAT A20
COLUMN event    FORMAT A50
PROMPT +------------------------------------------------------------------------+
PROMPT | V$SYSTEM_EVENT CONT ## EVENTOS DESDE A INICIALIZAÇÃO DA INSTANCIA ##   |
PROMPT +------------------------------------------------------------------------+
PROMPT ..
 select se.event evento ,
  sum(se.time_waited)espera_total,
  round((100 * sum(se.time_waited))/aux.total) "%"
  from V$system_event se,
  (select sum(time_waited)total from v$system_event
  where wait_class != 'Idle'
  and total_timeouts >0
  and event not in ('rdbms ipc message')
  and rownum <11) aux
  where se.wait_class != 'Idle'
  and se.total_timeouts >0
  and se.event not in ('rdbms ipc message')
  and rownum <11
  group by se.event, aux.total
  order by 2 desc
/