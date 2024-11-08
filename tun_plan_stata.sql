-----------------------------------------------------------------------------
--
--
--  NAME
--    plan_stata.sql
--
--  DESCRIPTON
--    Lista o tempo médio de execução de cada plan_hash de um SQL_ID
--
--  ATTENTION 
--    A execução deste script requer licença da OPTION DIAGNOSTIC & TUNING PACK
--
--  HISTORY
--    21/08/2016 => Valter Aquino
--
-----------------------------------------------------------------------------

set echo off 
SET VERIFY OFF
set serveroutput on size 20000
col PLAN_HASH_VALUE for 999999999999;
set linesize 200

ACCEPT sql_id PROMPT 'SQL_ID..: '

WITH
p AS (
SELECT plan_hash_value
  FROM gv$sql_plan
 WHERE sql_id = TRIM('&sql_id.')
   AND other_xml IS NOT NULL
 UNION
SELECT plan_hash_value
  FROM dba_hist_sql_plan
 WHERE sql_id = TRIM('&sql_id.')
   AND other_xml IS NOT NULL ),
m AS (
SELECT plan_hash_value,
       SUM(elapsed_time)/SUM(executions) avg_et_secs
  FROM gv$sql
 WHERE sql_id = TRIM('&sql_id.')
   AND executions > 0
 GROUP BY
       plan_hash_value ),
a AS (
SELECT plan_hash_value,
       SUM(elapsed_time_total)/SUM(executions_total) avg_et_secs
  FROM dba_hist_sqlstat
 WHERE sql_id = TRIM('&sql_id.')
   AND executions_total > 0
 GROUP BY
       plan_hash_value )
SELECT p.plan_hash_value,
       ROUND(NVL(m.avg_et_secs, a.avg_et_secs)/1e6, 6) "avg_et_µs"
  FROM p, m, a
 WHERE p.plan_hash_value = m.plan_hash_value(+)
   AND p.plan_hash_value = a.plan_hash_value(+)
 ORDER BY
       "avg_et_µs" NULLS LAST;

SET VERIFY ON