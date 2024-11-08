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


COL SAMPLESTART FORMAT A30       HEAD 'BEGIN TIME'         JUSTIFY CENTER
COL TC FORMAT A50                HEAD 'TIME|COMP'          JUSTIFY CENTER
COL DBTW FORMAT 999.99           HEAD 'DB TIME|METRIC'     JUSTIFY CENTER
COL SMPCNT FORMAT 999.99         HEAD 'DB TIME'            JUSTIFY CENTER
COL EPCT FORMAT 999.99           HEAD '% PER SAMPLE'       JUSTIFY CENTER
col dbt_w format 99999.99        head 'DB Time|Per Metric' JUSTIFY CENTER
col aas_w format 99999.99        head 'AAS|Per Metric'     JUSTIFY CENTER
col dbt_a format 99999.99        head 'DB Time'            JUSTIFY CENTER
col aas_a format 99999.99        head 'AAS'                JUSTIFY CENTER

col bt NEW_VALUE _bt NOPRINT
col et NEW_VALUE _et NOPRINT
select min(cast(sample_time as date)) bt,
max(cast(sample_time as date)) et
from v$active_session_history
where to_date(to_char(sample_time,'DD-MON-RR HH24:MI:SS'),'DD-MON-RR HH24:MI:SS')
 between to_date('&&DATA_INI','DD/MM/YYYY HH24:MI:SS') and to_date('&&DATA_FIM','DD/MM/YYYY HH24:MI:SS')
/ 
break on samplestart;
rem #################################################################################
rem Name: dbt_ashall_byevt.sql
rem Purpose: Show DB Time and AAS at 1-second intervals from DBA_HIST_ACTIVE_SESS_HISTORY
rem Granluarity: By wait class or “CPU/CPU + CPU Wait”
rem #################################################################################
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : dbt_04_ashall_byevt.sql             +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT |04 - Mostrar DB Time e AAS em intervalos de 1 minuto de DBA_HIST_ACTIVE_SESS_HISTORY
PROMPT +------------------------------------------------------------------------+
PROMPT
WITH xtimes (xdate) AS
  (SELECT to_date(to_date('&&DATA_INI','DD/MM/YYYY HH24:MI:SS')) xdate FROM dual
  UNION ALL
  SELECT xdate+(1/1440) FROM xtimes WHERE xdate+(1/1440) <= to_date('&&DATA_FIM','DD/MM/YYYY HH24:MI:SS')
  )
select to_char(xdate,'DD-MON-RR HH24:MI') samplestart,
nvl(evt,'*** IDLE *** ') tc,
sum(decode(evt,null,0,dbtw)) dbt_w,
sum(decode(evt,null,0,dbtw))/60 aas_w,
nvl(smpcnt,0) dbt_a,
nvl(smpcnt,0)/60 aas_a
from (
select s1.xdate,ash.sample_id,
evt,10*count(*) dbtw,ash.smpcnt
from (
select sample_id,sample_time,session_state,
decode(session_state,'ON CPU','CPU + CPU Wait',event) evt,
10*(count(sample_id) over (partition by to_date(to_char(sample_time,'DD-MON-RR HH24:MI'), 'DD-MON-RR HH24:MI:SS'))) smpcnt
from dba_hist_active_sess_history
where to_date(to_char(sample_time,'DD-MON-RR HH24:MI'),'DD-MON-RR HH24:MI')
 between to_date('&&DATA_INI','DD/MM/YYYY HH24:MI:SS') and to_date('&&DATA_FIM','DD/MM/YYYY HH24:MI:SS')
)  ash,
(select to_date(TO_CHAR(xdate,'DD-MON-RR HH24:MI'),'DD-MON-RR HH24:MI') xdate
from xtimes ) s1
where to_date(TO_CHAR(ash.sample_time(+),'DD-MON-RR HH24:MI'),'DD-MON-RR HH24:MI')=s1.xdate
group by s1.xdate,sample_id,evt,smpcnt
)
group by xdate,evt,smpcnt
order by 1,dbt_w desc
/
undefine etime
undefine btime
undefine bt
undefine et
