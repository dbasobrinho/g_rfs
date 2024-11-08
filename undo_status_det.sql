-- -----------------------------------------------------------------------------------
set pages 1000
set lines 1000
select z.*, (case z.STATUS WHEN 'ACTIVE'    then 'TRANSACAOS EM ANDAMENTO'
                           WHEN 'EXPIRED'   then 'TRANSACAOS FINALIZADAS, UNDO_RETENTION NAO EXPIRADO'
					       WHEN 'UNEXPIRED' then 'TRANSACAOS FINALIZADAS, UNDO_RETENTION EXPIRADO'
                    END) REF
from (
select tablespace_name, owner, segment_name
      ,status
      ,count(*) Num_Extents
      ,sum(blocks) Num_Blocks
      ,round((sum(bytes) / 1024 / 1024), 2) MB
  from dba_undo_extents
 group by status, tablespace_name, owner, segment_name
 order by tablespace_name, status) Z
 /
