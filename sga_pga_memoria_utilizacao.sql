--Script    : sga_pga_memoria_utilizacao.sql
--Data      : 27/06/2017
--Autor     : Roberto Fernandes Sobrinho
--Finalidade: Mostrar a utilizacao de memória da instância (SGA + PGA)
--Versão    : 1.0 
col TOTAL_UTILIZADO               format a15   heading "TOTAL IN USE|MB SGA+PGA"        JUSTIFY CENTER 
col SGA_MAX_SIZE                  format a15   heading "<ASMM>|SGA_MAX_SIZE|MB"         JUSTIFY CENTER
col SGA_TARGET                    format a15   heading "<ASMM>|SGA TARGET| MB"          JUSTIFY CENTER 
col PGA_AGGREGATE_LIMIT           format a15   heading "<ASMM>|PGA_AGGREGATE|LIMIT MB"  JUSTIFY CENTER 
col PGA_AGGREGATE_TARGET          format a15   heading "<ASMM>|PGA_AGGREGATE|TARGET MB" JUSTIFY CENTER 
col MEMORY_MAX_TARGET             format a15   heading "<AMM>|MEMORY_MAX|TARGET MB"     JUSTIFY CENTER 
col MEMORY_TARGET                 format a15   heading "<AMM>|MEMORY_TARGET|MB"         JUSTIFY CENTER 
set pagesize 1000
set lines 1000
--set echo on 
select to_char(a.pga + b.sga          ,'9999999999999') TOTAL_UTILIZADO, 
       to_char(c.SGA_MAX_SIZE         ,'9999999999999') SGA_MAX_SIZE,
       to_char(d.SGA_TARGET           ,'9999999999999') SGA_TARGET,
       to_char((select value/1024/1024 pga_aggregate_limit  from v$parameter where name= 'pga_aggregate_limit' )  ,'9999999999999') PGA_AGGREGATE_LIMIT,
	   to_char(f.PGA_AGGREGATE_TARGET ,'9999999999999') PGA_AGGREGATE_TARGET,
       to_char(g.MEMORY_MAX_TARGET    ,'9999999999999') MEMORY_MAX_TARGET,
	   to_char(h.MEMORY_TARGET        ,'9999999999999') MEMORY_TARGET
from (select sum(pga_used_mem)/1024/1024 pga from v$process) a,
      (select sum(value)      /1024/1024 sga  from v$sga) b,
      (select name, value     /1024/1024 SGA_MAX_SIZE         from v$parameter where name= 'sga_max_size'        ) c,
      (select name, value     /1024/1024 SGA_TARGET           from v$parameter where name= 'sga_target'          ) d,
    --(select name, value     /1024/1024 pga_aggregate_limit  from v$parameter where name= 'pga_aggregate_limit' ) e	  
      (select name, value     /1024/1024 PGA_AGGREGATE_TARGET from v$parameter where name= 'pga_aggregate_target') f,
      (select name, value     /1024/1024 MEMORY_MAX_TARGET    from v$parameter where name= 'memory_max_target'   ) g,
      (select name, value     /1024/1024 MEMORY_TARGET        from v$parameter where name= 'memory_target'       ) h
/	  