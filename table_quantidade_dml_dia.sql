--Script: MODIFICACOES_TABELA_ULTIMO_DIA
--Data:   01/11/2015
--Finalidade: Mostra a quantidade INSERT , UPDATES e DELETES realizado nas tabelas no ultimo dia

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | MODIFICACOES TABELA ULTIMO DIA                                    |
PROMPT +------------------------------------------------------------------------+
PROMPT | alter table [OWNER].[TABLE_NAME] move pctfree 50 pctused 30;           |
PROMPT | alter table [OWNER].[TABLE_NAME] minimize records_per_block;           |
PROMPT +------------------------------------------------------------------------+
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT days       char PROMPT 'OWNER      = '
ACCEPT table_name_002  char PROMPT 'TABLE_NAME = '
DEFINE ponto    = '.' (CHAR)
PROMPT
COL owner                FOR A10;
COL table_name           FOR A30;
COL pct_free             FOR 999;
COL pct_used             FOR 999;
COL chain_cnt            FOR 999999;
COL com                  FOR A100;
COL status               FOR A10;
COL blockno              FOR 99999999;
COL tot_lines            FOR 999999;
COL blockno_tot          FOR 999999999;
COL lines_tot            FOR 999999999;
COL avg_lines_block      FOR 999999999;

select * from dba_tab_modifications a
where a.table_owner not in ('SYS','SYSTEM','WMSYS','OUTLN','XDB','DBSNMP','RENATO') and
      TRUNC(a.timestamp) >= trunc(sysdate)-&days