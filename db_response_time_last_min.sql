--Last minute response time
select to_char(begin_time,'hh24:mi') time,  value "Response Time"
from v$sysmetric
where metric_name='SQL Service Response Time'
/
