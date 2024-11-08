alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Localiza Profile por SQL_ID                                            |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT sql_id9 char   PROMPT 'SQL ID = '
set pages 999 lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
--break on plan_hash_value on startup_time skip 1
SELECT name, created, last_modified
  FROM dba_sql_profiles
 WHERE name IN
       (SELECT sql_profile FROM gv$sql WHERE sql_id = trim('&sql_id9'))
/       
