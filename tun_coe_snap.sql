-- |----------------------------------------------------------------------------|
-- | Objetivo   : SNAPSHOT EXECUTION TIME SQLID                                 |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 01/03/2019                                                    |
-- | Exemplo    : coe_snap.sql                                                  |
-- | Arquivo    : coe_snap.sql                                                  |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+ 
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : SNAPSHOT EXECUTION TIME SQLID       +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.2                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT sql_id2 char   PROMPT 'SQL_ID    [*] = '
ACCEPT days    number PROMPT 'SYSDATE - [1] = ' DEFAULT 1
PROMPT
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
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES 
col inst_id      format 99           HEADING 'I|-'      JUSTIFY CENTER
col snap_id      format 99999999     HEADING 'SNAP|ID'  JUSTIFY CENTER
col sql_id       format a13          HEADING 'SQL_ID|-'  JUSTIFY CENTER
col SQL_PROFILE  format a30          HEADING 'SQL PROFILE|NAME'  JUSTIFY CENTER 
col LOADS_DELTA  format 999             HEADING 'L|-'           JUSTIFY CENTER 
col CPU_TIME     format 9999999999    HEADING 'CPU|TIME(MIN)'     JUSTIFY CENTER  
col ELAPSED_TIME format 9999999999  HEADING 'ELAPSED|TIME(MIN)' JUSTIFY CENTER  
col btime        format a12           HEADING 'BEGIN|TIME' JUSTIFY CENTER 
col etime        format a05           HEADING 'END|TIME' JUSTIFY CENTER 
col minutes      format 9999          HEADING 'MIN|' JUSTIFY CENTER 
col executions   format 999999      HEADING 'EXEC|' JUSTIFY CENTER 
col RROWS        format 99999999      HEADING 'ROWS|PROCECED' JUSTIFY CENTER 
col AGV_DURATION format 9999999.99999    HEADING 'AVG|TIME(SEC)' JUSTIFY CENTER 
col p_hash_value format 9999999999    HEADING 'PLAN|HASH_VALUE'         JUSTIFY CENTER
col Rows         format 9999999999    HEADING 'ROWS|-'                  JUSTIFY CENTER
col DiskRead     format 9999999999    HEADING 'DISKREAD|EXEC'           JUSTIFY CENTER
col BufferGets   format 9999999999    HEADING 'BUFFERGETS|EXEC'         JUSTIFY CENTER
col Px_Servers   format 99            HEADING 'PX|-'         JUSTIFY CENTER
SET COLSEP '|' 
select a.instance_number inst_id,
       --a.snap_id,
       a.sql_id, 
       a.plan_hash_value as p_hash_value,
       a.SQL_PROFILE,
       a.LOADS_DELTA,
       a.CPU_TIME_DELTA / 60000 as CPU_TIME,
       a.ELAPSED_TIME_DELTA / 60000 as ELAPSED_TIME,
       to_char(begin_interval_time, 'ddMMYY hh24:mi') btime,
       to_char(END_INTERVAL_TIME, 'hh24:mi')   etime,	   
       abs(extract(minute from(end_interval_time - begin_interval_time)) +
           extract(hour from(end_interval_time - begin_interval_time)) * 60 +
           extract(day from(end_interval_time - begin_interval_time)) * 24 * 60) minutes,
       	   a.ROWS_PROCESSED_DELTA RROWS,
        round((DISK_READS_delta)/greatest((executions_delta),1),0) DiskRead,
        round((BUFFER_GETS_delta)/greatest((executions_delta),1),0) BufferGets,	  
        A.PX_SERVERS_EXECS_DELTA Px_Servers,		
		executions_delta executions,
        round(ELAPSED_TIME_delta / 1000000 / greatest(executions_delta, 1), 7) AGV_DURATION
  from dba_hist_SQLSTAT a, dba_hist_snapshot b
 where sql_id = '&&sql_id2'
   and a.snap_id = b.snap_id
   and a.instance_number = b.instance_number
   and begin_interval_time > trunc(sysdate - &&days)
 order by a.snap_id desc, begin_interval_time desc, a.instance_number
/
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF days
UNDEF sql_id2
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 

