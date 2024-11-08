set heading off
set feedback off
select '********************' from dual;
select 'Data Guard STATS' from dual;
select '********************' from dual;
set heading on
set feedback on
set pages 200
set lines 200
column name format a18
column lag_time format a15
column datum_time format a28
column TIME_COMP  format a28
column UNIQUE_NAME  format a11
column NAME         format a25
SELECT SOURCE_DBID           DBID  
     , SOURCE_DB_UNIQUE_NAME UNIQUE_NAME
	 , NAME                  NAME
	 , VALUE 				 LAG_TIME
	 , DATUM_TIME 			 DATUM_TIME
	 , TIME_COMPUTED         TIME_COMP
	 , UNIT                  UNIT
from V$DATAGUARD_STATS
/
---dg_dataguard_stats