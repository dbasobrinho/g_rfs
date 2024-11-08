-- -----------------------------------------------------------------------------------
set pages 1000
set lines 1000
 
COLUMN tbs_name    FORMAT A20
COLUMN NUM_EXTENTS FORMAT 999999
COLUMN NUM_BLOCKS  FORMAT 999999999
COLUMN mb_aloc     FORMAT 999999
COLUMN mb_use      FORMAT 999999
COLUMN pct_use     FORMAT A15
COLUMN status      FORMAT A10
COLUMN REF         FORMAT A60


 select z.TABLESPACE_NAME as tbs_name, z.NUM_EXTENTS, z.NUM_BLOCKS, X.size_allocated mb_aloc, z.mb_use
      , lpad(to_char(ROUND(Z.MB_USE / X.size_allocated * 100,2)),5,'0') ||' %' as pct_use,  z.status
      ,(case z.STATUS WHEN 'ACTIVE'    then 'TRANSACOES EM ANDAMENTO'
                      WHEN 'EXPIRED'   then 'TRANSACOES FINALIZADAS, UNDO_RETENTION EXPIRADO'
                      WHEN 'UNEXPIRED' then 'TRANSACOES FINALIZADAS, UNDO_RETENTION NAO EXPIRADO'END) REF
from (
select v.tablespace_name
      ,v.status
      ,count(*) Num_Extents
      ,sum(v.blocks) Num_Blocks
      ,round((sum(v.bytes) / 1024 / 1024), 2) MB_USE
  from dba_undo_extents v
 group by status, v.tablespace_name
 order by v.tablespace_name, status) Z
,( SELECT dt.tablespace_name ,round((SUM(ddf.bytes)/ 1024 / 1024), 2) size_allocated
          FROM dba_tablespaces dt
              ,dba_data_files  ddf
         WHERE dt.tablespace_name = ddf.tablespace_name
           AND dt.contents = 'UNDO'
         GROUP BY dt.tablespace_name
 )x
WHERE  X.tablespace_name = Z.tablespace_name
/