alter session set NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set lines 1000
select OWNER, MVIEW_NAME,FAST_REFRESHABLE, LAST_REFRESH_TYPE, LAST_REFRESH_DATE, COMPILE_STATE
  from DBA_MVIEWS;
