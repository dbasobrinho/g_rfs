--Script: PGA_LISTA_PARAMETROS_CONFIGURACAO
--Data:   11/03/2013
--Autor: Marcio Guimaraes
--Finalidade: Lista parametros de configuração da PGA
--Versão: 1.0 


set pagesize 1000
set lines 1000
column name format a22
column description format a80
column MB format 99,999
--set echo on 

SELECT ksppinm name, ksppdesc description,
       CASE WHEN ksppinm LIKE '_smm%' THEN ksppstvl/1024 
             ELSE ksppstvl/1048576 END as MB
  FROM sys.x$ksppi JOIN sys.x$ksppcv
       USING (indx)
WHERE ksppinm IN
            ('pga_aggregate_target',
             '_pga_max_size',
             '_smm_max_size',
             '_smm_px_max_size','__pga_aggregate_target' )
/			 