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
rem Name: dbt_ashpast_bysqlid.sql
rem Purpose: Show DB Time and AAS at X-min intervals from dba_hist_active_sess_history
rem Granluarity: By SQL_ID + wait event or “CPU/CPU + CPU Wait”
rem Notes: At X-min intervals, where X = Entered time in minutes
rem #################################################################################
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : dbt_12_ashpast_bysqlid.sql          +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT |11 -  Show DB Time and AAS at X-second intervals from dba_hist_active_sess_history
PROMPT +------------------------------------------------------------------------+
PROMPT
break on samplestart on sampleend on smpcnt on aas
WITH xtimes (xdate) AS
  (SELECT to_date(to_date('&&DATA_INI','DD/MM/YYYY HH24:MI:SS')) xdate FROM dual
  UNION ALL
  SELECT xdate+(&&interval_mins/1440) FROM xtimes WHERE xdate+(&&interval_mins/1440) <= to_date('&&DATA_FIM','DD/MM/YYYY HH24:MI:SS')
  )
select to_char(xdate,'DD-MON-RR HH24:MI:SS') samplestart,
        to_char(xdate+&&interval_mins/1440,'DD-MON-RR HH24:MI:SS') sampleend,
        sql_id,
       (sum(decode(event,null,0,dbtw)) over (partition by to_char(xdate,'DD-MON-RR HH24:MI:SS'))) smpcnt,
       (sum(decode(event,null,0,dbtw)) over (partition by to_char(xdate,'DD-MON-RR HH24:MI:SS')))/60/&&interval_mins aas,
       nvl(event,'*** IDLE *** ') tc,
       decode(event,null,0,dbtw) dbtw,
       decode(event,null,0,dbtw)/60/&&interval_mins aas_comp
from (
        select s1.xdate,event,10*count(*) dbtw,sql_id,count(ash.smpcnt) smpcnt
          from (
                select  sample_id,
                        sample_time,
                        session_state,sql_id,
                        decode(session_state,'ON CPU','CPU + CPU Wait',event) event,
                        10*(count(sample_id) over (partition by sample_id)) smpcnt
                from dba_hist_active_sess_history
                where to_date(to_char(sample_time,'DD-MON-RR HH24:MI:SS'),'DD-MON-RR HH24:MI:SS')
                        between to_date('&&DATA_INI','DD/MM/YYYY HH24:MI:SS') and to_date('&&DATA_FIM','DD/MM/YYYY HH24:MI:SS')
                )  ash,
                (select xdate
                from xtimes ) s1
        where 1=1
        and ash.sample_time(+) between s1.xdate and s1.xdate+(&&interval_mins/1440)
        group by s1.xdate,event,sql_id)
order by 1,dbtw desc
/
undefine btime
undefine etime
undefine bt
undefine et
undefine interval_secs
