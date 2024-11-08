-- -----------------------------------------------------------------------------------
-- ARQUIVO      : https://GUINA
-- AUTOR        : rfsobrinho
-- DESCRICAO    : EVENTOS DESDE A INICIALIZACAO DO SID
-- REQUERIMENTO : ACESSO AS V$
-- CHAMADA      : @sess_02_session_events_by_spid
-- MODIFICAOES  : 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN username FORMAT A20
COLUMN event    FORMAT A50
PROMPT +------------------------------------------------------------------------+
PROMPT | V$SESSION_EVENT ## EVENTOS DESDE A INICIALIZACAO DO SID <BY PID> ##    |
PROMPT +------------------------------------------------------------------------+
PROMPT ..

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       se.event,
       se.total_waits,
       se.total_timeouts,
       se.time_waited/100 TIME_WAITED_SEG,
       se.average_wait,
       se.max_wait,
       se.time_waited_micro
FROM   v$session_event se,
       v$session s,
       v$process p
WHERE  s.sid = se.sid
AND    s.paddr = p.addr
AND    p.spid = &1
AND    se.time_waited > 1
ORDER BY se.time_waited DESC;
