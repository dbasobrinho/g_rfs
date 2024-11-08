-- |----------------------------------------------------------------------------|
-- | Objetivo   : SNAPSHOT EXECUTION TIME SQLID                                 |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 23/03/2023 (Ontem foi meu aniversario)                        |
-- | Exemplo    : limit_hist_processes_by_date.sql                              |
-- | Arquivo    : limit_hist_processes_by_date.sql                              |
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
PROMPT | Report   : LIMIT PROCESSES CURRENT             +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.2                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT
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
col RESOURCE_NAME  format a20          HEADING 'RESOURCE_NAME|-'  JUSTIFY CENTER 
col LOADS_DELTA  format 999             HEADING 'L|-'           JUSTIFY CENTER 
col CPU_TIME     format 9999999999    HEADING 'CPU|TIME(MIN)'     JUSTIFY CENTER  
col ELAPSED_TIME format 9999999999  HEADING 'ELAPSED|TIME(MIN)' JUSTIFY CENTER  
col SNAPSHOTTIME        format a17           HEADING 'SNAP|END TIME' JUSTIFY CENTER 
col etime        format a05           HEADING 'END|TIME' JUSTIFY CENTER 
col minutes      format 9999          HEADING 'MIN|' JUSTIFY CENTER 
col CURRENT_UTILIZATION   format 999999      HEADING 'CURRENT|UTILIZATION' JUSTIFY CENTER 
col MAX_UTILIZATION       format 999999      HEADING 'MAX|UTILIZATION' JUSTIFY CENTER 
col LIMIT_VALUE       format 999999      HEADING 'LIMIT|VALUE' JUSTIFY CENTER 
col RROWS        format 99999999      HEADING 'ROWS|PROCECED' JUSTIFY CENTER 
col AGV_DURATION format 9999999.999    HEADING 'AVG|TIME(SEC)' JUSTIFY CENTER 
col p_hash_value format 9999999999    HEADING 'PLAN|HASH_VALUE'         JUSTIFY CENTER
col Rows         format 9999999999    HEADING 'ROWS|-'                  JUSTIFY CENTER
col DiskRead     format 9999999999    HEADING 'DISKREAD|EXEC'           JUSTIFY CENTER
col BufferGets   format 9999999999    HEADING 'BUFFERGETS|EXEC'         JUSTIFY CENTER
col Px_Servers   format 99            HEADING 'PX|-'         JUSTIFY CENTER
col PERC         format 99            HEADING '%|-'         JUSTIFY CENTER
SET COLSEP '|' 

	COL SNAPSHOTTIME FOR A20
	COL RESOURCE_NAME FOR A20
	
	
select INST_ID, RESOURCE_NAME,CURRENT_UTILIZATION,MAX_UTILIZATION,LIMIT_VALUE from gv$resource_limit where resource_name in ('sessions','processes') order by 1,2,3;


CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF days
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 

