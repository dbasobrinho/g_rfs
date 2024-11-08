SET TERMOUT OFF FEEDBACK OFF;
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
SET TERMOUT ON FEEDBACK ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Localiza Profile por SQL_ID e Remove Profile                           |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT sql_id9 char   PROMPT 'SQL ID = '
set pages 999 lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col NAME_PROFILE   for a30
col created        for a19
col last_modified  for a19
col LAST_LOAD_TIME for a19
col descr          for a30
col hash_value     for a20
col address        for a20

--break on plan_hash_value on startup_time skip 1
SELECT name NAME_PROFILE, to_char(created, 'dd/mm/yyyy hh24:mi:ss') created, to_char(last_modified, 'dd/mm/yyyy hh24:mi:ss') last_modified, substr(DESCRIPTION,1,30) descr
  FROM dba_sql_profiles
 WHERE name IN
       (SELECT sql_profile FROM gv$sql WHERE sql_id = trim('&sql_id9'))
/  
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | REMOVER PROFILE DO SQLID                                               |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT name_sql_profile char   PROMPT 'NAME_PROFILE = '
exec dbms_sqltune.drop_sql_profile('&name_sql_profile');
select address,  to_char(hash_value) hash_value, to_char(LAST_LOAD_TIME, 'dd/mm/yyyy hh24:mi:ss') LAST_LOAD_TIME from v$sqlarea where sql_id like '&&sql_id9';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | REMOVER SQLID DA SHARED_POOL                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT address    char   PROMPT 'ADDRESS    = '
ACCEPT hash_value char   PROMPT 'HASH_VALUE = '
exec dbms_shared_pool.purge('&address, &hash_value','C');
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | VALIDA SE REMOVEU SQLID DA SHARED_POOL                                 |
PROMPT +------------------------------------------------------------------------+
PROMPT
select address, to_char(hash_value) hash_value, to_char(LAST_LOAD_TIME, 'dd/mm/yyyy hh24:mi:ss') LAST_LOAD_TIME from v$sqlarea where sql_id like '&&sql_id9';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | E ZAS                                                                  |
PROMPT +------------------------------------------------------------------------+
PROMPT