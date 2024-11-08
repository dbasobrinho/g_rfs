set pages 1000
set lines 1000
COLUMN segment_type     FORMAT A15
COLUMN schema_size_gig  FORMAT 999999999
  
select 
   sum(bytes)/1024/1024/1024 as size_in_gig, 
   segment_type
from 
   dba_segments
where 
   owner= '&owner'
group by 
   segment_type
/   