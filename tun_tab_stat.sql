-----------------------------------------------------------------------------
--
--  NAME
--    tab_stat.sql
-- 
--  DESCRIPTON
--    Mostra as estatisticas das colunas de uma tabela 
--
--  HISTORY
--    12/08/2016 => Valter Aquino
--
-----------------------------------------------------------------------------

set verify off tab off feedback off timing off
set pages 40 lines 300

col "NAME"         for a30
col "#DISTINCT"    for 999,999,999,990 
col "DENSITY"      for 9.999999999
col low_value      for a70
col high_value     for a70

prompt
accept owner prompt 'Owner : '
accept name prompt  'Tabela: '
prompt

BREAK ON kowner SKIP 1


SELECT column_name AS "NAME",
       num_distinct AS "#DISTINCT",
       density AS "DENSITY",
       num_nulls AS "#NULL",
       avg_col_len ,
       histogram,
       num_buckets AS "#BUCKETS",
       LOW_VALUE,
       HIGH_VALUE
  FROM dba_tab_col_statistics
 WHERE table_name = upper('&name')
   AND owner = upper('&owner');

UNDEFINE name
UNDEFINE owner
set feedback on timing on 
set pages 100 lines 200

--
-- Fim
--
