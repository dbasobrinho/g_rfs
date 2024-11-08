-----------------------------------------------------------------------------
--
--
--  NAME
--    plan_stat.sql
--
--  DESCRIPTON
--    Lista o tempo médio de execução de cada plan_hash de um SQL_ID  
--
--  HISTORY
--    15/07/2013 => Valter Aquino
--
-----------------------------------------------------------------------------

set echo off 
SET VERIFY OFF
set serveroutput on size 20000
col PLAN_HASH_VALUE for 999999999999;
set linesize 200

ACCEPT sql_id PROMPT 'SQL_ID..: '

WITH
m AS (
SELECT plan_hash_value,
       SUM(elapsed_time)/SUM(executions) avg_et_secs
  FROM gv$sql
 WHERE sql_id = TRIM('&sql_id.')
   AND executions > 0
 GROUP BY
       plan_hash_value )
SELECT plan_hash_value,
       ROUND(NVL(m.avg_et_secs, 0.001)/1e6, 6) "avg_et_µs"
  FROM m
 ORDER BY "avg_et_µs" NULLS LAST;

SET VERIFY ON