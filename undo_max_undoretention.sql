-- -----------------------------------------------------------------------------------
set pages 1000
set lines 1000

-- Historico tuned_retention
-- Max undoretention baseado no Historico em v$undostat
select max(tuned_undoretention) from v$undostat order by tuned_undoretention ;