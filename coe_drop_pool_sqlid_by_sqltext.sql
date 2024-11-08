alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | REMOVE SQLID SHARED POOL BY SQLTEXT                                    |
PROMPT +------------------------------------------------------------------------+
PROMPT
set echo OFF
SET VERIFY OFF 
set pages 999 lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio        for 999,999,999.9
col sql_text       for a100
col com        for a100
col last_modified  for a19
col LAST_LOAD_TIME for a19
col descr          for a30
col hash_value     for a20
col address        for a20
PROMPT
ACCEPT texto_sql    char   PROMPT 'TEXTO_SQL    = '

select z.* from(
 SELECT 
         SQL_ID, INST_ID, substr(sql_text,1,100) as sql_text
 FROM   Gv$sql
 WHERE  INSTR(upper(sql_text), upper('&&texto_sql')) > 0
 AND    INSTR(upper(sql_text), upper('EXPLAIN PLAN')) = 0
 AND    INSTR(upper(sql_text), upper('/* SQL ANALYZE(')) = 0) Z ORDER BY 1,2
/
select 'exec dbms_shared_pool.purge('''||address||','|| hash_value||''','||'''C'');' com,
--address,  to_char(hash_value) hash_value,
to_char(LAST_LOAD_TIME, 'dd/mm/yyyy hh24:mi:ss') LAST_LOAD_TIME from v$sqlarea 
where sql_id in(
SELECT DISTINCT Z.SQL_ID FROM
(
 SELECT 
         SQL_ID, substr(sql_text,1,40) as sql_text
 FROM   v$sql
 WHERE  INSTR(upper(sql_text), upper('&&texto_sql')) > 0
 AND    INSTR(upper(sql_text), upper('EXPLAIN PLAN')) = 0
 AND    INSTR(upper(sql_text), upper('/* SQL ANALYZE(')) = 0) Z)
/

set echo off
UNDEFINE texto_sql
PROMPT
PROMPT
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 
