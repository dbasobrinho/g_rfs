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

set echo on feedback on timing on pagesize 100 linesize 200 trimout
on trimspool on tab off
col sample_time format a26
col day format a12
col min_sample_time format a5
col max_sample_time format a5
col inst# format 9990
col sid format a10
col state format a10
col blksid format a10
col blkstate format a10
col time_waited format 999,999,990
col event format a30
col plsql_entry_object_id format 999990
col plsql_entry_subprogram_id format 999990
col plsql_object_id format 999990
col plsql_subprogram_id format 999990
col program format a30
col module format a25
col action format a40
col entry_owner format a6 heading "Entry|Owner"
col entry_name format a40 heading "Entry|Package.procedure"
col owner format a6 heading "Owner"
col name format a40 heading "Package.procedure"
col cnt format 999,990
col duration format a20

clear breaks computes
select  /*+ PARALLEL(a,15) */     sql_id,
           count(*) cnt,
           count(*)*10 time_waited
from      dba_hist_active_sess_history a
where       sample_time BETWEEN  TIMESTAMP'&&dt_ini' AND TIMESTAMP'&&dt_fim'
and sql_id is not null
group by  sql_id
having count(*)> 5
order by  time_waited desc
/

select    /*+ PARALLEL(e,15)  PARALLEL(p,15)*/
    e.object_name || decode(e.object_name,'','','.') ||
    e.procedure_name entry_name,
    p.object_name || decode(p.object_name,'','','.') ||
    p.procedure_name name,
    x.sql_id,
    --x.sql_plan_hash_value,
    substr(x.module,1,20)  module,
    x.event,
    x.time_waited,
    x.cnt
    from      dba_procedures    e,
               dba_procedures    p,
               (select  /*+ PARALLEL(a,15) */   plsql_entry_object_id,
                          plsql_entry_subprogram_id,
                          plsql_object_id,
                          plsql_subprogram_id,
                          module,
                          sql_id,
                          sql_plan_hash_value,
                          event,
                          --sum(decode(session_state, 'ON CPU', wait_time,time_waited))/1000000 time_waited,
						   count(*)*10 time_waited,
                          count(*) cnt
                from      dba_hist_active_sess_history a
    where    sample_time BETWEEN  TIMESTAMP'&&dt_ini' AND TIMESTAMP'&&dt_fim'
                group by  plsql_entry_object_id,
                          plsql_entry_subprogram_id,
                          plsql_object_id,
                          plsql_subprogram_id,
                          module,
                          sql_id,
                          sql_plan_hash_value,
                          event) x
    where     e.object_id (+) = x.plsql_entry_object_id
    and       e.subprogram_id (+) = x.plsql_entry_subprogram_id
    and       p.object_id (+) = x.plsql_object_id
    and       p.subprogram_id (+) = x.plsql_subprogram_id
	and x.cnt > 10
    order by  7 desc, 1, 2, 3, 4
/	

select   /*+ PARALLEL(a,15) */ sample_time,
           session_id||'.'||session_serial# sid,
           session_state state,
           decode(session_state, 'ON CPU', wait_time, time_waited) time_waited,
           blocking_session||'.'||blocking_session_serial# blksid,
           blocking_session_status blkstate,
           user_id,
           sql_id,
           module,
           event,
           p1, p2, p3,
           action
from      dba_hist_active_sess_history a
where    sample_time BETWEEN  TIMESTAMP'&&dt_ini' AND TIMESTAMP'&&dt_fim'
order by  sample_time
/


