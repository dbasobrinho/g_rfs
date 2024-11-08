alter session set nls_date_format='dd/mm/yyyy';
alter session set nls_timestamp_format='dd/mm/yyyy';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | LIST ALL SQLS THAT HAVE PINNED PLANES                                  |
PROMPT +------------------------------------------------------------------------+
PROMPT
set pages 1000 lines 500
col sql_profile_name    for  a40
col sql_id              for  a15
col date_created        for  a12
col date_modified       for  a12


select distinct  p.name sql_profile_name, s.sql_id, trunc(created) date_created, trunc(last_modified)  date_modified
 from  dba_sql_profiles p,
       DBA_HIST_SQLSTAT s
where p.name=s.sql_profile
order by date_created
/

alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';


