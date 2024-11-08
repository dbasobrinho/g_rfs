-- |----------------------------------------------------------------------------|
-- | Objetivo   : Statisticas de Stale > 10%                                    |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 22/07/2019                                                    |
-- | Exemplo    : @stat_stale_table_and_lockstat_all.sql                        |
-- | Arquivo    : stat_stale_table_and_lockstat_all.sql                         |
-- |                                                                            |
-- +----------------------------------------------------------------------------+

accept V_STALE prompt "ENTRE COM A % PARA ESTATISTICA STALE [0 a 100] (DEFAULT: 10): "  DEFAULT  10
variable v_stale number

SET TERMOUT OFF;

COLUMN n_stale NEW_VALUE V0 NOPRINT;
select  decode('&&V_STALE','',10,to_number(nvl('&&V_STALE','10'))) as n_stale from  dual
/

COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
Exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;

COLUMN total_sub1 NEW_VALUE V1 NOPRINT;
select 'TABLE_STAT_NULL' T, count(1) total_sub1
from dba_tables t
where t.last_analyzed is null
and t.owner not in ('SYS', 'SYSTEM')
and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER = t.owner and j.TABLE_NAME = t.TABLE_NAME and  j.stattype_locked = 'ALL')  
and not exists (select 1 FROM dba_external_tables j where j.OWNER = t.owner and j.TABLE_NAME = t.TABLE_NAME) 
/	  

COLUMN maior_stale NEW_VALUE V2 NOPRINT;
COLUMN menor_stale NEW_VALUE V3 NOPRINT;
select 'TABLE_STAT_STALE' T,
  sum(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) >  NVL(&&v_stale,10) then 1 else 0 end) maior_stale,
sum(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) <=  NVL(&&v_stale,10) then 1 else 0 end) menor_stale
 from dba_tab_modifications m, dba_tables t
where m.table_owner = t.owner
  and m.table_name = t.table_name
  and m.table_owner not in ('SYS', 'SYSTEM')
 and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER = t.owner and j.TABLE_NAME = t.TABLE_NAME and  j.stattype_locked = 'ALL')  
 and not exists (select 1 FROM dba_external_tables j where j.OWNER = t.owner and j.TABLE_NAME = t.TABLE_NAME) 	  
/

COLUMN total_sub2 NEW_VALUE V4 NOPRINT;
select 'PART_STAT_NULL' T, count(1) total_sub2
from dba_tab_partitions t
where t.last_analyzed is null
and t.table_owner not in ('SYS', 'SYSTEM')
and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER = t.table_owner and j.TABLE_NAME = t.TABLE_NAME and  j.stattype_locked = 'ALL')  
and not exists (select 1 FROM dba_external_tables j where j.OWNER = t.table_owner and j.TABLE_NAME = t.TABLE_NAME) 
/	  

COLUMN maior_stale2 NEW_VALUE V5 NOPRINT;
COLUMN menor_stale2 NEW_VALUE V6 NOPRINT;
select 'PART_STAT_STALE' T,
  COUNT(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) >   NVL(&&v_stale,10) then 1 else NULL end) maior_stale2,
COUNT(case when (m.inserts+m.updates+m.deletes)*100/NULLIF(t.num_rows,0) <=  NVL(&&v_stale,10) then 1 else NULL end)   menor_stale2
 from dba_tab_modifications m, dba_tab_partitions t
where m.table_owner = t.table_owner
  and m.table_name = t.table_name
  and m.table_owner not in ('SYS', 'SYSTEM')
 and not exists (select 1 FROM dba_tab_statistics  j where j.OWNER = t.table_owner and j.TABLE_NAME = t.TABLE_NAME and  j.stattype_locked = 'ALL')  
  and not exists (select 1 FROM dba_external_tables j where j.OWNER = t.table_owner and j.TABLE_NAME = t.TABLE_NAME) 	  
/
COLUMN TOT_STAT_LOCKED NEW_VALUE V7 NOPRINT;
select COUNT(1) TOT_STAT_LOCKED      FROM dba_tab_statistics  j where j.OWNER not in ('SYS', 'SYSTEM') and  j.stattype_locked = 'ALL'
/
COLUMN TOT_EXTERNAL_TABLES NEW_VALUE V8 NOPRINT;
select COUNT(1) TOT_EXTERNAL_TABLES  FROM dba_external_tables j where j.OWNER not in ('SYS', 'SYSTEM')
/
COLUMN TOT NEW_VALUE T0 NOPRINT;
select &V1+&V2+&V3+&V4+&V5+&V6+&V7+&V8+&V8 TOT  FROM dual
/
COLUMN P1 NEW_VALUE P1 NOPRINT;
select '['||to_char((&V1*100)/(&T0),'FM999G999G999G999G900D00')||' %]' P1  FROM dual
/
COLUMN P2 NEW_VALUE P2 NOPRINT;
select '['||to_char((&V2*100)/(&T0),'FM999G999G999G999G900D00')||' %]' P2  FROM dual
/
COLUMN P3 NEW_VALUE P3 NOPRINT;
select '['||to_char((&V3*100)/(&T0),'FM999G999G999G999G900D00')||' %]' P3  FROM dual
/
COLUMN P4 NEW_VALUE P4 NOPRINT;
select '['||to_char((&V4*100)/(&T0),'FM999G999G999G999G900D00')||' %]' P4  FROM dual
/
COLUMN P5 NEW_VALUE P5 NOPRINT;
select '['||to_char((&V5*100)/(&T0),'FM999G999G999G999G900D00')||' %]' P5  FROM dual
/
COLUMN P6 NEW_VALUE P6 NOPRINT;
select '['||to_char((&V6*100)/(&T0),'FM999G999G999G999G900D00')||' %]' P6  FROM dual
/
COLUMN P7 NEW_VALUE P7 NOPRINT;
select '['||to_char((&V7*100)/(&T0),'FM999G999G999G999G900D00')||' %]' P7  FROM dual
/
COLUMN P8 NEW_VALUE P8 NOPRINT;
select '['||to_char((&V8*100)/(&T0),'FM999G999G999G999G900D00')||' %]' P8  FROM dual
/

SET TERMOUT ON;

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       10000
SET PAGES       10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Report Statistics Database                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT | PARAMETRO % STALE         : &V0                                 |
PROMPT +------------------------------------------------------------------------+
PROMPT | TABLE     STATS NULL      : &V1    &P1                    |
PROMPT | TABLE     STATS STALE     : &V2    &P2                    |
PROMPT | TABLE     STATS NO STALE  : &V3    &P3                    |
PROMPT | PARTITION STATS NULL      : &V4    &P4                    |
PROMPT | PARTITION STATS STALE     : &V5    &P5                    |
PROMPT | PARTITION STATS NO STALE  : &V6    &P6                    |
PROMPT | TABLE STATS LOCKED        : &V7    &P7                    |
PROMPT | TABLE EXTERNAL TABLES     : &V8    &P8                    |
PROMPT +------------------------------------------------------------------------+
PROMPT | TOTAL OBJETOS ANALISADOS : &T0                                  |
PROMPT +------------------------------------------------------------------------+         
PROMPT ..
UNDEF V_STALE
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 

