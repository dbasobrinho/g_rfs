col input_type for a20
col status for a08
SET LINES 1000
SET PAGES 1000
col start_time          for a17
col DT                  for a19
col output_MB           for a10
col MATERIALIZED_VIEW   for a30

select distinct MATERIALIZED_VIEW from MVIEW_REFRESH_LOG
/
select z.MATERIALIZED_VIEW,TO_CHAR(Z.DATA_CHECKPOINT,'DD/MM/YYYY HH24:MI:SS') as DT, Z.STATUS  
FROM
(
SELECT MATERIALIZED_VIEW,
       DATA_CHECKPOINT ,
       STATUS 
   FROM sys.MVIEW_REFRESH_LOG 
 WHERE MATERIALIZED_VIEW = '&MVIEW_NAME'
   and DATA_CHECKPOINT > sysdate -&DIAS_ATRAS
) z
ORDER BY DATA_CHECKPOINT desc
/
