-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
--https://oracle-base.com/articles/10g/active-session-history

SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON VERIFY OFF feedback off
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss'; 

Def dt_ini='2020-12-18 18:45:00'
Def dt_fim='2020-12-18 19:00:00'

col session_state format a07
col event         format a30
col tot           format 99999999999999 HEADING 'WAIT_TIME'
col time_waited   format 99999999999999 
col percent       format a30            HEADING '%'
col min_date      format a25           
col max_date      format a25
col program       format a25
col sql_id        format a14
set feedback on

7y3gycum4pjtc

SELECT * FROM (
  SELECT  /*+ PARALLEL(a,15) */ 
        a.session_state
      , substr(a.event,1,30) as event
      , count(*)*10 as WAIT_TIME
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
      , MIN(a.sample_time) min_date
      , MAX(a.sample_time) max_date
    FROM
        dba_hist_active_sess_history a
    WHERE
        a.sample_time BETWEEN TIMESTAMP'&&dt_ini' AND TIMESTAMP'&&dt_fim'
    GROUP BY
        a.session_state
      , substr(a.event,1,30) 
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
/

SELECT * FROM (
  SELECT   /*+ PARALLEL(a,15) */
        substr(a.program,1,25) AS program
      , a.sql_id
      , a.session_state
      , a.event
      , count(*)*10 as WAIT_TIME
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
      , MIN(a.sample_time) min_date
      , MAX(a.sample_time) max_date
    FROM
        dba_hist_active_sess_history a
    WHERE
        a.sample_time BETWEEN TIMESTAMP'&&dt_ini' AND TIMESTAMP'&&dt_fim'
    GROUP BY
         substr(a.program,1,25)
      , a.sql_id
      , a.session_state
      , a.event
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
/

SELECT * FROM (
  SELECT  /*+ PARALLEL(a,15) */
         substr(a.program,1,25) program
      , a.sql_id
      , a.session_state
      , a.event
      , a.p1
      , a.p2
      --, count(*)*10 as WAIT_TIME
	  , sum(decode(session_state, 'ON CPU', wait_time,time_waited))/1000000 time_waited
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
      , MIN(a.sample_time) min_date
      , MAX(a.sample_time) max_date
    FROM
        dba_hist_active_sess_history a
    WHERE
        a.sample_time BETWEEN  TIMESTAMP'&&dt_ini' AND TIMESTAMP'&&dt_fim'
		and a.event like '%enq:%'
    GROUP BY
         substr(a.program,1,25)
      , a.sql_id
      , a.session_state
      , a.event
      , a.p1
      , a.p2
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 300
/


