SET FEEDBACK   off
SET TIMING      OFF
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
-----ACCEPT DATA_INI CHAR DEFAULT '18/02/2021 19:30:00' PROMPT 'Data Inicial (DD/MM/YYYY HH24:MI:SS) = '
-----ACCEPT DATA_FIM CHAR DEFAULT '18/02/2021 20:30:00' PROMPT 'Data Final   (DD/MM/YYYY HH24:MI:SS) = '
SET ECHO        OFF
SET HEADING     ON
SET LINES       600
SET PAGES       600
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
DEF days_of_history_accessed       = '31';
DEF captured_at_least_x_times      = '10'; 
DEF captured_at_least_x_days_apart = '10';
DEF med_elap_microsecs_threshold   = '1e4';
DEF min_slope_threshold            = '0.1'; 
DEF max_num_rows                   = '100';

SET LIN 500 VER OFF;
COL ROW_N FOR A5 HEA '#SEQ#|'                                 JUSTIFY CENTER;
COL SQL_ID FOR A15 HEA 'SQL_ID|'                         JUSTIFY CENTER;
COL CHANGE FOR A20 HEA 'STATUS|'                         JUSTIFY CENTER;
COL SLOPE  FOR A20 HEA 'DESEMPENHO'                      JUSTIFY CENTER;
COL MED_SECS_PER_EXEC HEA 'MEDIAN SECS|PER EXEC'         JUSTIFY CENTER;
COL STD_SECS_PER_EXEC HEA 'STD DEV SECS|PER EXEC'        JUSTIFY CENTER;
COL AVG_SECS_PER_EXEC HEA 'AVG SECS|PER EXEC'            JUSTIFY CENTER;
COL MIN_SECS_PER_EXEC HEA 'MIN SECS|PER EXEC'            JUSTIFY CENTER;
COL MAX_SECS_PER_EXEC HEA 'MAX SECS|PER EXEC'            JUSTIFY CENTER;
COL plans FOR 9999    HEA 'PLANS|'                       JUSTIFY CENTER;
COL sql_text_80 FOR A50                                  JUSTIFY CENTER;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : TROCAS DE PLANOS X IMPACTO (30DIAS) +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT | SQL_IDS QUE MAIS TIVERAM MODIFICAÇÃO DE RESPOSTA                     |
PROMPT | O GUINA NAO TINHA DÓ, SE REGIR BUMMM! VIRA PÓ!!!!!!!!!!!             |
PROMPT +------------------------------------------------------------------------+
WITH
per_time AS (
SELECT h.dbid,
       h.sql_id,
       SYSDATE - CAST(s.end_interval_time AS DATE) days_ago,
       SUM(h.elapsed_time_total) / SUM(h.executions_total) time_per_exec
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
WHERE h.executions_total > 0
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.end_interval_time AS DATE) > SYSDATE - &&days_of_history_accessed.
GROUP BY
       h.dbid,
       h.sql_id,
       SYSDATE - CAST(s.end_interval_time AS DATE)
),
avg_time AS (
SELECT dbid,
       sql_id,
       MEDIAN(time_per_exec) med_time_per_exec,
       STDDEV(time_per_exec) std_time_per_exec,
       AVG(time_per_exec)    avg_time_per_exec,
       MIN(time_per_exec)    min_time_per_exec,
       MAX(time_per_exec)    max_time_per_exec      
  FROM per_time
GROUP BY
       dbid,
       sql_id
HAVING COUNT(*) >= &&captured_at_least_x_times.
   AND MAX(days_ago) - MIN(days_ago) >= &&captured_at_least_x_days_apart.
   AND MEDIAN(time_per_exec) > &&med_elap_microsecs_threshold.
),
time_over_median AS (
SELECT h.dbid,
       h.sql_id,
       h.days_ago,
       (h.time_per_exec / a.med_time_per_exec) time_per_exec_over_med,
       a.med_time_per_exec,
       a.std_time_per_exec,
       a.avg_time_per_exec,
       a.min_time_per_exec,
       a.max_time_per_exec
  FROM per_time h, avg_time a
WHERE a.sql_id = h.sql_id
),
ranked AS (
SELECT RANK () OVER (ORDER BY ABS(REGR_SLOPE(t.time_per_exec_over_med, t.days_ago)) DESC) rank_num,
       t.dbid,
       t.sql_id,
       CASE WHEN REGR_SLOPE(t.time_per_exec_over_med, t.days_ago) > 0 THEN 'MELHOROU' ELSE 'PIOROU' END change,
       ROUND(REGR_SLOPE(t.time_per_exec_over_med, t.days_ago), 3) slope,
       ROUND(AVG(t.med_time_per_exec)/1e6, 3) med_secs_per_exec,
       ROUND(AVG(t.std_time_per_exec)/1e6, 3) std_secs_per_exec,
       ROUND(AVG(t.avg_time_per_exec)/1e6, 3) avg_secs_per_exec,
       ROUND(MIN(t.min_time_per_exec)/1e6, 3) min_secs_per_exec,
       ROUND(MAX(t.max_time_per_exec)/1e6, 3) max_secs_per_exec
  FROM time_over_median t
GROUP BY
       t.dbid,
       t.sql_id
HAVING ABS(REGR_SLOPE(t.time_per_exec_over_med, t.days_ago)) > &&min_slope_threshold.
),
TUDON AS (
SELECT LPAD(ROWNUM, 2) row_n,
       r.sql_id,
       r.change,
       TO_CHAR(r.slope, '990.000MI') slope,
       TO_CHAR(r.med_secs_per_exec, '999,990.000') med_secs_per_exec,
       TO_CHAR(r.std_secs_per_exec, '999,990.000') std_secs_per_exec,
       TO_CHAR(r.avg_secs_per_exec, '999,990.000') avg_secs_per_exec,
       TO_CHAR(r.min_secs_per_exec, '999,990.000') min_secs_per_exec,
       TO_CHAR(r.max_secs_per_exec, '999,990.000') max_secs_per_exec,
       (SELECT COUNT(DISTINCT p.plan_hash_value) FROM dba_hist_sql_plan p WHERE p.dbid = r.dbid AND p.sql_id = r.sql_id) plans
      -- ,trim(REPLACE((SELECT DBMS_LOB.SUBSTR(s.sql_text, 50) FROM dba_hist_sqltext s WHERE s.dbid = r.dbid AND s.sql_id = r.sql_id), CHR(10))) sql_text_80
  FROM ranked r
WHERE r.rank_num <= &&max_num_rows
ORDER BY
       r.change desc,r.rank_num)
                   SELECT  * FROM TUDON where PLANS> 1  --and change='PIOROU' 
/
PROMPT
PROMPT