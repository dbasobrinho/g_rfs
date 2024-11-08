--Script: REDO_LOG_BUFFER_WAITS
--Data:   30/09/2013
--Autor: Marcio Guimaraes
--Finalidade: exibe o total de esperas por redo log buffer

SELECT NAME, VALUE FROM V$SYSSTAT WHERE NAME = 'redo buffer allocation retries';
