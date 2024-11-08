set pagesize 1000
select TO_CHAR(min(begin_time),'DD/MM/YYYY HH24:MI:SS') AS begin_time, TO_CHAR(max(end_time),'DD/MM/YYYY HH24:MI:SS') AS end_time,
sum(case metric_name when 'User Commits Per Sec' then average end) User_Commits_Per_Sec,
sum(case metric_name when 'User Rollbacks Per Sec' then average end) User_Rollbacks_Per_Sec,
sum(case metric_name when 'User Transaction Per Sec' then average end) User_Transactions_Per_Sec,
snap_id
from dba_hist_sysmetric_summary
where trunc(begin_time) > sysdate-7
group by snap_id
order by snap_id;
