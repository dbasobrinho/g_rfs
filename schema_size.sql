set pages 1000
set lines 1000
COLUMN owner            FORMAT A15
COLUMN schema_size_gig  FORMAT 999999999

select 
   owner,
   sum(bytes)/1024/1024/1024 schema_size_gig
from 
   dba_segments 
group by 
   owner
order by 1   
/