--Script    : @sga_memory_full_state.sql
SET PAGESIZE            1000 
SET LINESIZE            220 
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy HH24:MI:SS';
COLUMN FILE_NAME FORMAT A120 
COLUMN NAME      FORMAT A80 
COLUMN TYPE      FORMAT A30 
COLUMN VALUE     FORMAT A110 
SET TERMOUT ON;
SET TIMING      OFF
col NAME_COL_PLUS_SHOW_PARAM          format a35
col TYPE                              format a15
col VALUE_COL_PLUS_SHOW_PARAM         format a30
set echo on
show parameter memory
set echo off
prompt ..
prompt .
set echo on
show parameter db_cache_size
set echo off
prompt ..
prompt .
set echo on
show parameter shared_pool
set echo off
prompt ..
prompt .
set echo on
show parameter sga
set echo off
prompt ..
prompt .
set echo on
show parameter session_cached_cursors
set echo off
prompt ..
prompt .
set echo on
show parameter use_large_pages
set echo off
prompt ..
prompt .
SET FEEDBACK    OFF
--Script    : @sga_memory_full_state.sql
COLUMN INST_ID     FORMAT 9999999
COLUMN CON_ID      FORMAT 9999999
COLUMN NAME        FORMAT A39
COLUMN BYTES       FORMAT 99999999999999.99 heading "BYTES" 
COLUMN mb          FORMAT 9999999999.99 heading "MB" 
COLUMN GB          FORMAT 9999999999.99 heading "GB" 
COLUMN RESIZEABLE FORMAT A11
prompt
prompt #######################################################################################################################
prompt # GV$SGAINFO                                                                                                          #
prompt #######################################################################################################################
select INST_ID, NAME, 
BYTES, BYTES/1024/1024 mb,  BYTES/1024/1024/1024 gb,  RESIZEABLE  from gv$sgainfo order by NAME, INST_ID
/
COLUMN size_GB        FORMAT 9999999999.99 heading "SIZE-GB" 
COLUMN min_size_GB    FORMAT 9999999999.99 heading " MIN-GB" 
COLUMN MAX_size_GB    FORMAT 9999999999.99  heading " MAX-GB" 
COLUMN size_MB        FORMAT 9999999999.99  heading "SIZE-MB"
COLUMN min_size_MB    FORMAT 9999999999.99  heading " MIN-MB"
COLUMN MAX_size_MB	  FORMAT 9999999999.99  heading " MAX-MB"
COLUMN LAST_OPER_TYPE FORMAT A16        
COLUMN component      FORMAT A32        
COLUMN GRANULE_GB     FORMAT 9999999999.99 heading " GRANULE-GB"  
COLUMN GRANULE_mb     FORMAT 9999999999.99 heading " GRANULE-MB"  
prompt
prompt #######################################################################################################################
prompt # GV$SGA_DYNAMIC_COMPONENTS                                                                                           #
prompt #######################################################################################################################
SELECT INST_ID,              component, 
current_size/1024/1024/1024     as size_GB, 
    min_size/1024/1024/1024     as min_size_GB,
    MAX_size/1024/1024/1024     as MAX_size_GB,
	GRANULE_SIZE/1024/1024/1024 as GRANULE_GB,
current_size/1024/1024          as size_MB, 
    min_size/1024/1024          as min_size_MB,
    MAX_size/1024/1024          as MAX_size_MB	,
GRANULE_SIZE/1024/1024           as GRANULE_mb,	
                                 LAST_OPER_TYPE
FROM Gv$sga_dynamic_components
WHERE current_size > 0
ORDER BY component, INST_ID
/
prompt
prompt #######################################################################################################################
prompt # LARGE_PAGES  |                 grep Huge /proc/meminfo                 |                                            #
prompt #######################################################################################################################
--Script    : @sga_memory_full_state.sql
--Data      : 27/06/2017
--Autor     : Roberto Fernandes Sobrinho
--Finalidade: Mostrar a utilizacao de mem▒ria da inst▒ncia (SGA + PGA)
--Vers▒o    : 1.0
col TOTAL_UTILIZADO               format a15   heading "TOTAL IN USE|MB SGA+PGA"        JUSTIFY CENTER
col SGA_MAX_SIZE                  format a15   heading "<ASMM>|SGA_MAX_SIZE|MB"         JUSTIFY CENTER
col SGA_TARGET                    format a15   heading "<ASMM>|SGA TARGET| MB"          JUSTIFY CENTER
col PGA_AGGREGATE_LIMIT           format a15   heading "<ASMM>|PGA_AGGREGATE|LIMIT MB"  JUSTIFY CENTER
col PGA_AGGREGATE_TARGET          format a15   heading "<ASMM>|PGA_AGGREGATE|TARGET MB" JUSTIFY CENTER
col MEMORY_MAX_TARGET             format a15   heading "<AMM>|MEMORY_MAX|TARGET MB"     JUSTIFY CENTER
col MEMORY_TARGET                 format a15   heading "<AMM>|MEMORY_TARGET|MB"         JUSTIFY CENTER
col NAME_COL_PLUS_SHOW_PARAM          format a15
set pagesize 1000
set lines 1000
prompt
prompt #######################################################################################################################
prompt # SGA_RESIZE_OPS                                                                                                      #
prompt #######################################################################################################################
COLUMN parameter FORMAT A25
COLUMN component FORMAT A30
COLUMN oper_type FORMAT A14
SELECT start_time,
       end_time,
       component,
       oper_type, 
       oper_mode,
       parameter,
       ROUND(initial_size/1024/1024) AS initial_size_mb,
       ROUND(target_size/1024/1024) AS target_size_mb,
       ROUND(final_size/1024/1024) AS final_size_mb,
       status
FROM   v$sga_resize_ops
ORDER BY start_time
/
prompt
prompt #######################################################################################################################
prompt # DISTRIBUICAO INSTANCE                                                                                               #
prompt #######################################################################################################################
select to_char(a.pga + b.sga          ,'9999999999999') TOTAL_UTILIZADO,
       to_char(c.SGA_MAX_SIZE         ,'9999999999999') SGA_MAX_SIZE,
       to_char(d.SGA_TARGET           ,'9999999999999') SGA_TARGET,
       to_char((select value/1024/1024 pga_aggregate_limit  from v$parameter where name= 'pga_aggregate_limit' )  ,'9999999999999') PGA_AGGREGATE_LIMIT,
           to_char(f.PGA_AGGREGATE_TARGET ,'9999999999999') PGA_AGGREGATE_TARGET,
       to_char(g.MEMORY_MAX_TARGET    ,'9999999999999') MEMORY_MAX_TARGET,
           to_char(h.MEMORY_TARGET        ,'9999999999999') MEMORY_TARGET
from  (select sum(pga_used_mem)/1024/1024 pga from v$process) a,
      (select sum(value)      /1024/1024 sga  from v$sga) b,
      (select name, value     /1024/1024 SGA_MAX_SIZE         from v$parameter where name= 'sga_max_size'        ) c,
      (select name, value     /1024/1024 SGA_TARGET           from v$parameter where name= 'sga_target'          ) d,
    --(select name, value     /1024/1024 pga_aggregate_limit  from v$parameter where name= 'pga_aggregate_limit' ) e
      (select name, value     /1024/1024 PGA_AGGREGATE_TARGET from v$parameter where name= 'pga_aggregate_target') f,
      (select name, value     /1024/1024 MEMORY_MAX_TARGET    from v$parameter where name= 'memory_max_target'   ) g,
      (select name, value     /1024/1024 MEMORY_TARGET        from v$parameter where name= 'memory_target'       ) h
/
prompt
prompt #######################################################################################################################
prompt # SGA_DYNAMIC_FREE_MEMORY - quantidade de SGA disponível para futuras operações de redimensionamento dinâmico de SGA  #                                                                                            #
prompt #######################################################################################################################
select to_char(CURRENT_SIZE) as byte,to_char(CURRENT_SIZE/1024/1024) as MB, to_char(CURRENT_SIZE/1024/1024/1024) as gb   from v$sga_dynamic_free_memory
/
prompt . . .
SET FEEDBACK    OFF