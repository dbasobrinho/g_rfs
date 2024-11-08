 --tablespace growth_report(USING SQLPLUS)
set linesize 120
column name format a15
column variance format a20
alter session set nls_date_format='yyyy-mm-dd';
with t as (
select ss.run_time,ts.name,round(su.tablespace_size*dt.block_size/1024/1024/1024,2) alloc_size_gb, round(su.tablespace_usedsize*dt.block_size/1024/1024/1024,2) used_size_gb
from
dba_hist_tbspc_space_usage su,
(select trunc(BEGIN_INTERVAL_TIME) run_time,max(snap_id) snap_id from dba_hist_snapshot
group by trunc(BEGIN_INTERVAL_TIME) ) ss,
v$tablespace ts,
dba_tablespaces dt
where su.snap_id = ss.snap_id
and su.tablespace_id = ts.ts#
AND dt.contents                not in ('UNDO', 'TEMPORARY')
and ts.name =ts.name
and ts.name = dt.tablespace_name )
select e.run_time,e.name,e.alloc_size_gb,e.used_size_gb curr_used_size_gb,b.used_size_gb prev_used_size_gb,
case when e.used_size_gb > b.used_size_gb then to_char(e.used_size_gb - b.used_size_gb)
when e.used_size_gb = b.used_size_gb then 'NO DATA GROWTH' when e.used_size_gb < b.used_size_gb then '***DATA PURGED' end variance
from t e, t b
where e.run_time = b.run_time +1
order by 2, 1
/