set lines 1000 
set pages 500  
PROMPT 
ACCEPT DATA_INI CHAR PROMPT 'Data Inicial (DD/MM/YYYY HH24:MI:SS) = '
ACCEPT DATA_FIM CHAR PROMPT 'Data Final   (DD/MM/YYYY HH24:MI:SS) = '
ACCEPT q        CHAR PROMPT 'SQL ID = '
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Localizar execucao query por um periodo de tempo                       |
PROMPT +------------------------------------------------------------------------+
PROMPT
COLUMN sql_id           FORMAT A13
COLUMN event            FORMAT A23
COLUMN BLOCKING_SESSION FORMAT 999999
COLUMN SID              FORMAT 99999
COLUMN SERIAL           FORMAT 999999
COLUMN SAMPLE_TIME      FORMAT A20
COLUMN USERNAME         FORMAT A15
COLUMN PROGRAM          FORMAT A16
COLUMN MODULE           FORMAT A20
COLUMN MACHINE          FORMAT A20
select SESSION_ID as SID
      ,SESSION_SERIAL#  as SERIAL
      ,sql_id
      ,substr(event,1,23)  event
	  ,BLOCKING_SESSION
      ,to_char(SAMPLE_TIME,'dd/mm/yyyy hh24:mi:ss') SAMPLE_TIME
	  ,substr((select x.username from dba_users x where x.user_id =  a.USER_ID),1,15) as USERNAME
	  ,substr(PROGRAM,1,16)  as PROGRAM
	  ,substr(MODULE ,1,20)  as MODULE
	  ,substr(MACHINE,1,20)  as MACHINE
  from dba_hist_active_sess_history a
 where sample_time between
       to_date('&DATA_INI', 'dd/mm/yyyy hh24:mi:ss') and
       to_date('&DATA_FIM', 'dd/mm/yyyy hh24:mi:ss') and SQL_ID = '&q'
order by SAMPLE_TIME asc 
/