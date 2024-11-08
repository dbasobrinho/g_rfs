alter session set NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set lines 1000
Select * from DBA_MVIEW_REFRESH_TIMES order by LAST_REFRESH desc;

