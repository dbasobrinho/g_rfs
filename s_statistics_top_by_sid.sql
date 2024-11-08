--sess_statistics_top_by_sid.sql
set pages 1000
set lines 1000
col username  format a25 

select s.sid,s.username,st.name,se.value
from v$session s, v$sesstat se, v$statname st
where s.sid=se.SID and se.STATISTIC#=st.STATISTIC# 
--and st.name ='CPU used by this session' 
and s.sid='&SID'
order by s.sid,se.value desc
/