SET TERMOUT OFF FEEDBACK OFF;
SET LONG 10000;
SET PAGESIZE 9999
SET LINESIZE 155
set verify off
set feedback off
set echo off
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
SET TERMOUT ON FEEDBACK ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | HINT da Profile                                                        |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT v_profile_name char   PROMPT 'PROFILE NAME = '
PROMPT
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

set lines 200
col hint for a160

SELECT hint 
  FROM (SELECT p.name, 
               p.signature, 
               p.category,
               row_number() over (partition by sd.signature, sd.category order by sd.signature) row_num,
               extractValue(value(t), '/hint') hint
          FROM sys.sqlobj$data sd, 
               dba_sql_profiles p,
               table(xmlsequence(extract(xmltype(sd.comp_data),'/outline_data/hint'))) t
         WHERE sd.obj_type = 1
           AND p.signature = sd.signature
           AND upper(p.name) LIKE UPPER('&&v_profile_name%'))
 order by row_num;
/

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | E ZAS                                                                  |
PROMPT +------------------------------------------------------------------------+
PROMPT
set feedback off
UNDEFINE v_profile_name