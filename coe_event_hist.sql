@save_sqlplus_settings

set lines  200



-- this scripts uses "ASH math" by Graham Wood, Uri Shaft and John Beresniewicz
-- for estimating the event counts (and average durations):
--   http://www.aioug.org/sangam12/Presentations/20130.pdf (ASH Architecture and Advanced Usage)

			
COL evh_event HEAD WAIT_EVENT for A58 TRUNCATE
COL evh_graph HEAD "Estimated|Time Graph" JUST CENTER FOR A12
COL pct_evt_time HEAD "% Event|Time" format 990D9
COL evh_est_total_sec HEAD "Estimated|Total Sec" FOR 999G999D9
COL evh_millisec HEAD "Wait time|bucket ms+" FOR A15 JUST RIGHT
COL evh_event HEAD "Wait Event" format a50
COL evh_sample_count HEAD "Num ASH|Samples"
COL evh_est_event_count HEAD "Estimated|Total Waits" format 999G999G999
COL first_seen FOR A25
COL last_seen FOR A25


BREAK ON evh_event SKIP 1

SELECT
    e.*
  , ROUND ( 100 * RATIO_TO_REPORT(evh_est_total_sec) OVER (PARTITION BY evh_event) , 1 ) pct_evt_time
  , '|'||RPAD(NVL(RPAD('#', ROUND (10 * RATIO_TO_REPORT(evh_est_total_sec) OVER (PARTITION BY evh_event)), '#'),' '), 10)||'|' evh_graph
FROM (
    SELECT 
        event evh_event
      , LPAD('< ' || CASE WHEN time_waited = 0 THEN 0 ELSE CEIL(POWER(2,CEIL(LOG(2,time_waited/1000)))) END, 15) evh_millisec
      , COUNT(*)  evh_sample_count
      , ROUND(SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END),1) evh_est_event_count
      , ROUND(CASE WHEN time_waited = 0 THEN 0 ELSE CEIL(POWER(2,CEIL(LOG(2,time_waited/1000)))) END * SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END) / 1000,1) evh_est_total_sec
    FROM 
        V$ACTIVE_SESSION_HISTORY 
        --dba_hist_active_sess_history
    WHERE 
        event like '&1'
    AND &2
    AND sample_time BETWEEN &3 AND &4
    AND session_state = 'WAITING' -- not really needed as "event" for ON CPU will be NULL in ASH, but added just for clarity
    AND time_waited > 0 
    GROUP BY 
        event
      , CASE WHEN time_waited = 0 THEN 0 ELSE CEIL(POWER(2,CEIL(LOG(2,time_waited/1000)))) END -- evh_millisec
) e
ORDER BY
    evh_event
  , evh_millisec
/

@restore_sqlplus_settings

