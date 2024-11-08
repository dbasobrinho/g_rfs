-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/temp_usage.sql
-- Author       : Tim Hall
-- Description  : Displays temp usage for all session currently using temp space.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @temp_usage_user_sid.sql
-- Last Modified: 12/02/2004
-- -----------------------------------------------------------------------------------


COLUMN temp_used FORMAT 9999999999
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a17  HEADING 'SLAVE/W_CLASS'
col opid         format a04 
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a20
col client_info  format a23
col machine      format a30
col logon_time   format a10
col hold         format a06
col sessionwait  format a25
col status       format a08
col hash_value   format a10
col sc_wait      format a06 HEADING 'WAIT'
col sql_text     format a120

ALTER SESSION SET NLS_DATE_FORMAT                 = 'DD/MM/YYYY';

select t.sample_time, t.sql_id, t.temp_mb, t.temp_diff
       ,substr(s.sql_text,1,120)  sql_text
  from (
        select --session_id,session_serial#,
               --'alter system kill session ''' || session_id || ',' || session_serial# || ''' immediate;' kill_session_cmd,
               trunc(sample_time) sample_time,sql_id, sum(temp_mb) temp_mb, sum(temp_diff) temp_diff
               , row_number() over (partition by trunc(sample_time) order by sum(temp_mb) desc nulls last) as rn
          from (
                select sample_time,session_id,session_serial#,sql_id,temp_space_allocated/1024/1024 temp_mb, 
                       temp_space_allocated/1024/1024-lag(temp_space_allocated/1024/1024,1,0) over (order by sample_time) as temp_diff
                 --from dba_hist_active_sess_history 
                 from v$active_session_history
                where 1 = 1 
                -- session_id=1 
                -- and session_serial#=2
               )
         group by --session_id,session_serial#,
                  trunc(sample_time),
                  sql_id
       ) t
  left join v$sqlarea s
    on s.sql_id = t.sql_id
 where 1 = 1
   and rn <=5
   and sample_time >= trunc(sysdate) - &dias_menos_sysdate                
 order by sample_time desc, temp_mb desc
/ 
ALTER SESSION SET NLS_DATE_FORMAT                 = 'DD/MM/YYYY HH24:MI:SS';
