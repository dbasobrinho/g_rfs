--
--
--  NAME
--    idx_cols.sql
-- 
--  DESCRIPTION
--    Mostra as colunas de todos os indices de uma determinada tabela.
--
--  HISTORY
--    28/02/2013 => Valter Aquino
--
-----------------------------------------------------------------------------
  
set verify off tab off
set pages 100 lines 200 

col index_owner for a16 heading 'Owner'
col index_name  for a40 heading 'Indice'
col column_name for a20 heading 'Coluna'
col column_position for 999 heading 'Posicao'

accept name prompt 'Nome da tabela: '
prompt

BREAK ON index_owner SKIP 1 ON index_name SKIP 1 

select index_owner, index_name, column_name, column_position
from dba_ind_columns
where table_name = upper('&name')
order by index_owner, index_name, column_position
/

--
-- Fim
--
