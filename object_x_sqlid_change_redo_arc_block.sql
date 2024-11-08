-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : object_x_sqlid_change_redo_arc_block.sql                        |
-- | CREATOR  : ROBERTO FERNANDES SOBRINHO                                      |
-- | DATE     : 21/02/2019 (amanha e meu aniversario, VIVA!)                    |
-- |          : 19/02/2021 Dois anos depois, um pequeno ajuste                  |
-- +----------------------------------------------------------------------------+
set lines 1000  
set pages 500  
SET FEEDBACK   off
ALTER SESSION FORCE PARALLEL DML PARALLEL   08;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 08;
alter session set nls_date_format='DD/mm/RR HH24:MI'; 
alter session set parallel_force_local=true;
SET FEEDBACK   on
SET TERMOUT OFF;
set verify off 
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
ACCEPT DATA_INI CHAR DEFAULT '18/02/2021 19:30:00' PROMPT 'DATA INICIAL (DD/MM/YYYY HH24:MI:SS) = '
ACCEPT DATA_FIM CHAR DEFAULT '18/02/2021 20:30:00' PROMPT 'DATA FINAL   (DD/MM/YYYY HH24:MI:SS) = '
COLUMN sql_id           FORMAT A13
COLUMN event            FORMAT A23
COLUMN BLOCKING_SESSION FORMAT 999999
COLUMN SID              FORMAT 99999
COLUMN SERIAL           FORMAT 999999
COLUMN SAMPLE_TIME      FORMAT A20
COLUMN USERNAME         FORMAT A15
COLUMN PROGRAM          FORMAT A16
COLUMN MODULE           FORMAT A20
COLUMN MACHINE          FORMAT A20
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : QTDE LOGSWITCH REDO                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.1                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT
BREAK ON x SKIP 2 ON REPORT 
COMPUTE SUM OF  logswitch   ON report
COMPUTE SUM OF  "REDO PER DAY (TB)"   ON report
select to_char(z.rundate,'dd/mm/yyyy') as rundate, z.logswitch, z.redo_day as "REDO PER DAY (TB)"
from(
select trunc(completion_time) rundate,
       count(*) logswitch,
       round((sum(blocks * block_size) / 1024 / 1024 / 1024 / 1024)) redo_day
  from gv$archived_log
  where completion_time BETWEEN
       to_date('&&DATA_INI', 'dd/mm/yyyy hh24:mi:ss') and
       to_date('&&DATA_FIM', 'dd/mm/yyyy hh24:mi:ss')  
 group by trunc(completion_time)
 order by 1) z
/

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : QTDE BLOCK CHANGES                  +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.1                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT

BREAK ON x SKIP 2 ON REPORT 
COMPUTE SUM OF  maxchages   ON report
SELECT /*+ parallel(dhss,8) parallel(dhsso,8) parallel(dhs,8) */
       to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI') snap_time,
       dhsso.object_name,
       sum(db_block_changes_delta) as maxchages
  FROM dba_hist_seg_stat     dhss,
       dba_hist_seg_stat_obj dhsso,
       dba_hist_snapshot     dhs
 WHERE dhs.snap_id = dhss.snap_id
   AND dhs.instance_number = dhss.instance_number
   AND dhss.obj# = dhsso.obj#
   AND dhss.dataobj# = dhsso.dataobj#
   AND begin_interval_time BETWEEN
       to_date('&&DATA_INI', 'dd/mm/yyyy hh24:mi:ss') and
       to_date('&&DATA_FIM', 'dd/mm/yyyy hh24:mi:ss')
 GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'),
          dhsso.object_name
 having  sum(db_block_changes_delta) > 99         
 order by maxchages asc
/
PROMPT
PROMPT 
ACCEPT obj_name        CHAR PROMPT 'OBJECT_NAME = '
PROMPT
PROMPT
SET FEEDBACK   off
ALTER SESSION FORCE PARALLEL DML PARALLEL   08;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 08;
alter session set nls_date_format='DD/mm/RR'; 
alter session set parallel_force_local=true;
SET FEEDBACK   on
BREAK ON x SKIP 2 ON REPORT 
COMPUTE SUM OF  rows_processed_delta   ON report

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : SQID OBJ_NAME                       +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 2.1                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT

select trunc(dt) dt, substr(sql_text,1,70) sql_text, sql_id, sum(executions_delta) executions, sum(rows_processed_delta)   rows_processed
from(
SELECT begin_interval_time as dt,
       dbms_lob.substr(sql_text, 500, 1) AS sql_text,
       dhss.instance_number,
       dhss.sql_id,
       executions_delta,
       rows_processed_delta
  FROM dba_hist_sqlstat dhss, dba_hist_snapshot dhs, dba_hist_sqltext dhst
 WHERE upper(dhst.sql_text) LIKE UPPER('%&obj_name%')
   and '&obj_name' is not null
   AND dhss.snap_id = dhs.snap_id
   AND dhss.instance_Number = dhs.instance_number
   AND begin_interval_time BETWEEN
       to_date('&&DATA_INI', 'dd/mm/yyyy hh24:mi:ss') and
       to_date('&&DATA_FIM', 'dd/mm/yyyy hh24:mi:ss')
   AND dhss.sql_id = dhst.sql_id
   )
group by trunc(dt) , substr(sql_text,1,70), sql_id
HAVING  sum(rows_processed_delta) > 50
order by 1 , executions desc
/   
SET FEEDBACK   off
ALTER SESSION FORCE PARALLEL DML PARALLEL   01;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 01;
alter session set nls_date_format='DD/MM/YYYY HH24:MI:SS'; 
alter session set parallel_force_local=true;
SET FEEDBACK   on
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 

-----      BREAK ON x SKIP 2 ON REPORT 
-----      COMPUTE SUM OF  maxchages   ON report
-----      
-----      SELECT /*+ parallel(dhss,8) parallel(dhsso,8) parallel(dhs,8) */
-----             to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI') snap_time,
-----             dhsso.object_name,
-----             sum(db_block_changes_delta) as maxchages
-----        FROM dba_hist_seg_stat     dhss,
-----             dba_hist_seg_stat_obj dhsso,
-----             dba_hist_snapshot     dhs
-----       WHERE dhs.snap_id = dhss.snap_id
-----         AND dhs.instance_number = dhss.instance_number
-----         AND dhss.obj# = dhsso.obj#
-----         AND dhss.dataobj# = dhsso.dataobj#
-----         AND begin_interval_time BETWEEN
-----             to_date('18/02/2021 19:30:00', 'dd/mm/yyyy hh24:mi:ss') and
-----             to_date('18/02/2021 20:30:00', 'dd/mm/yyyy hh24:mi:ss')
-----      and dhsso.object_name like '%AU_OPEN%'	   
-----       GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'),
-----                dhsso.object_name
-----       having  sum(db_block_changes_delta) > 1         
-----       order by snap_time asc
-----      /
-----      



-----      BREAK ON x SKIP 2 ON REPORT 
-----      COMPUTE SUM OF  maxchages   ON report
-----      
-----      SELECT /*+ parallel(dhss,8) parallel(dhsso,8) parallel(dhs,8) */
-----             to_char(begin_interval_time, 'YYYY_MM_DD HH24') snap_time,
-----             dhsso.object_name,
-----             sum(db_block_changes_delta) as maxchages
-----        FROM dba_hist_seg_stat     dhss,
-----             dba_hist_seg_stat_obj dhsso,
-----             dba_hist_snapshot     dhs
-----       WHERE dhs.snap_id = dhss.snap_id
-----         AND dhs.instance_number = dhss.instance_number
-----         AND dhss.obj# = dhsso.obj#
-----         AND dhss.dataobj# = dhsso.dataobj#
-----         AND begin_interval_time BETWEEN
-----             to_date('18/02/2021 19:30:00', 'dd/mm/yyyy hh24:mi:ss') and
-----             to_date('18/02/2021 20:30:00', 'dd/mm/yyyy hh24:mi:ss')
-----      and dhsso.object_name like '%AU_OPEN%'	   
-----       GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD HH24'),
-----                dhsso.object_name
-----       having  sum(db_block_changes_delta) > 1         
-----       order by snap_time asc
-----      /
-----    


-----      BREAK ON x SKIP 2 ON REPORT 
-----      COMPUTE SUM OF  maxchages   ON report
-----      
-----      SELECT /*+ parallel(dhss,8) parallel(dhsso,8) parallel(dhs,8) */
-----             to_char(begin_interval_time, 'YYYY_MM_DD') snap_time,
-----             dhsso.object_name,
-----             sum(db_block_changes_delta) as maxchages
-----        FROM dba_hist_seg_stat     dhss,
-----             dba_hist_seg_stat_obj dhsso,
-----             dba_hist_snapshot     dhs
-----       WHERE dhs.snap_id = dhss.snap_id
-----         AND dhs.instance_number = dhss.instance_number
-----         AND dhss.obj# = dhsso.obj#
-----         AND dhss.dataobj# = dhsso.dataobj#
-----         AND begin_interval_time BETWEEN
-----             to_date('10/02/2021 19:30:00', 'dd/mm/yyyy hh24:mi:ss') and
-----             to_date('18/02/2021 20:30:00', 'dd/mm/yyyy hh24:mi:ss')
-----      and dhsso.object_name like '%AU_OPEN%'	   
-----       GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD'),
-----                dhsso.object_name
-----       having  sum(db_block_changes_delta) > 1         
-----       order by dhsso.object_name, snap_time asc
-----      /
-----    


-----       having  sum(db_block_changes_delta) > 1         
-----       order by maxchages asc
-----      /
-----    


-----      BREAK ON x SKIP 2 ON REPORT 
-----      COMPUTE SUM OF  maxchages   ON report
-----      
-----      SELECT /*+ parallel(dhss,8) parallel(dhsso,8) parallel(dhs,8) */
-----             to_char(begin_interval_time, 'YYYY_MM_DD') snap_time,
-----             dhsso.object_name,
-----             sum(db_block_changes_delta) as maxchages
-----        FROM dba_hist_seg_stat     dhss,
-----             dba_hist_seg_stat_obj dhsso,
-----             dba_hist_snapshot     dhs
-----       WHERE dhs.snap_id = dhss.snap_id
-----         AND dhs.instance_number = dhss.instance_number
-----         AND dhss.obj# = dhsso.obj#
-----         AND dhss.dataobj# = dhsso.dataobj#
-----         AND begin_interval_time BETWEEN
-----             to_date('18/02/2021 19:30:00', 'dd/mm/yyyy hh24:mi:ss') and
-----             to_date('18/02/2021 20:30:00', 'dd/mm/yyyy hh24:mi:ss')
-----      and dhsso.object_name like '%AU_OPEN%'	   
-----       GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD'),
-----                dhsso.object_name
-----       having  sum(db_block_changes_delta) > 1         
-----       order by snap_time asc
-----      /
-----    
