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

COLUMN index_owner FORMAT A15
COLUMN index_name FORMAT A30
COLUMN column_name FORMAT A20
COLUMN column_position FORMAT 999
COLUMN num_distinct FORMAT 9999999
COLUMN clustering_factor FORMAT 9999999
COLUMN selectivity FORMAT 9999999.99999999

accept name prompt 'Nome da tabela: '
prompt

BREAK ON index_owner SKIP 1 ON index_name SKIP 1 


SELECT 
    ic.index_owner,
    ic.index_name,
    ic.column_name,
    ic.column_position,
    ts.num_distinct,
    t.num_rows,
    idx.clustering_factor,
	ts.num_distinct / t.num_rows AS selectivity
FROM 
    dba_ind_columns ic
LEFT JOIN 
    dba_tab_col_statistics ts
ON 
    ic.table_name = ts.table_name
    AND ic.column_name = ts.column_name
    AND ic.index_owner = ts.owner
LEFT JOIN 
    dba_indexes idx
ON 
    ic.index_owner = idx.owner
    AND ic.index_name = idx.index_name
LEFT JOIN 
    dba_tables t
ON 
    ic.index_owner = t.owner
    AND ic.table_name = t.table_name
WHERE 
    ic.table_name = UPPER('&name')
ORDER BY 
    ic.index_owner, 
    ic.index_name, 
    ic.column_position;


--
-- Fim
--
