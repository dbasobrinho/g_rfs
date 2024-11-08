alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | REMOVE SQLID SHARED POOL                                               |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT sql_id9 char   PROMPT 'SQL ID = '
set pages 999 lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio        for 999,999,999.9
col NAME_PROFILE   for a30
col created        for a19
col last_modified  for a19
col LAST_LOAD_TIME for a19
col descr          for a30
col hash_value     for a20
col address        for a20

select address,  to_char(hash_value) hash_value, to_char(LAST_LOAD_TIME, 'dd/mm/yyyy hh24:mi:ss') LAST_LOAD_TIME from v$sqlarea where sql_id like '&&sql_id9';
PROMPT
PROMPT
ACCEPT address    char   PROMPT 'ADDRESS    = '
ACCEPT hash_value char   PROMPT 'HASH_VALUE = '
set echo on
exec dbms_shared_pool.purge('&address, &hash_value','C');
set echo off
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | VALIDA SE REMOVEU SQLID DA SHARED_POOL                                 |
PROMPT +------------------------------------------------------------------------+
PROMPT
select address, to_char(hash_value) hash_value, to_char(LAST_LOAD_TIME, 'dd/mm/yyyy hh24:mi:ss') LAST_LOAD_TIME from v$sqlarea where sql_id like '&&sql_id9';
PROMPT
PROMPT
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 
