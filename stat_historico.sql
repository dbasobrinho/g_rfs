PROMPT
PROMPT
PROMPT  HISTORICO DE COLETA DE ESTATISTICAS DE UMA DETERMINADA TABELA
PROMPT  EXEMPLO PARA RESTAURAR AS ESTATISTICAS:
PROMPT DBMS_STATS.RESTORE_SCHEMA_STATS(OWNNAME => 'SH',AS_OF_TIMESTAMP => SYSTIMESTAMP – 1, FORCE => TRUE)
PROMPT
PROMPT
set lines 1000
set pages 1000


PROMPT QUANTIDADE DE DIAS DE RETENCAO DO HISTORICO DE ESTATISTICAS
PROMPT
SELECT dbms_stats.get_stats_history_retention() AS retention
 FROM dual;

 
col operation form a30
col target form a60
col duration form a40
col start_time form a22 


PROMPT
PROMPT

PROMPT HISTORICO DE TODAS AS ESTATISTICAS EXECUTADAS NO BANCO
PROMPT

SELECT substr(operation,1,30) operation, target, to_char(start_time,'dd/mm/yyyy hh24:mi:ss') start_time,
 (end_time-start_time) DAY(1) TO SECOND(0) AS duration
 FROM dba_optstat_operations
 ORDER BY start_time DESC; 
 
PROMPT HISTORICO DE DETERMINADA TABELA
PROMPT
SELECT stats_update_time
 FROM dba_tab_stats_history
 WHERE owner = '&owner' and table_name = '&table';
 

