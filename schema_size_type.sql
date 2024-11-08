set pages 1000
set lines 1000
COLUMN owner            FORMAT A15
COLUMN segment_type     FORMAT A30
COLUMN schema_size_gig  FORMAT 999999999
 
  select
   owner,segment_type,
   sum(bytes)/1024/1024/1024 schema_size_gig
from
   dba_segments
group by
   owner, segment_type  
order by 1,2   
/