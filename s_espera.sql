-- verifica_performance.sql
-- script revisado por Lilian Barroso em 15-05-2015
-- Objectivo: verificar as maiores waits do banco de dados no momento.


col usuario for a20
col evento_espera for a40
col sessao for a15
col program for a60
col tempo for 999999999
col inst_id for 99

set feed off

prompt

SELECT  '''' || s.SID ||','|| s.serial# ||  '@' || s.inst_id ||  '''' as sessao,
                S.username                                                                      usuario,
                p.spid                                                                          processo_SO,
                S.program,
                s.EVENT                                                                         evento_espera,
                s.SECONDS_IN_WAIT                                                       tempo,
                s.SQL_id                                                                        sql_id
FROM    GV$SESSION S,
                  GV$PROCESS P
WHERE S.PADDR = P.ADDR
 AND  upper(S.EVENT) NOT IN ( 'DISPATCHER TIMER',
                              'PIPE GET',
                              'PMON TIMER',
                              'PX IDLE WAIT',
                              'PX DEQ CREDIT: NEED BUFFER',
                              'RDBMS IPC MESSAGE',
                              'SMON TIMER',
                              'SQL*NET MESSAGE FROM CLIENT',
                              'VIRTUAL CIRCUIT STATUS',
                              'STREAMS AQ: WAITING FOR TIME MANAGEMENT OR CLEANUP TASKS',
                              'STREAMS AQ: QMN SLAVE IDLE WAIT',
                              'STREAMS AQ: QMN COORDINATOR IDLE WAIT')
AND S.WAIT_CLASS != 'Idle'
  and S.SECONDS_IN_WAIT > 3
ORDER BY  S.SECONDS_IN_WAIT, S.SID
--  ORDER BY 3
/

prompt

