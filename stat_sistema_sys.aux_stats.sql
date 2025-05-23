--stat_sistema_verifica_que_valendo.sql
-- Verifica o que ta valendo
set echo off
set linesize 200 pagesize 1000
column pname format a30
column sname format a20
column pval2 format a20
select pname,pval2 from sys.aux_stats$ where sname='SYSSTATS_INFO';
prompt "-"
prompt "<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"
prompt "-"
select pname,pval1,calculated,formula from sys.aux_stats$ where sname='SYSSTATS_MAIN'
model
  reference sga on (
    select name,value from v$sga
        ) dimension by (name) measures(value)
  reference parameter on (
    select name,decode(type,3,to_number(value)) value from v$parameter where name='db_file_multiblock_read_count' and ismodified!='FALSE'
    union all
    select name,decode(type,3,to_number(value)) value from v$parameter where name='sessions'
    union all
    select name,decode(type,3,to_number(value)) value from v$parameter where name='db_block_size'
        ) dimension by (name) measures(value)
partition by (sname) dimension by (pname) measures (pval1,pval2,cast(null as number) as calculated,cast(null as varchar2(60)) as formula) rules(
  calculated['MBRC']=coalesce(pval1['MBRC'],parameter.value['db_file_multiblock_read_count'],parameter.value['_db_file_optimizer_read_count'],8),
  calculated['MREADTIM']=coalesce(pval1['MREADTIM'],pval1['IOSEEKTIM'] + (parameter.value['db_block_size'] * calculated['MBRC'] ) / pval1['IOTFRSPEED']),
  calculated['SREADTIM']=coalesce(pval1['SREADTIM'],pval1['IOSEEKTIM'] + parameter.value['db_block_size'] / pval1['IOTFRSPEED']),
  calculated['   multi block Cost per block']=round(1/calculated['MBRC']*calculated['MREADTIM']/calculated['SREADTIM'],4),
  calculated['   single block Cost per block']=1,
  formula['MBRC']=case when pval1['MBRC'] is not null then 'MBRC' when parameter.value['db_file_multiblock_read_count'] is not null then 'db_file_multiblock_read_count' when parameter.value['_db_file_optimizer_read_count'] is not null then '_db_file_optimizer_read_count' else '= _db_file_optimizer_read_count' end,
  formula['MREADTIM']=case when pval1['MREADTIM'] is null then '= IOSEEKTIM + db_block_size * MBRC / IOTFRSPEED' end,
  formula['SREADTIM']=case when pval1['SREADTIM'] is null then '= IOSEEKTIM + db_block_size        / IOTFRSPEED' end,
  formula['   multi block Cost per block']='= 1/MBRC * MREADTIM/SREADTIM',
  formula['   single block Cost per block']='by definition',
  calculated['   maximum mbrc']=sga.value['Database Buffers']/(parameter.value['db_block_size']*parameter.value['sessions']),
  formula['   maximum mbrc']='= buffer cache size in blocks / sessions'
);
set echo on