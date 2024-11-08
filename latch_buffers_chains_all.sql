col object_name for a35
col cnt for 99999

SELECT
  cnt, object_name, object_type,file#, dbablk, obj, tch, hladdr 
FROM (
  select count(*) cnt, rfile, block from (
    SELECT /*+ ORDERED USE_NL(l.x$ksuprlat) */ 
      --l.laddr, u.laddr, u.laddrx, u.laddrr,
      dbms_utility.data_block_address_file(to_number(object,'XXXXXXXX')) rfile,
      dbms_utility.data_block_address_block(to_number(object,'XXXXXXXX')) block
    FROM 
       (SELECT /*+ NO_MERGE */ 1 FROM DUAL CONNECT BY LEVEL <= 100000) s,
       (SELECT ksuprlnm LNAME, ksuprsid sid, ksuprlat laddr,
        TO_CHAR(ksulawhy,'XXXXXXXXXXXXXXXX') object
        FROM x$ksuprlat) l,
       (select  indx, kslednam from x$ksled ) e,
       (SELECT
                    indx
                  , ksusesqh     sqlhash
   , ksuseopc
   , ksusep1r laddr
             FROM x$ksuse) u
    WHERE LOWER(l.Lname) LIKE LOWER('%cache buffers chains%') 
     AND  u.laddr=l.laddr
     AND  u.ksuseopc=e.indx
     AND  e.kslednam like '%cache buffers chains%'
    )
   group by rfile, block
   ) objs, 
     x$bh bh,
     dba_objects o
WHERE 
      bh.file#=objs.rfile
 and  bh.dbablk=objs.block  
 and  o.object_id=bh.obj(+)
order by cnt
/


---   select * from (
---   with sq as (select object_name, data_object_id 
---                 from dba_objects where object_name like '%SPOKESMAN%')
---       ,bh as (select hladdr, obj, file#, dbablk, sum(tch) tch 
---                 from x$bh group by hladdr, obj, file#, dbablk)
---   select hladdr cbc_latch_addr
---         ,sum(tch) tch
---         ,listagg(tch || '-' || obj || '(' || object_name || ')/' || file# || '/' ||dbablk, ';') 
---            within group (order by tch desc) tch_list -- "tch-obj(name)/file/blk_list"
---         ,count(*) blk_cnt
---   from  bh, sq
---   where bh.obj = sq.data_object_id
---     and tch > 0
---     --and (hladdr like '%18B3DB828%' or hladdr like '%18B3BACA8')   
---   group by hladdr
---   order by tch desc)
---   where 1=1
---     and (tch_list = tch_list);
  

------      CNT|     RFILE|     BLOCK
------    ------|----------|----------
------       238|       172|    518888
------       
------    select bh.obj from x$bh bh where  bh.file# =   461 and bh.dbablk =   2411276 ;
------    
------    select * from dba_objects where object_id like '%429742%'    ,429743);
------    429742
