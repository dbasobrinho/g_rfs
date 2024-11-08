-- -----------------------------------------------------------------------------------
-- ARQUIVO      : https://GUINA
-- AUTOR        : rfsobrinho
-- DESCRICAO    : EVENTOS DESDE A INICIALIZACAO DO SID
-- REQUERIMENTO : ACESSO AS V$
-- CHAMADA      : @sess_03_session_waits_by_sid
-- MODIFICAOES  : 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000
PROMPT +------------------------------------------------------------------------+
PROMPT | GV$SESSION_WAIT ## EVENTOS DO QUE ESTA ACONTECENDO AGORA <BY SID> ##   |
PROMPT +------------------------------------------------------------------------+
PROMPT ..

COLUMN username    FORMAT A20
COLUMN event       FORMAT A50
COLUMN wait_class  FORMAT A15

SELECT s.inst_id,
       NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_class,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state
FROM   gv$session_wait sw,
       gv$session s
WHERE  s.sid     = sw.sid
AND    s.inst_id = sw.inst_id
AND    sw.wait_class != 'Idle'
AND    s.sid = &1
ORDER BY sw.seconds_in_wait DESC;
