--
--
--  NAME
--    idx_size.sql 
--
--  DESCRIPTION
--    Mostra o tamanho de todos os indices de uma determinada tabela.
--
--  HISTORY
--    04/07/2013 => Valter Aquino
--
-----------------------------------------------------------------------------
 
set verify off
set echo off
set timing off
set pages 100 lines 200 

col owner for a16 heading 'Owner'
col segment_name  for a40 heading 'Indice'

accept name prompt 'Nome da tabela: '
prompt

BREAK ON index_owner SKIP 1 ON index_name SKIP 1 

select owner,
       segment_name,
       round(bytes/1024/1024) MB
  from dba_segments
 where segment_name in (select index_name from dba_indexes where table_name = upper('&name'))
 order by 1,2;

set heading off;

select owner, 'Total ---> '||round(sum(bytes)/1024/1024)||' MB'
  from dba_segments
 where segment_name in (select index_name from dba_indexes where table_name = upper('&name'))
 group by owner;

set heading on timing on;
--
-- Fim
--
