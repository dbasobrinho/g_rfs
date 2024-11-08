--
--
--  NAME
--    idx_stat.sql
--
--  DESCRIPTON
--    Mostra os indices de uma tabela e suas estatisticas.
--
--  HISTORY
--    28/02/2013 => Valter Aquino
--
-----------------------------------------------------------------------------
  
set verify off tab off

col kowner         for a16             heading 'Owner'
col kindex_name    for a30             heading 'Indice'
col kblevel        for 999             heading 'BLevel'
col knum_rows      for 999,999,999,990 heading 'Linhas'
col kdistinct_keys for 999,999,999,990 heading 'Chaves distintas'
col kclustering    for 999,999,999,990 heading 'Clustering Factor'
col knumlblks      for 999,999,999,990 heading 'Leaf Blocks'
col kavglblk       for 999,999,999,990 heading 'Avg Leaf Blocks'
col kavgdblk       for 999,999,999,990 heading 'Avg Data Blocks'

prompt
accept name prompt 'Nome da tabela: '
prompt

BREAK ON kowner SKIP 1

select owner kowner, 
       index_name kindex_name, 
       blevel kblevel, 
       num_rows knum_rows, 
       distinct_keys kdistinct_keys,
       CLUSTERING_FACTOR kclustering,
              status, 
       LEAF_BLOCKS knumlblks,
       AVG_LEAF_BLOCKS_PER_KEY kavglblk,
       AVG_DATA_BLOCKS_PER_KEY kavgdblk,
       VISIBILITY,    
       last_analyzed
from dba_indexes
where table_name = upper('&name')
order by owner, index_name
/

--
-- Fim
--
