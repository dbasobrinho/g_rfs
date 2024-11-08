set lines 1000
set pages 500 
PROMPT 
ACCEPT DATA_INI CHAR PROMPT 'Data Inicial (DD/MM/YYYY HH24:MI:SS) = '
ACCEPT DATA_FIM CHAR PROMPT 'Data Final   (DD/MM/YYYY HH24:MI:SS) = '
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Ver a quantidade + % de eventos que aconteceu em um determinado periodo|
PROMPT +------------------------------------------------------------------------+
PROMPT
set lines 1000
set pages 500
COLUMN sql_id           FORMAT A16
COLUMN event            FORMAT A60
COLUMN BLOCKING_SESSION FORMAT 99999999
COLUMN total            FORMAT 99999999
COLUMN percent          FORMAT A15

select sql_id
      ,substr(event,1,60)  event
	  ,BLOCKING_SESSION
      ,count(*) total  
      ,lpad(round(ratio_to_report(count(*)) over() * 100) || '%', 10, ' ') percent
  from dba_hist_active_sess_history
 where sample_time between
       to_date('&DATA_INI', 'dd/mm/yyyy hh24:mi:ss') and
       to_date('&DATA_FIM', 'dd/mm/yyyy hh24:mi:ss')
 group by sql_id ,substr(event,1,60), BLOCKING_SESSION
 order by percent desc
/
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Ver SQL_ID do bloqueador                                               |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT sid number PROMPT 'BLOCKING_SESSION = '
PROMPT
select sql_id
      ,event
      ,count(*)
      ,BLOCKING_SESSION
      ,lpad(round(ratio_to_report(count(*)) over() * 100) || '%', 10, ' ') percent
  from dba_hist_active_sess_history
 where sample_time between
       to_date('&&DATA_INI', 'dd/mm/yyyy hh24:mi:ss') and
       to_date('&&DATA_FIM', 'dd/mm/yyyy hh24:mi:ss') and 
       SESSION_ID = &sid
 group by sql_id
         ,event
         ,BLOCKING_SESSION
 order by percent desc
/ 
@coe_sql_history.sql
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Ver Planos Execucao e profile                                          |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT a1 char   PROMPT 'SQL_ID = '
ACCEPT a2 number PROMPT 'SQL_PLAN_HASH_VALUE ou NULL = '
PROMPT

select distinct p.name as sql_profile_name, s.sql_id 
  from dba_sql_profiles p
      ,DBA_HIST_SQLSTAT s
 where p.name = s.sql_profile and s.sql_id = '&a1'
 /
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_AWR('&a1', &a2)); 


 
 --   @dba_hist_sess_group_event_analise_coe.sql
 --   15/07/2017 02:20:00
 --   15/07/2017 02:51:36
