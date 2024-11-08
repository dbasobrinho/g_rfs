--Script: REDO_TOTAL_GERADO_BYTES
--Data:   30/09/2013
--Autor: Marcio Guimaraes
--Finalidade: exibe o total de bytes de redo log gerados

select n.name, t.value from v$mystat t join v$statname n 
on t.statistic# = n.statistic# where n.name = 'redo size';
