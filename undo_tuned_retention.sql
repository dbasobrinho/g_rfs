-- -----------------------------------------------------------------------------------
set pages 1000
set lines 1000

-- Historico tuned_retention
alter session set nls_date_format='dd-mm-yyyy hh24:mi:ss';
select BEGIN_TIME , END_TIME , tuned_undoretention from v$undostat order by tuned_undoretention , BEGIN_TIME , END_TIME
/