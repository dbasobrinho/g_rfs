PROMPT 
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT | LATCH: CACHE BUFFERS CHAINS TABLE                                                           |
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT | alter table [OWNER].[TABLE_NAME] move pctfree 50 pctused 30 storage (freelists 2);          |
PROMPT | alter table [OWNER].[TABLE_NAME] minimize records_per_block;                                |
PROMPT | alter index [OWNER].[INDEX_NAME] rebuild pctfree 50 storage (freelists 2);                  |
PROMPT | http://toolkit.rdbms-insight.com/latch.php                                                  |
PROMPT | SE FOR USAR O FREELISTS, LEIA:                                                              |
PROMPT | https://www.akadia.com/services/ora_freelists.html                                          |
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT
ACCEPT owner_001       char PROMPT 'OWNER      = '
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
SET LINES 200
SET PAGES 200


select count(blockno) blockno_tot, sum(tot_lines) lines_tot,  trunc(sum(tot_lines)/  count(blockno)) avg_lines_block
from(
select dbms_rowid.rowid_block_number(rowid) blockno
,      count(*) tot_lines
from  &owner_001&ponto&table_name_002
group by dbms_rowid.rowid_block_number(rowid)
order by  2 desc)
/
select owner, table_name, freelists, pct_free, pct_used, chain_cnt
  from dba_tables
 where owner = '&owner_001'
 and table_name = '&table_name_002'
/
select 'alter table '||owner||'.'||table_name||' minimize records_per_block;' com
  from dba_tables
 where owner = '&owner_001'
 and table_name = '&table_name_002'
UNION ALL
select 'alter table '||owner||'.'||table_name||' move pctfree 50 pctused 30;' com
  from dba_tables
 where owner = '&owner_001'
 and table_name = '&table_name_002'
/
select 'alter index '||OWNER||'.'||INDEX_NAME||' rebuild pctfree 50;' com, PCT_FREE, status 
from dba_indexes 
where owner = '&owner_001'
and TABLE_NAME = '&table_name_002'
/
--select dbms_rowid.rowid_block_number(rowid) blockno
--,      count(*) tot_lines
--from  &owner_001&ponto&table_name_002
--group by dbms_rowid.rowid_block_number(rowid)
--order by  2 desc


