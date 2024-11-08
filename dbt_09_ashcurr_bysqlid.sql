SET FEEDBACK   off
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
ACCEPT DATA_INI CHAR DEFAULT '18/02/2021 19:30:00' PROMPT 'Data Inicial (DD/MM/YYYY HH24:MI:SS) = '
ACCEPT DATA_FIM CHAR DEFAULT '18/02/2021 20:30:00' PROMPT 'Data Final   (DD/MM/YYYY HH24:MI:SS) = '
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       10000
SET PAGES       10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;


COL SAMPLESTART FORMAT A19       HEAD 'BEGIN TIME'         JUSTIFY CENTER
COL SAMPLESEND  FORMAT A19       HEAD 'END TIME'           JUSTIFY CENTER
COL TC FORMAT A50                HEAD 'TIME|COMP'          JUSTIFY CENTER
COL DBTW FORMAT 999.99           HEAD 'DB TIME|METRIC'     JUSTIFY CENTER
COL SMPCNT FORMAT 999.99         HEAD 'DB TIME'            JUSTIFY CENTER
COL EPCT FORMAT 999.99           HEAD '% PER SAMPLE'       JUSTIFY CENTER
COL DBT_W FORMAT 99999.99        HEAD 'DB TIME|PER METRIC' JUSTIFY CENTER
COL AAS_W FORMAT 99999.99        HEAD 'AAS|PER METRIC'     JUSTIFY CENTER
COL DBT_A FORMAT 99999.99        HEAD 'DB TIME'            JUSTIFY CENTER
COL AAS_A FORMAT 99999.99        HEAD 'AAS'                JUSTIFY CENTER
COL SMPCNT FORMAT 999.99         HEAD 'DB TIME|TOTAL'      JUSTIFY CENTER
COL AAS FORMAT 999.99            HEAD 'AAS|TOTAL'          JUSTIFY CENTER
COL AAS_COMP FORMAT 999.99       HEAD 'AAS PER|METRIC'     JUSTIFY CENTER
col sql_id format a15            head 'SQL_ID'             JUSTIFY CENTER



col bt NEW_VALUE _bt NOPRINT
col et NEW_VALUE _et NOPRINT
select min(cast(sample_time as date)) bt,
max(cast(sample_time as date)) et
from v$active_session_history
where to_date(to_char(sample_time,'DD-MON-RR HH24:MI:SS'),'DD-MON-RR HH24:MI:SS')
 between to_date('&&DATA_INI','DD/MM/YYYY HH24:MI:SS') and to_date('&&DATA_FIM','DD/MM/YYYY HH24:MI:SS')
/ 
rem #################################################################################
rem Name: dbt_ashcurr_sqlid.sql
rem Purpose: Show DB Time and AAS at 1-second intervals from V$ACTIVE_SESSION_HISTORY
rem Granluarity: By SQL_ID
rem #################################################################################
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : dbt_09_ashcurr_bysqlid.sql          +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT |09 - Show DB Time and AAS at 1-second intervals from V$ACTIVE_SESSION_HISTORY
PROMPT +------------------------------------------------------------------------+
PROMPT
break on samplestart on sql_id;
WITH xtimes (xdate) AS
  (SELECT to_date(to_date('&&DATA_INI','DD/MM/YYYY HH24:MI:SS')) xdate FROM dual
  UNION ALL
  SELECT xdate+(1/86400) FROM xtimes WHERE xdate+(1/86400) <= to_date('&&DATA_FIM','DD/MM/YYYY HH24:MI:SS')
  )
select to_char(xdate,'DD-MON-RR HH24:MI:SS') samplestart,
sql_id,
nvl(evt,'*** IDLE *** ') tc,
decode(evt,null,0,dbtw) dbtw,
nvl(smpcnt,0) smpcnt,
round(100*(dbtw/smpcnt),2) epct
from (
select s1.xdate,ash.sample_id,ash.sample_time,sql_id,evt,count(*) dbtw,ash.smpcnt
from (
select sample_id,sample_time,session_state,sql_id,
decode(session_state,'ON CPU','CPU + CPU Wait',event) evt,
count(sample_id) over (partition by sample_id) smpcnt
from v$active_session_history
where to_date(to_char(sample_time,'DD-MON-RR HH24:MI:SS'),'DD-MON-RR HH24:MI:SS')
 between to_date('&&DATA_INI','DD/MM/YYYY HH24:MI:SS') and to_date('&&DATA_FIM','DD/MM/YYYY HH24:MI:SS')
)  ash,
(select xdate
from xtimes ) s1
where to_date(TO_CHAR(ash.sample_time(+),'DD-MON-RR HH24:MI:SS'),'DD-MON-RR HH24:MI:SS')=s1.xdate
group by s1.xdate,sample_id,evt,sql_id,smpcnt,sample_time)
order by 1,dbtw desc
/
undefine btime
undefine etime
undefine bt
undefine et
undefine btime
undefine etime
undefine bt
undefine et
undefine interval_secs
