SET SQLPROMPT "_USER'@'_CONNECT_IDENTIFIER _PRIVILEGE> "
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY hh24:mi:ss';
set lines 350
set pages 50000
set time on
set timing off
col HOST_NAME format a30
col VERSION format a20
col status format a10
col instance_name format a10
col name format a15
col logins format a10
col open_mode format a10
col database_role format a15
PROMPT #####################################################################
PROMPT AMBIENTE
PROMPT #####################################################################
select a.INST_ID, INSTANCE_NAME, HOST_NAME, VERSION, NAME, STARTUP_TIME, STATUS, OPEN_MODE,DATABASE_ROLE, LOGINS, SYSDATE from gv$instance a,gv$database b where a.INST_ID = b.INST_ID;
PROMPT #####################################################################
PROMPT MVIEW COM PROBLEMA
PROMPT #####################################################################
select *  from (
select* from dba_mviews where owner not in ('SYS','SYSMAN','SYSTEM','DBSNMP')
and ((last_refresh_date <= (sysdate - (2/400))
and REFRESH_METHOD='FAST')
or (last_refresh_date <= (sysdate - (2/24)) and REFRESH_METHOD='FORCE'))) where MVIEW_NAME not in ('MVIEW_C01VW1535','MVIEW_FL_DRIVER_VEHICLE_GROUP','AU_OPEN_TRANSACTION_TED','AD_CALL_ORIGIN_WEBSERVICE_MV') and sysdate >= trunc(sysdate)+4/24 
/
PROMPT #####################################################################
PROMPT LAST REFRESH MVIEWS
PROMPT #####################################################################
select owner, mview_name, last_refresh_type, to_char(LAST_REFRESH_DATE, 'yyyy-mm-dd hh24:mi:ss') last_refresh_date from dba_mviews order by last_refresh_date;
col status format a10
PROMPT #####################################################################
PROMPT MAX CHECKPOINT MVIEW_REFRESH_LOG
PROMPT #####################################################################
select status, max(data_checkpoint) from MVIEW_REFRESH_LOG where data_checkpoint > trunc(sysdate) group by status order by 2;

col Registros_mlog    format 999,999,999
col registros_pend    format 999,999,999
col Feito             format 999,999,999
col MATERIALIZED_VIEW format a50
PROMPT #####################################################################
PROMPT MONITORA PROGRESSO MVIEW FAST [MLOG$_AU_OPEN_TRANSACTION@AUTORIZADOR]
PROMPT #####################################################################
select distinct DMLTYPE$$,count(*) Registros_mlog from sysau.MLOG$_AU_OPEN_TRANSACTION@AUTORIZADOR group by DMLTYPE$$;
Select distinct inicio as dt_inicio,
       sysdate dt_atual,
       substr(to_char(numtodsinterval((sysdate - inicio), 'DAY')), 12, 8) tempo,
       nvl(Registros, 0) registros_pend,
	          nvl(feito, 0) Feito,
       round(feito / nvl(registros, 100000000) * 100, 2) "%",
       sysdate +
       ((registros - feito) * (sysdate - inicio) / nvl(decode(feito,0,1), 100000000000)) Estimativa
  from (select max(data_checkpoint) INICIO
          from MVIEW_REFRESH_LOG
         where data_checkpoint > trunc(sysdate)
           and status = 'INICIO'),
       (select count(*) Registros
          from sysau.MLOG$_AU_OPEN_TRANSACTION@AUTORIZADOR),
       (SELECT total_inserts_knstmvr + total_updates_knstmvr +
               total_deletes_knstmvr Feito
          FROM x$knstmvr X
         WHERE type_knst = 6
           AND EXISTS
         (SELECT 1
                  FROM v$session s
                 WHERE s.sid = x.sid_knst
                   AND s.serial# = x.serial_knst)
           and currmvname_knstmvr like '%AU_OPEN_TRANSACTION%')
/   
			  
column MATERIALIZED_VIEW format a50  JUSTIFY center
column "REFRESH TYPE" format a20 JUSTIFY center
column "STATUS" format a27 JUSTIFY center
column inserts format 999,999,999 JUSTIFY center
column updates format 999,999,999 JUSTIFY center
column deletes format 999,999,999 JUSTIFY center
PROMPT #####################################################################
PROMPT MONITORA PROGRESSO MVIEWS
PROMPT #####################################################################
SELECT currmvowner_knstmvr
       || '.'
       || currmvname_knstmvr    MATERIALIZED_VIEW,
       Decode(reftype_knstmvr, 1, 'FAST - RAPIDO',
                               2, 'COMPLETE - COMPLETO',
                                  'UNKNOWN')     as "REFRESH TYPE",
       Decode(groupstate_knstmvr, 1, 'SETUP - Iniciando Processo',
                                  2, 'INSTANTIATE - Carregando',
                                  3, 'WRAPUP - Finalizando',
                                  'UNKNOWN') STATUS,
       total_inserts_knstmvr                 INSERTS,
       total_updates_knstmvr                 UPDATES,
       total_deletes_knstmvr                 DELETES
FROM   x$knstmvr X
WHERE  type_knst = 6
       AND EXISTS (SELECT 1
                   FROM   v$session s
                   WHERE  s.sid = x.sid_knst
                          AND s.serial# = x.serial_knst)
/						  
set timing on 


