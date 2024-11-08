alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Historico de planos de execucao de um SQL_ID                           |
PROMPT +------------------------------------------------------------------------+
PROMPT
PROMPT
COL sql_id               FOR A16;
COL SQL_PLAN_HASH_VALUE  FOR 9999999999;
COL starting_time        FOR A21;
COL end_time             FOR A21;
COL user_id              FOR A21;


SELECT distinct a.sql_id,
                a.blocking_session,
                a.blocking_session_serial#,
                a.user_id,
               -- s.sql_text,
                a.module
  FROM V$ACTIVE_SESSION_HISTORY a, v$sql s
 where a.sql_id = s.sql_id
   and blocking_session is not null
   and a.user_id <> 0
   and a.sample_time between
       to_date('22/02/2023 01:10', 'dd/mm/yyyy hh24:mi') and
       to_date('22/02/2023 01:16', 'dd/mm/yyyy hh24:mi')
/	   