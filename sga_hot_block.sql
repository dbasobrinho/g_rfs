-- Objetos com maior numero de blocos em memoria
-- excluindo objetos do SYS, SYSMAN, SYSTEM, DBSNMP
select y.owner
     , y.object_name
     , y.object_type
     , y.num_blks_mem
     , s.blocks tot_blk_obj
     , round(y.num_blks_mem / s.blocks*100,2) pct_obj_blks_in_mem
     , s.buffer_pool
     , case 
          when ( (y.num_blks_mem / s.blocks*100) > 0 ) then 'alter '||s.segment_type||' '||y.owner||'.'||s.segment_name||' cache storage (buffer_pool keep);'
          else 'Review the queries and the need to create indexes.'
       end as cmd
  from (select o.owner
             , o.object_name
             , o.object_type
             , count(distinct file# || block#) num_blks_mem
          from v$bh x
             , dba_objects o
         where x.objd = o.object_id
           and x.status != 'free'
           and o.owner not in ('SYS','SYSTEM','SYSMAN','DBSNMP')
         group by o.owner
             , o.object_name
             , o.object_type
        having count(distinct file# || block#) > 299
       ) y
       , dba_segments s
 where s.owner = y.owner
   and s.segment_name = y.object_name
   and s.segment_type = y.object_type
 order by y.num_blks_mem desc
/
   
 
/* 
select \*+ FIRST_ROWS(25) *\ e.owner || '.' || e.segment_name segment_name
     , e.extent_id extent#
     , x.dbablk - e.block_id + 1 block#
     , x.tch
     , l.child#
  from sys.v$latch_children l, sys.x$bh x, sys.dba_extents e
 where e.file_id = x.file#
   and x.hladdr = l.addr
   and x.dbablk between e.block_id and e.block_id + e.blocks - 1
   and e.owner not in ('SYS','SYSTEM')
 order by x.tch desc;
*/

-- HOT blocks dos objetos encontrados em memória
-- excluindo objetos do SYS, SYSMAN, SYSTEM, DBSNMP
/*select o.owner
     , o.object_name
     , o.object_type
     , x.block#
     , d.file_name
     , count(*) 
  from v$bh x
     , dba_data_files d
     , dba_objects o
 where x.file# = d.file_id
   and x.objd = o.object_id
   and o.owner not in ('SYS','SYSTEM','SYSMAN','DBSNMP')
 group by o.owner, o.object_name, o.object_type, x.block#, d.file_name
having count(*) > 1
 order by count(*) desc;*/
