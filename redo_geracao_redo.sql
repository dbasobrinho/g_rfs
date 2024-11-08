--Script: REDO_GERACAO_REDO
--Data:   21/09/2012
--Autor: Marcio Guimaraes
--Finalidade: Mostrar a geração de Redo Log Buffer

col name format a30 heading 'Statistic|Name'
col value heading 'Statistic|Value'
start title80 "Redo Log Statistics"
SELECT name, value
FROM v$sysstat
WHERE name like '%redo%'
order by name;