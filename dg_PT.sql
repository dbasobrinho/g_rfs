-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dg.sql                                                   |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
COLUMN DG_CONF NEW_VALUE DG_CONF NOPRINT;
select value DG_CONF from v$parameter a where name = 'log_archive_config';
SET TERMOUT ON;


PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DG Status Replicacao Ativa                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT | DG_CONF  : &DG_CONF
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    200
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN REPLICACAO_DG          FORMAT a100       HEAD 'REPLICACAO DG CONFIGURACAO'
COLUMN STANDBY_LAST_RECEIVED  FORMAT 9999999    HEAD 'ULTIMO ARC|ORIGEM'          justify CENTER
COLUMN STANDBY_LAST_APPLIED   FORMAT 9999999    HEAD 'ULTIMO ARC|DESTINO'         justify CENTER
COLUMN STANDBY_DT_LAST_APP    FORMAT a19        HEAD 'ULTIMA DATA|DESTINO'        justify CENTER
COLUMN data_atual             FORMAT a19        HEAD 'DATA| ATUAL'                justify CENTER
COLUMN MINUTOS                FORMAT 999999     HEAD 'DIF|MIN'                    justify CENTER
COLUMN ARC_DIFF               FORMAT 999999     HEAD 'DIF|ARC'                    justify CENTER
COLUMN DATABASE_ROLE          FORMAT a16        HEAD 'DATABASE|PERFIL'            justify CENTER
COLUMN PROTECTION_MODE        FORMAT a20        HEAD 'MODO|PROTECAO'              justify CENTER
COLUMN thread                 FORMAT 99999      HEAD 'THREAD|'                    justify CENTER
COLUMN SWITCHOVER_STATUS      FORMAT a16        HEAD 'SWITCHOVER|STATUS'          justify CENTER
COLUMN DEST_ID                FORMAT 999        HEAD 'ID|DEST'                    justify CENTER
COLUMN NAME                   FORMAT a10        HEAD 'DEST|NAME'                  justify CENTER
COLUMN ST                     FORMAT a03        HEAD 'ST|'                        justify CENTER
COLUMN NAME                   FORMAT a20        HEAD 'NAME|DESTINATION'           justify CENTER
SET COLSEP '|'
SET FEEDBACK    off







column fuzzy format a6 heading 'fuzzy'
select status,to_char(checkpoint_change#) checkpoint_change
      ,to_char(checkpoint_time, 'dd-mon-yyyy hh24:mi:ss') as checkpoint_time
      ,count(*) cnt ,fuzzy
  from v$datafile_header
 group by status,checkpoint_change#,checkpoint_time,fuzzy
 order by status,checkpoint_change#,checkpoint_time
/
SET FEEDBACK    on
PROMPT
SET FEEDBACK    off
SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY
/
PROMPT
set feedback off
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
set feedback on
----select 
----(select nvl2(xx.name,xx.DEST_ID||' - '||xx.name,null)
----	     from v$archived_log xx 
----		where xx.DEST_ID = h.DEST_ID 
----		  and xx.resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
----		  and SEQUENCE#  = (select max(yy.SEQUENCE#) 
----		                      from v$archived_log yy 
----							 where yy.resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
----							  and yy.DEST_ID = xx.DEST_ID)) as name,
----h.*
----from(
----select DEST_ID, APPLIED, thread# thread ,max(sequence#) 
----from v$archived_log 
----where resetlogs_change#=(SELECT resetlogs_change# FROM v$database) 
----and UPPER(NAME) NOT LIKE '%ARCHIVELOG%'
----and resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
----group by DEST_ID, thread#,APPLIED) h
----order by name, thread

------------
------------
------------
------------
------------
------------select  case when ARC_DIFF <= 3 then ':)'  when ARC_DIFF > 3 AND ARC_DIFF <=8  then ':|' ELSE ':('  END ST
------------,  z.*
------------from(
------------SELECT c.DATABASE_ROLE,
------------       c.PROTECTION_MODE,
------------           C.SWITCHOVER_STATUS,
------------           a.DEST_ID,
------------           (select xx.name from v$archived_log xx where xx.DEST_ID = a.DEST_ID and SEQUENCE# = (select max(yy.SEQUENCE#) from v$archived_log yy where yy.DEST_ID = xx.DEST_ID)) as name,
------------       a.thread# thread,
------------       b.last_seq STANDBY_LAST_RECEIVED ,
------------       a.applied_seq STANDBY_LAST_APPLIED,
------------           b.last_seq - a.applied_seq ARC_DIFF ,
------------       TO_CHAR(a.last_app_timestamp,'DD/MM/YYYY HH24:MI:SS') as STANDBY_DT_LAST_APP,
------------           TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI:SS') as data_atual,
------------           (sysdate - a.last_app_timestamp) *24*60  as MINUTOS
------------      --(select value from v$parameter a where name = 'log_archive_config') REPLICACAO_DG
------------FROM   (SELECT thread#, DEST_ID,Max(sequence#) applied_seq,  Max(next_time) last_app_timestamp
------------        FROM   v$archived_log
------------        WHERE  applied = 'YES'
------------                and resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
------------        GROUP  BY thread#, DEST_ID) a,
------------       (SELECT thread#, DEST_ID, Max (sequence#) last_seq
------------        FROM   v$archived_log
------------                where resetlogs_change#=(SELECT resetlogs_change# FROM v$database)
------------        GROUP  BY thread#, DEST_ID ) b,
------------                (SELECT DATABASE_ROLE, DB_UNIQUE_NAME INSTANCE, OPEN_MODE, PROTECTION_MODE, PROTECTION_LEVEL, SWITCHOVER_STATUS FROM V$DATABASE) c
------------WHERE  a.thread# = b.thread#
------------and a.DEST_ID = b.DEST_ID
------------and ((c.DATABASE_ROLE = 'PRIMARY'and (a.thread#,b.DEST_ID ) in (SELECT INST_ID thread#, DEST_ID FROM GV$ARCHIVE_DEST_STATUS WHERE STATUS <> 'INACTIVE')) or (c.DATABASE_ROLE <> 'PRIMARY'))
------------order by   b.DEST_ID, a.thread#) z --where UPPER(z.NAME) NOT LIKE '%ARCHIVELOG%'

