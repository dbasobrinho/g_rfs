--Script: REDO_TOTAL_WAITS
--Data:   05/07/2014
--Autor: Marcio Guimaraes
--Finalidade: exibe o total de esperas por Redo Log File

SELECT EVENT,TOTAL_WAITS,TIME_WAITED,TIME_WAITED_MICRO
FROM V$SYSTEM_EVENT
WHERE EVENT LIKE '%log file%';