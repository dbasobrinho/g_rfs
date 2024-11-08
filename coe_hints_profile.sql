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

COL hint FOR A150
SELECT hint
 FROM (SELECT p.name,
 p.signature,
 p.category,
 row_number() over (partition by sd.signature, sd.category order by sd.signature)
row_num,
 extractValue(value(t), '/hint') hint
 FROM sys.sqlobj$data sd,
 dba_sql_profiles p,
 table(xmlsequence(extract(xmltype(sd.comp_data), '/outline_data/hint'))) t
WHERE sd.obj_type = 1
 AND p.signature = sd.signature
 AND p.name like nvl('&sql_profile_name',name))
ORDER by row_num
/
