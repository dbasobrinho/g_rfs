alter session set NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set lines 1000
select log_owner, master, log_table from dba_mview_logs
/
