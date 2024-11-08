--Script: REDO_INFORMACOES
--Data:   07/08/2014
--Autor: Marcio Guimaraes
--Finalidade: Exibe informações a respeito de redo logs
--Versão: 1.0 
col member format a50

select a.thread#, a.group#, b.member,  round(bytes/1024,0) kb, a.members, a.status, b.status ST_LogFile
from v$log a, v$logfile b
where
a.group#=b.group#
order by 1,2;

SELECT name, value 
   FROM v$sysstat 
   WHERE name = 'redo log space requests'; 

prompt "Contencao de latch para taxas maiores que 1%";
  SELECT
   substr(ln.name, 1, 20), gets, misses, immediate_gets, immediate_misses ,
   round((misses / gets) * 100,2) taxa,
   round(immediate_misses / decode((immediate_gets+immediate_misses),0,1,(immediate_gets+immediate_misses)),2) taxa_immediate
   FROM v$latch l, v$latchname ln
   WHERE ln.name in ('redo allocation', 'redo copy')
  and ln.latch# = l.latch#;  