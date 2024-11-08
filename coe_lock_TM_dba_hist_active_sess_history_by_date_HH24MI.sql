
---- Mostrar instance(s) do banco
set lines 350
set pages 50000
set time on
set timing off
SET VERIFY OFF
col HOST_NAME format a15
col VERSION format a10
col status format a10
col instance_name format a10
col name format a15
col logins format a10
col open_mode format a10
col database_role format a15
SET TERMOUT OFF;
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
exec dbms_application_info.set_module( module_name => 'ZICA! WORKING [ZICA]. . . [ZICA]', action_name =>  'ZICA! ZICA [ZICA]. . . [rfs]');
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : LOCKED TM - OFENSOR [HH24:MI]         +-+-+-+-+-+-+-+-+-+-+ |
PROMPT | Instance : &current_instance                     |r|f|s|o|b|r|i|n|h|o| |
PROMPT | Version  : 1.0                                   +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
PROMPT
set lines 3000
set pages 500 
COLUMN username            FORMAT a30         HEAD 'USERNAME|-'                     JUSTIFY CENTER
COLUMN sample_time         FORMAT a18         HEAD 'SAMPLE_TIME|-'                  JUSTIFY CENTER
COLUMN sql_id              FORMAT a15         HEAD 'SQL_ID|-'                       JUSTIFY CENTER
COLUMN program             FORMAT a30         HEAD 'PROGRAM|-'                      JUSTIFY CENTER
COLUMN module              FORMAT a20         HEAD 'MODULE|-'                       JUSTIFY CENTER
COLUMN machine             FORMAT a40         HEAD 'MACHINE|-'                      JUSTIFY CENTER
COLUMN temp_use_gb         FORMAT 99999999    HEAD 'TEMP_USED|(GB)'                 JUSTIFY CENTER
COLUMN event               FORMAT a40         HEAD 'EVENT|-'                        JUSTIFY CENTER
COLUMN object_name         FORMAT a40         HEAD 'OBJECT_NAME|-'                  JUSTIFY CENTER
COLUMN OWNER               FORMAT a10         HEAD 'OWNER|-'                        JUSTIFY CENTER
COLUMN object_type         FORMAT 99999999    HEAD 'object_type|-'                  JUSTIFY CENTER
COLUMN total_wait_time     FORMAT 99999999    HEAD 'total_wait_time|-'              JUSTIFY CENTER
COLUMN pct                 FORMAT 99999999    HEAD '%|-'                            JUSTIFY CENTER
COLUMN sql_plan_hash_value FORMAT 99999999    HEAD 'sql_plan_hash_value|-'          JUSTIFY CENTER


PROMPT
ACCEPT DATA_INI CHAR PROMPT 'Data Inicial (DD/MM/YYYY HH24:MI) = ' 
ACCEPT DATA_FIM CHAR PROMPT 'Data Final   (DD/MM/YYYY HH24:MI) = ' 
ACCEPT v_sql_id CHAR PROMPT 'SQL_ID                      (ALL) = ' DEFAULT ALL
PROMPT
SET TERMOUT OFF;
set timing on
SET TERMOUT ON;
select nvl(event,'ON CPU')event,sql_id,sql_plan_hash_value,OWNER, object_name,object_type, count(*) total_wait_time,round((count(*))/(sum(count(*)) over() ) *100,2) pct
from dba_hist_active_sess_history a,dba_objects o
where a.sample_time >= to_date('&DATA_INI', 'dd/mm/yyyy hh24:mi') --to_date('25/03/2024 16:00','DD/MM/YYYY HH24:MI')
and a.sample_time >=   to_date('&DATA_FIM', 'dd/mm/yyyy hh24:mi') --to_date('25/03/2024 18:00','DD/MM/YYYY HH24:MI')
and event like 'enq:%TM%'
and o.object_id=a.current_obj#
and sql_id = DECODE('&&v_sql_id'   ,'ALL',a.sql_id   ,'&&v_sql_id')
group by nvl(event,'ON CPU'),sql_id,sql_plan_hash_value,OWNER, object_name,object_type
order by total_wait_time desc
/

/*select z.username, z.sample_time, round(z.gig,3) temp_use_gb, sql_id, substr(program,1,30) program, substr(module,1,20) module , substr(machine,1,40) machine
from (
select b.username, to_char(a.sample_time, 'dd/mm/yyyy hh24:MI') sample_time
      ,max((a.TEMP_SPACE_ALLOCATED)) / (1024 * 1024 * 1024) gig, sql_id, program, module , machine
  from DBA_HIST_ACTIVE_SESS_HISTORY a, dba_users b
 where a.sample_time >  to_date('&DATA_INI', 'dd/mm/yyyy hh24:mi')
   and a.sample_time <= to_date('&DATA_FIM', 'dd/mm/yyyy hh24:mi')
   and a.USER_ID = b.USER_ID 
   and a.sql_id     = DECODE('&&v_sql_id'   ,'ALL',a.sql_id   ,'&&v_sql_id')
 group by b.username, to_char(a.sample_time, 'dd/mm/yyyy hh24:MI'), sql_id,program, module , machine )z
 where z.username not in ('SYS')
 and round(z.gig) > 0
 order by to_date(z.sample_time , 'dd/mm/yyyy hh24:MI'), temp_use_gb desc
/
*/
UNDEFINE DATA_INI
UNDEFINE DATA_FIM
