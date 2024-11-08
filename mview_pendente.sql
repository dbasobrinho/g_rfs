
select *  from (select* from dba_mviews where owner not in ('SYS','SYSMAN','SYSTEM','DBSNMP') and
((last_refresh_date <= (sysdate - (2/400)) and REFRESH_METHOD='FAST') or (last_refresh_date <= (sysdate - (2/24)) and REFRESH_METHOD='FORCE')))
where MVIEW_NAME not in ('MVIEW_C01VW1535','MVIEW_FL_DRIVER_VEHICLE_GROUP','AU_OPEN_TRANSACTION_TED') ;
