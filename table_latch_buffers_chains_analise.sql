 
O evento de espera "latch: cache buffers chains" ocorre quando há acesso extremamente alto e simultâneo ao mesmo bloco em um banco de dados. 
O acesso a um bloco normalmente é uma operação rápida, mas se os usuários simultâneos acessarem um bloco rápido o suficiente, repetidamente, o acesso simples ao bloco pode se tornar um gargalo. 
A ocorrência mais comum de contenção de trava cbc (cache buffer chains) ocorre quando vários usuários estão executando junções nest loop joins em uma tabela e acessando a tabela conduzida por meio de um índice. Uma vez que a junção NL é basicamente um

  Para todas as linhas em i
     procure um valor em j onde j.field1 = i.val
  laço final

então, o índice da tabela j no campo 1 será atingido para cada linha retornada de i. 
Agora, se a pesquisa em i retornar muitas linhas e se vários usuários estiverem executando a mesma consulta, o bloco raiz do índice será martelado no índice j (campo1).

Para resolver um afunilamento de trava CBC, precisamos saber qual SQL está causando o afunilamento e qual tabela ou índice que a instrução SQL está usando está causando o afunilamento.

------------------------------------------------------------------------------------------------------------
select /*+ PARALLEL(ash,15) */
      count(*), 
      sql_id, 
      nvl(o.object_name,ash.current_obj#) objn,
      substr(o.object_type,0,10) otype,
      CURRENT_FILE# CURRENT_FILE,
      CURRENT_BLOCK# blockn
from  v$active_session_history ash
    , dba_objects o
where event like 'latch: cache buffers chains'
  and o.object_id (+)= ash.CURRENT_OBJ#
  and sample_time  between
			   to_date('10/03/2021 09:30','dd/mm/yyyy hh24:mi') and
			   to_date('10/03/2021 10:00','dd/mm/yyyy hh24:mi')
group by sql_id, current_obj#, current_file#, current_block#, o.object_name,o.object_type
order by count(*)
/ 
------------------------------------------------------------------------------------------------------------ 
select /*+ PARALLEL(ash,15) */
      count(*), 
      sql_id, 
      nvl(o.object_name,ash.current_obj#) objn,
      substr(o.object_type,0,10) otype,
      CURRENT_FILE# CURRENT_FILE,
      CURRENT_BLOCK# blockn
from  dba_hist_active_sess_history  ash
    , dba_objects o
where event like 'latch: cache buffers chains'
  and o.object_id (+)= ash.CURRENT_OBJ#
  and sample_time  between
			   to_date('10/03/2021 09:30','dd/mm/yyyy hh24:mi') and
			   to_date('10/03/2021 10:00','dd/mm/yyyy hh24:mi')
group by sql_id, current_obj#, current_file#, current_block#, o.object_name,o.object_type
order by count(*)
/ 




------------------------------------------------------------------------------------------------------------
P1 é o endereço da trava para a espera da trava cbc. 
Agora podemos agrupar as esperas de trava CBC pelo endereço e descobrir qual endereço teve mais esperas:
------------------------------------------------------------------------------------------------------------
select /*+ PARALLEL(ash,15) */
    count(*), sql_id sqlid,  to_char(sample_time,'yyyymmddhh24') as sample_time_hh24,
    lpad(replace(to_char(p1,'XXXXXXXXXXXX'),' ','0'),16,0) laddr
from  dba_hist_active_sess_history   ash
    , dba_objects o
where event like 'latch: cache buffers chains'
  and o.object_id (+)= ash.CURRENT_OBJ#
  and sample_time  between
			   to_date('09/03/2021 06:00','dd/mm/yyyy hh24:mi') and
			   to_date('09/03/2021 18:50','dd/mm/yyyy hh24:mi')
group by P1 , sql_id, to_char(sample_time,'yyyymmddhh24')
order by 3,count(*)
/

--SO VALE SE FORA NA HORA, PORQUE O ENDEREÇO É LIBERADO APOS A EXECUÇÃO
WITH GUINA AS (
select /*+ PARALLEL(ash,15) */
    count(*), sql_id sqlid,  --,to_char(p1),
    lpad(replace(to_char(p1,'XXXXXXXXXXXX'),' ','0'),16,0) laddr
from  v$active_session_history   ash
    , dba_objects o
where event like 'latch: cache buffers chains'
  and o.object_id (+)= ash.CURRENT_OBJ#
  and sample_time  between
			   to_date('10/03/2021 09:30','dd/mm/yyyy hh24:mi') and
			   to_date('10/03/2021 10:00','dd/mm/yyyy hh24:mi')
group by P1 , sql_id  --, current_obj#, current_file#, current_block#, o.object_name,o.object_type
order by count(*)
)
select o.name, o.TYPE#, bh.dbarfil, bh.dbablk, bh.tch, g.*
from x$bh bh, obj$ o, guina g
where tch > 4
  and hladdr=g.laddr
  and o.obj#=bh.obj
order by tch
/
NAME                          |     TYPE#|   DBARFIL|    DBABLK|       TCH|  COUNT(*)|SQLID        |LADDR
------------------------------|----------|----------|----------|----------|----------|-------------|----------------
CT_CONTRACT_PARAMETER         |         2|       172|    166229|        43|         1|1cqnd1qjk0gan|0000001B33B73E08

@hot_block_latch_buffers_chains.sql

OWNER          |OBJECT_NAME                   |OBJECT_TYPE        |       TCH|       OBJ|     FILE#|    DBABLK|CLASS             |STATE
---------------|------------------------------|-------------------|----------|----------|----------|----------|------------------|-------
SYSCT          |CT_CONTRACT_PARAMETER         |TABLE              |        51|     54234|       172|    166229|data block        |scur
SYSCS          |CS_CUSTOMER                   |TABLE              |        45|    284542|       187|   1802964|data block        |scur
SYSRQ          |RQ_REQUEST                    |TABLE              |        10|    352253|       302|    232590|data block        |scur
SYSAD          |IX_FK_AD_USER__R_AI_SYSTE     |INDEX              |         5|    609030|       723|   4164128|data block        |scur
SYSCT          |IDX$$_E92630001               |INDEX              |         3|    448854|       172|   1149036|data block        |scur
SYSRQ          |RQ_REQUEST                    |TABLE              |         2|    352253|       370|   3047905|data block        |scur
SYSFC          |FC_INVOICE                    |TABLE              |         1|    352252|       332|   4099057|data block        |scur
SYSTX          |IX_CNS_TX_CONF_TRS_01_20      |INDEX              |         1|    699129|      1179|    757718|data block        |scur
SYSAC          |IDX_AC_CUST_MOV_20_03         |INDEX              |         1|    699086|       454|    230030|data block        |scur
SYSAD          |IX_FK_AD_USER__R_AI_SYSTE     |INDEX              |         0|    609030|       723|   4164128|data block        |free


------------------------------------------------------------------------------------------------------------
Procuramos o bloco com o maior "TCH" ou "touch counT". A contagem de toques é uma contagem de vezes que o bloco foi acessado. 
A contagem tem algumas restrições. A contagem é incrementada apenas uma vez a cada 3 segundos, então mesmo se eu acessar o bloco 1 milhão de vezes por segundo, a contagem aumentará apenas uma vez a cada 3 segundos. Além disso, e infelizmente, a contagem é zerada se o bloco percorrer o cache do buffer, mas provavelmente o mais lamentável é que essa análise só funciona quando o problema está acontecendo. Assim que o problema terminar, os blocos geralmente serão empurrados para fora do cache do buffer.

No caso em que a contenção de trava CBC está acontecendo agora, podemos executar toda essa análise em uma consulta


select name, file#, dbablk, obj, tch, hladdr 
from x$bh bh
    , obj$ o
 where 
       o.obj#(+)=bh.obj and hladdr in 
(
    select ltrim(to_char(p1,'XXXXXXXXXXXX') )
    from v$active_session_history 
    where event like 'latch: cache buffers chains'
    group by p1 
    having count(*) > 1
)
   and tch > 1
order by tch   


------------------------------------------------------------------------------------------------------------
Análise mais profunda do Tanel Poder
http://blog.tanelpoder.com/2009/08/27/latch-cache-buffers-chains-latch-contention-a-better-way-for-finding-the-hot-block/comment-page-1/
Usando as ideias de Tanel, aqui está um script para obter os objetos que temos mais espera da trava cbc

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
       (SELECT indx , ksusesqh     sqlhash
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
 and  o.object_id=bh.obj
order by cnt
/











COLUMN owner FORMAT A15
COLUMN object_name FORMAT A30
COLUMN subobject_name FORMAT A20

SELECT *
FROM   (SELECT o.owner,
               o.object_name,
               o.subobject_name,
               o.object_type,
               bh.tch,
               bh.obj,
               bh.file#,
               bh.dbablk,
               DECODE(bh.class,1,'data block',
                               2,'sort block',
                               3,'save undo block',
                               4,'segment header',
                               5,'save undo header',
                               6,'free list',
                               7,'extent map',
                               8,'1st level bmb',
                               9,'2nd level bmb',
                               10,'3rd level bmb',
                               11,'bitmap block',
                               12,'bitmap index block',
                               13,'file header block',
                               14,'unused',
                               15,'system undo header',
                               16,'system undo block',
                               17,'undo header',
                               18,'undo block') AS class,
               DECODE(bh.state, 0,'free',
                                1,'xcur',
                                2,'scur',
                                3,'cr',
                                4,'read',
                                5,'mrec',
                                6,'irec',
                                7,'write',
                                8,'pi',
                                9,'memory',
                                10,'mwrite',
                                11,'donated') AS state
        FROM   x$bh bh,
               dba_objects o
        WHERE  o.data_object_id = bh.obj
        AND    hladdr = '&address'
        ORDER BY tch DESC)
WHERE  rownum < 500
/




116621796624

há algunsndereço que aguardamos, então agora podemos ver quais blocos (cabeçalhos, na verdade) estavam naquele endereço

select o.name, bh.dbarfil, bh.dbablk, bh.tch
from x$bh bh, obj$ o
where tch > 5
  and hladdr ='0000116866552400'
  and o.obj#=bh.obj
order by tch
/



PROMPT 
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT | LATCH: CACHE BUFFERS CHAINS TABLE                                                           |
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT | alter table [OWNER].[TABLE_NAME] move pctfree 50 pctused 30 storage (freelists 2);          |
PROMPT | alter table [OWNER].[TABLE_NAME] minimize records_per_block;                                |
PROMPT | alter index [OWNER].[INDEX_NAME] rebuild pctfree 50 storage (freelists 2);                  |
PROMPT | http://toolkit.rdbms-insight.com/latch.php                                                  |
PROMPT | SE FOR USAR O FREELISTS, LEIA:                                                              |
PROMPT | https://www.akadia.com/services/ora_freelists.html                                          |
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT +---------------------------------------------------------------------------------------------+
PROMPT
ACCEPT owner_001       char PROMPT 'OWNER      = '
ACCEPT table_name_002  char PROMPT 'TABLE_NAME = '
DEFINE ponto    = '.' (CHAR)
PROMPT
COL owner                FOR A10;
COL table_name           FOR A30;
COL pct_free             FOR 999;
COL pct_used             FOR 999;
COL chain_cnt            FOR 999999;
COL com                  FOR A100;
COL status               FOR A10;
COL blockno              FOR 99999999;
COL tot_lines            FOR 999999;
COL blockno_tot          FOR 999999999;
COL lines_tot            FOR 999999999;
COL avg_lines_block      FOR 999999999;
SET LINES 200
SET PAGES 200


select count(blockno) blockno_tot, sum(tot_lines) lines_tot,  trunc(sum(tot_lines)/  count(blockno)) avg_lines_block
from(
select dbms_rowid.rowid_block_number(rowid) blockno
,      count(*) tot_lines
from  &owner_001&ponto&table_name_002
group by dbms_rowid.rowid_block_number(rowid)
order by  2 desc)
/
select owner, table_name, freelists, pct_free, pct_used, chain_cnt
  from dba_tables
 where owner = '&owner_001'
 and table_name = '&table_name_002'
/
select 'alter table '||owner||'.'||table_name||' minimize records_per_block;' com
  from dba_tables
 where owner = '&owner_001'
 and table_name = '&table_name_002'
UNION ALL
select 'alter table '||owner||'.'||table_name||' move pctfree 50 pctused 30;' com
  from dba_tables
 where owner = '&owner_001'
 and table_name = '&table_name_002'
/
select 'alter index '||OWNER||'.'||INDEX_NAME||' rebuild pctfree 50;' com, PCT_FREE, status 
from dba_indexes 
where owner = '&owner_001'
and TABLE_NAME = '&table_name_002'
/
--select dbms_rowid.rowid_block_number(rowid) blockno
--,      count(*) tot_lines
--from  &owner_001&ponto&table_name_002
--group by dbms_rowid.rowid_block_number(rowid)
--order by  2 desc



+------------------------------------------------------------------------+
| Report   : Active Sessions Oracle              +-+-+-+-+-+-+-+-+-+-+   |
| Instance : pback1                              |r|f|s|o|b|r|i|n|h|o|   |
| Version  : 2.2                                 +-+-+-+-+-+-+-+-+-+-+   |
+------------------------------------------------------------------------+

SID/SERIAL@I   |SLAVE/W_CLASS   |OPID|SOPID   |USERNAME  |OSUSER    |PROGRAM   |MACHINE            |LOGON_TIME   |CALL_ET|SESSIONWAIT             |SQL_ID/CHILD   |HOLD  |WAIT  |MODULE
---------------|----------------|----|--------|----------|----------|----------|-------------------|-------------|-------|------------------------|---------------|------|------|--------
1686,42799,@1  |* User I/O      |814 |5417    |FPS_BOB   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVWEBSP37 |0903:1003[P] |0      |db file sequential read |0cjdfwru3n9vt 0|,     |0     |
2644,63531,@1  |* Cluster       |726 |20289   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |0dzc63akq87s1 0|,     |0     |[JDBC ]
1200,7201,@1   |* Other         |298 |12046   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:1221[P] |8      |message from client     |0nwyd7hb40s8q 0|,     |0     |
264,8631,@1    |* Other         |578 |14004   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP10 |0903:1158[P] |2      |message from client     |0nwyd7hb40s8q 0|,     |0     |
494,53629,@1   |* Other         |644 |13191   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1223[P] |1      |message from client     |0rrxfgcxhanwu 0|,     |0     |
3123,63479,@1  |* Other         |826 |24233   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP06 |0803:1640[P] |71304  |db file sequential read |2j9fjdpwt9crb 0|,     |0     |
3345,38535,@1  |* User I/O      |124 |28480   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP22 |0903:1208[P] |11     |db file sequential read |2j9fjdpwt9crb 1|,     |0     |
2370,58733,@1  |* User I/O      |404 |18592   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP24 |0803:1608[P] |72503  |read by other session   |2j9fjdpwt9crb 0|,     |0     |
3346,36405,@1  |* User I/O      |860 |11616   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP10 |0903:1248[P] |8      |message from client     |2mcvffvm8uzsr 0|,     |0     |
528,50743,@1   |* User I/O      |868 |9103    |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP06 |0903:1246[P] |71     |db file sequential read |2tbtn5qt8g16s 1|,     |0     |
1443,62527,@1  |* Cluster       |588 |20248   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |2w3t09thhywvn 0|,     |0     |[JDBC ]
176,27709,@1   |* Cluster       |705 |20277   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |36dav9bh8vp1d 0|,     |0     |[JDBC ]
3102,45423,@1  |* User I/O      |922 |8234    |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP02 |0903:1219[P] |2      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
2025,12155,@1  |* User I/O      |785 |10106   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP06 |0903:1247[P] |0      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
3441,101,@1    |* User I/O      |925 |10115   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP06 |0903:1247[P] |1      |db file sequential read |3f4h2y7dc9x8q 1|,     |0     |
1829,28179,@1  |* User I/O      |271 |3460    |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP09 |0903:1241[P] |0      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
2650,58641,@1  |* User I/O      |822 |18059   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP12 |0903:1227[P] |0      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
2397,57671,@1  |* User I/O      |852 |880     |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVWEBSP22 |0903:1240[P] |0      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
242,34227,@1   |* User I/O      |674 |813     |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVWEBSP22 |0903:1240[P] |0      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
3556,58657,@1  |* User I/O      |382 |10761   |FPS_BOB   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP06 |0903:1247[P] |66     |direct path write temp  |4s9t42ybqnm1j 0|,     |0     |
2404,20861,@1  |* User I/O      |660 |4353    |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP01 |0903:1242[P] |0      |message from client     |5mx4y35grmcpa 0|,     |0     |
1914,26873,@1  |* User I/O      |496 |17706   |FPS_BOB   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVWEBSP37 |0903:1226[P] |0      |db file sequential read |63tp4bwsf8zy1 1|,     |0     |
843,8291,@1    |* Cluster       |263 |23721   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1807[P] |6      |message from client     |7jy6ck9xdq9sr 0|,     |0     |[JDBC ]
2967,21503,@1  |* User I/O      |185 |4485    |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP12 |0903:1242[P] |0      |message from client     |8hxhavmmcpc2r 1|,     |0     |
2503,54805,@1  |* User I/O      |661 |12519   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVWEBSP23 |0903:1249[P] |0      |message from client     |8hxhavmmcpc2r 1|,     |0     |
1466,15801,@1  |* Concurrency   |652 |20263   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
1696,10853,@1  |* Concurrency   |366 |19708   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1803[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
147,17869,@1   |* Cluster       |737 |20297   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
600,20637,@1   |* Cluster       |773 |20313   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
2165,1645,@1   |* Cluster       |786 |10845   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1823[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
2504,44843,@1  |* Other         |405 |29786   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP07 |0903:1116[P] |3452   |db file sequential read |acbc0tdz0n3hb 0|,     |0     |
2854,1889,@1   |* Other         |664 |14757   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP07 |0903:0818[P] |15211  |latch free              |acbc0tdz0n3hb 0|,     |0     |
1118,45827,@1  |* Other         |809 |31168   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP24 |0903:1211[P] |0      |message from client     |adnjt8mhd9m00 0|,     |0     |
3442,37531,@1  |* User I/O      |317 |10330   |FPS_URA   |svc_fvs_pr|Fidelity.U|FNIS-BR\SRVWEBSP03 |0903:1247[P] |2      |message from client     |b854u2rfn8n5p 0|,     |0     |
1812,7683,@1   |* Other         |975 |17817   |FPS_URA   |svc_fvs_pr|Fidelity.U|FNIS-BR\SRVWEBSP07 |0903:1227[P] |2      |db file sequential read |b854u2rfn8n5p 0|,     |0     |
2742,60708,@1  |* Concurrency   |375 |3773    |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP05 |0903:1148[P] |2966   |latch: row cache objects|bks0k29us2byh 0|,     |0     |
1900,26381,@1  |* Other         |432 |13721   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1157[P] |2700   |latch: row cache objects|bks0k29us2byh 0|,     |0     |
1796,42083,@1  |* Other         |815 |4972    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP02 |0903:1243[P] |0      |message from client     |brd7cvpx0sd2c 0|,     |0     |
1801,57357,@1  |* Other         |879 |10125   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP06 |0903:1247[P] |0      |message from client     |brd7cvpx0sd2c 0|,     |0     |
2378,48337,@1  |* Other         |532 |9451    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP12 |0903:1246[P] |0      |message from client     |brd7cvpx0sd2c 0|,     |0     |
15,50763,@1    |* Other         |768 |25681   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP04 |0903:1232[P] |1      |message from client     |ca03nxyk0qtqv 0|,     |0     |
2018,36509,@1  |* Other         |177 |29106   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1209[P] |587    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2047,48715,@1  |* Other         |49  |29096   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1209[P] |2326   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
517,38447,@1   |* Concurrency   |292 |29112   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1209[P] |2358   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2280,38039,@1  |* Concurrency   |403 |10218   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1155[P] |2629   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
974,11597,@1   |* Concurrency   |72  |31695   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1118[P] |2858   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
3557,201,@1    |* Other         |670 |25058   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP02 |0903:1232[P] |405    |latch free              |crwvjbp7s8zat 0|,     |0     |
1358,21273,@1  |* Other         |491 |12087   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP03 |0903:1101[P] |2850   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
3565,46903,@1  |* Other         |798 |4403    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP06 |0903:1149[P] |2358   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
1926,34503,@1  |* Concurrency   |528 |24833   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP06 |0903:1204[P] |2506   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
620,31481,@1   |* Concurrency   |805 |4409    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP06 |0903:1149[P] |2660   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
18,8673,@1     |* Concurrency   |896 |24865   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:1204[P] |2692   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
960,53563,@1   |* Concurrency   |104 |5708    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:1150[P] |2818   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2855,34509,@1  |* Concurrency   |536 |21530   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1201[P] |2781   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
990,24345,@1   |* Concurrency   |392 |9585    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP22 |0903:1154[P] |2503   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
3100,15195,@1  |* Concurrency   |506 |30048   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP22 |0903:1116[P] |2508   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2256,32261,@1  |* Other         |819 |31285   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1238[P] |468    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2959,15225,@1  |* Other         |825 |31287   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1238[P] |530    |latch free              |crwvjbp7s8zat 0|,     |0     |
2865,14857,@1  |* Concurrency   |216 |20988   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1200[P] |2599   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2247,51241,@1  |* Concurrency   |243 |20994   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1200[P] |2751   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
855,2285,@1    |* Other         |295 |31106   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP24 |0903:1211[P] |437    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
1907,15849,@1  |* Other         |208 |6833    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP24 |0903:1151[P] |2604   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2526,38279,@1  |* User I/O      |757 |25673   |FPS_BOU   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP03 |0903:1232[P] |0      |message from client     |cyc077uy10ka3 1|,     |0     |
2269,5677,@1   |* Cluster       |467 |20232   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |d0qnat65pg6kh 0|,     |0     |[JDBC ]
3701,8641,@1   |* User I/O      |287 |8975    |FPS_RP    |root      |JDBC Thin |lnxwassp08.fnis-br.|0903:1246[NP]|244    |db file scattered read  |dxt424svrsacu 0|,     |0     |[JDBC ]
757,58345,@1   |* Other         |614 |25678   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:1114[P] |16     |db file sequential read |f36knvx60mmud 0|,     |0     |
3568,9013,@1   |* User I/O      |830 |10113   |FPS_BOB   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVWEBSP37 |0903:0814[P] |0      |message from client     |fs6wkwtqkpuzp 0|,     |0     |
761,35087,@1   |* Other         |966 |4416    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP24 |0903:1242[P] |0      |message from client     |fxf4d944f9tmm 0|,     |0     |
3667,65291,@1  |* Commit        |735 |26976   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:1234[P] |0      |message from client     |               |,     |0     |
833,59057,@1   |* Network       |103 |10326   |FPS_URA   |svc_fvs_pr|Fidelity.U|FNIS-BR\SRVWEBSP03 |0903:1247[P] |4      |message from client     |               |,     |0     |
1937,5311,@1   |* Commit        |784 |17763   |FPS_BOB   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVWEBSP37 |0903:1227[P] |0      |db file sequential read |               |,     |0     |
524,64459,@1   |* Other         |612 |17606   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1802[P] |0      |message from client     |               |,     |0     |[JDBC ]
368,9963,@1    |* Commit        |611 |17604   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1802[P] |0      |message from client     |               |,     |0     |[JDBC ]
22,44641,@1    |* Other         |608 |20251   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |               |,     |0     |[JDBC ]
157,32217,@1   |* Other         |129 |23717   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1807[P] |0      |message from client     |               |,     |0     |[JDBC ]
1569,44697,@1  |* Commit        |493 |24147   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1808[P] |0      |message from client     |               |,     |0     |[JDBC ]
1185,47003,@1  |* Other         |138 |24136   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1808[P] |0      |message from client     |               |,     |0     |[JDBC ]
1679,39427,@1  |* User I/O      |782 |5935    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP05 |0903:1217[P] |1      |message from client     |1b7pha6xxb17a 2|,     |1     |
3309,59867,@1  |* Concurrency   |988 |13958   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1224[P] |660    |latch: row cache objects|bks0k29us2byh 0|,     |1     |
412,26145,@1   |* Concurrency   |195 |25083   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1139[P] |1877   |latch: row cache objects|bks0k29us2byh 0|,     |1     |
1449,52483,@1  |* Concurrency   |428 |30975   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:1237[P] |372    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |1     |
2614,5901,@1   |* Other         |598 |24158   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1808[P] |1      |message from client     |               |,     |1     |[JDBC ]
3191,30435,@1  |* Other         |603 |24160   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1808[P] |1      |message from client     |               |,     |1     |[JDBC ]
637,61571,@1   |* Other         |389 |29782   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP07 |0903:1116[P] |5159   |latch free              |acbc0tdz0n3hb 0|,     |8     |
1462,55269,@1  |* User I/O      |108 |14759   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP07 |0903:0818[P] |15810  |db file sequential read |acbc0tdz0n3hb 0|,     |12    |
1192,48503,@1  |* Network       |618 |20257   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |217    |more data to client     |gc9vrsht5790r 0|,     |140   |[JDBC ]
1824,54775,@2  |* User I/O      |207 |30615   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP12 |0903:1150[P] |0      |message from client     |04bf44gkcmnx5 0|,     |0     |
637,23283,@2   |* User I/O      |421 |17467   |FPS_CM    |svc_fvs_pr|BatchExecu|FNIS-BR\SRVWEBSP04 |0903:1236[NP]|836    |db file sequential read |1j7r86r7makb5 0|,     |0     |[BATCH]
1318,27759,@2  |* User I/O      |75  |22637   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP12 |0903:1211[P] |67     |db file sequential read |1p06232rwy3xb 1|,     |0     |
1555,51915,@2  |* User I/O      |749 |13916   |FPS_BOB   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP05 |0903:1232[P] |390    |db file sequential read |27nyrsf9zqaaz 0|,     |0     |
7,26859,@2     |* User I/O      |256 |19594   |FPS_BOB   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP03 |0903:1141[P] |651    |db file sequential read |29vg7tfab7u8f 0|,     |0     |
3567,40705,@2  |* User I/O      |350 |2414    |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP06 |0803:1623[P] |72055  |db file sequential read |2j9fjdpwt9crb 0|,     |0     |
3439,65385,@2  |* Cluster       |701 |18563   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP03 |0903:1114[P] |0      |db file sequential read |3f4h2y7dc9x8q 1|,     |0     |
1695,60371,@2  |* Cluster       |878 |1083    |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP07 |0903:1248[P] |0      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
3088,58365,@2  |* User I/O      |890 |18401   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP10 |0903:1140[P] |1      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
25,16561,@2    |* User I/O      |96  |27110   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP12 |0903:1242[P] |1      |message from client     |3f4h2y7dc9x8q 1|,     |0     |
2501,43021,@2  |* User I/O      |917 |28143   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVWEBSP22 |0903:1216[P] |1      |db file sequential read |3f4h2y7dc9x8q 1|,     |0     |
514,24045,@2   |* User I/O      |68  |18775   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVWEBSP24 |0903:1237[P] |1      |db file sequential read |3f4h2y7dc9x8q 1|,     |0     |
2745,64789,@2  |* User I/O      |215 |18109   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP02 |0903:1236[P] |0      |message from client     |8hxhavmmcpc2r 1|,     |0     |
1434,47281,@2  |* User I/O      |876 |2471    |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP03 |0903:1222[P] |0      |message from client     |8hxhavmmcpc2r 1|,     |0     |
765,24767,@2   |* User I/O      |262 |27098   |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP12 |0903:1242[P] |0      |message from client     |8hxhavmmcpc2r 1|,     |0     |
2020,12309,@2  |* User I/O      |401 |7261    |FPS_BOP   |SVC_FVS_PR|w3wp.exe  |FNIS-BR\SRVALESP12 |0903:1227[P] |0      |message from client     |8hxhavmmcpc2r 1|,     |0     |
1927,14371,@2  |* Cluster       |368 |31308   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1808[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
148,19,@2      |* Cluster       |513 |26244   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1803[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
3684,25741,@2  |* Cluster       |767 |27730   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1826[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
2512,54203,@2  |* Cluster       |661 |30307   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1807[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
980,25453,@2   |* Cluster       |424 |25232   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1803[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
2027,10503,@2  |* Cluster       |721 |30314   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1807[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
1800,93,@2     |* Cluster       |527 |25463   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1803[P] |0      |gc buffer busy release  |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
3458,4315,@2   |* Cluster       |541 |31312   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1808[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
2891,37527,@2  |* Cluster       |600 |23764   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1823[P] |0      |message from client     |96wqrgnx8qm3y 0|,     |0     |[JDBC ]
2889,28137,@2  |* User I/O      |536 |1881    |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1221[P] |68     |db file sequential read |a8hjkvv7jkw1h 1|,     |0     |
532,8067,@2    |* User I/O      |260 |3570    |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP24 |0903:1223[P] |33     |db file sequential read |a8hjkvv7jkw1h 1|,     |0     |
1819,28621,@2  |* Concurrency   |143 |20461   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1239[P] |78     |latch: row cache objects|bks0k29us2byh 0|,     |0     |
150,63933,@2   |* Concurrency   |961 |21044   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1210[P] |1435   |latch: row cache objects|bks0k29us2byh 0|,     |0     |
3007,52119,@2  |* Concurrency   |89  |15760   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1139[P] |3304   |latch: row cache objects|bks0k29us2byh 0|,     |0     |
950,48323,@2   |* Other         |808 |21418   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1240[P] |505    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
1671,59597,@2  |* Concurrency   |430 |12456   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP02 |0903:1201[P] |2813   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2030,27783,@2  |* Concurrency   |625 |12464   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP02 |0903:1201[NP]|2894   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
3721,40295,@2  |* Concurrency   |447 |3887    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP02 |0903:1129[P] |2907   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
1096,18663,@2  |* Concurrency   |233 |21377   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:1116[P] |2720   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
152,55057,@2   |* Concurrency   |673 |2270    |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP11 |0903:1222[P] |625    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
2521,45639,@2  |* Concurrency   |117 |11030   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP11 |0903:1134[P] |2781   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
3340,44837,@2  |* Concurrency   |700 |19538   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP12 |0903:1238[P] |535    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
1236,42555,@2  |* Concurrency   |970 |21658   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP22 |0903:1210[P] |2295   |latch free              |crwvjbp7s8zat 0|,     |0     |
1110,29937,@2  |* Concurrency   |201 |11296   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1200[P] |2862   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |0     |
3368,17231,@2  |* User I/O      |604 |24925   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP22 |0903:1051[P] |0      |db file sequential read |cycsw3y3wznc8 0|,     |0     |
2131,50805,@2  |* User I/O      |754 |678     |FPS_BOU   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP07 |0903:1247[P] |0      |message from client     |cz02gawc9bq0h 0|,     |0     |
1598,1585,@2   |* Cluster       |717 |23600   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1802[P] |0      |message from client     |d0qnat65pg6kh 0|,     |0     |[JDBC ]
3447,12215,@2  |* Cluster       |573 |31314   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1808[P] |0      |message from client     |d0qnat65pg6kh 0|,     |0     |[JDBC ]
3553,69,@2     |* Cluster       |606 |31316   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1808[P] |0      |message from client     |d0qnat65pg6kh 0|,     |0     |[JDBC ]
383,17,@2      |* Cluster       |835 |26753   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1804[P] |0      |message from client     |d0qnat65pg6kh 0|,     |0     |[JDBC ]
1689,35371,@2  |* Cluster       |782 |27750   |FPS_RC    |jboss     |JDBC Thin |localhost          |0503:1826[P] |0      |message from client     |d0qnat65pg6kh 0|,     |0     |[JDBC ]
282,17095,@2   |* User I/O      |866 |1181    |FPS_BOB   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVWEBSP37 |0903:1003[P] |0      |log file sync           |dns9pjmad9mkp 0|,     |0     |
2134,20419,@2  |* User I/O      |338 |6591    |FPS_BOB   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVWEBSP37 |0903:0625[P] |0      |gc current request      |dns9pjmad9mkp 0|,     |0     |
49,36241,@2    |* User I/O      |960 |22790   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP22 |0903:1240[P] |0      |message from client     |dzn42cuyndbd1 0|,     |0     |
134,36375,@2   |* Cluster       |865 |1168    |FPS_BOB   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVWEBSP37 |0903:1003[P] |489    |gc cr request           |f8xbhdf5d9pyp 0|,     |0     |
245,10651,@2   |* Cluster       |418 |27408   |FPS_BOB   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP07 |0903:1147[P] |2899   |db file sequential read |fcmuhuu8vxydc 0|,     |0     |
3709,15647,@2  |* Commit        |671 |18480   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP11 |0903:1237[P] |0      |message from client     |               |,     |0     |
392,50981,@2   |* Other         |515 |1879    |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1221[P] |1477   |db file sequential read |2j9fjdpwt9crb 1|,     |1     |
2852,1639,@2   |* Network       |760 |1894    |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP12 |0903:1221[P] |1      |gc cr request           |a8hjkvv7jkw1h 1|,     |1     |
755,1991,@2    |* Concurrency   |230 |18225   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1140[P] |2539   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |1     |
1217,3071,@2   |* Other         |522 |12462   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP02 |0903:1201[P] |2813   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |1     |
963,36085,@2   |* Concurrency   |328 |31959   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP03 |0903:1152[P] |2776   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |1     |
1893,22815,@2  |* Concurrency   |848 |15786   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP06 |0903:1204[P] |2540   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |1     |
1104,21991,@2  |* Other         |361 |28793   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1122[P] |2326   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |1     |
249,33731,@2   |* User I/O      |66  |6189    |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:0941[P] |42     |latch free              |f36knvx60mmud 0|,     |1     |
366,55919,@2   |* Other         |291 |21429   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1240[P] |284    |latch free              |2z1xq868wcym1 0|,     |2     |
1908,12839,@2  |* Cluster       |880 |31684   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP11 |0903:1246[P] |103    |gc cr request           |5v3kjsh9um6fn 0|,     |2     |
758,43537,@2   |* Concurrency   |582 |20475   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP03 |0903:1239[P] |567    |latch free              |crwvjbp7s8zat 0|,     |2     |
2062,38705,@2  |* Concurrency   |849 |18171   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP03 |0903:1207[P] |592    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |2     |
2172,62713,@2  |* Concurrency   |242 |631     |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP07 |0903:1126[P] |4421   |latch: cache buffers cha|acbc0tdz0n3hb 0|,     |3     |
858,29139,@2   |* Concurrency   |135 |13466   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1109[P] |2655   |latch: cache buffers cha|crwvjbp7s8zat 0|,     |3     |
1343,41969,@2  |* Cluster       |907 |28127   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP23 |0903:1216[P] |11     |gc cr request           |3ga69cqmhzhcz 0|,     |8     |
2757,57129,@2  |* Other         |759 |21412   |FPS_BOP   |SVC_FVS_PR|PayTrue.Pa|FNIS-BR\SRVALESP01 |0903:1240[P] |473    |latch: cache buffers cha|crwvjbp7s8zat 0|,     |8     |
1091,37913,@2  |* Other         |585 |18929   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP07 |0903:1237[P] |345    |latch free              |2z1xq868wcym1 0|,     |9     |
1580,57863,@2  |* Other         |845 |21544   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP11 |0903:1240[P] |405    |latch free              |2z1xq868wcym1 0|,     |9     |
1468,28171,@2  |* Other         |428 |19537   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP06 |0803:1610[P] |73313  |latch free              |2j9fjdpwt9crb 0|,     |13    |
2500,5105,@2   |* Other         |501 |23538   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP02 |0903:1212[P] |314    |latch free              |2z1xq868wcym1 0|,     |18    |
2022,27381,@2  |* Other         |369 |19529   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP12 |0903:1238[P] |254    |latch free              |2z1xq868wcym1 0|,     |25    |
2998,11401,@2  |* Concurrency   |633 |13208   |FPS_BOP   |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVALESP09 |0903:1231[P] |375    |latch free              |2z1xq868wcym1 0|,     |28    |
2956,48873,@2  |* Other         |313 |14706   |FPS_BO    |svc_fvs_pr|PayTrue.Pa|FNIS-BR\SRVWEBSP07 |0903:1138[P] |3819   |latch free              |acbc0tdz0n3hb 0|,     |36    |
2053,30943,@1  |* 2053,,@1      |241 |11866   |SYS [DBA ]|oracle    |sqlplus@ln|lnxorasp10         |0903:1248[P] |0      |PX Deq: Execute Reply   |8v6wkwuh74d34 0|,     |0     |[DBA -]
3218,35547,@1  |* Other         |91  |25023   |SYS [RMAN]|oracle    |rman@lnxor|lnxorasp10         |0903:1232[P] |134    |recovery area: computing|fg9r3dquf78fy 2|,     |0     |[RMAN@]
2140,9209,@2   |* User I/O      |82  |14869   |SYS [MVG6]|oracle    |sqlplus@ln|lnxorasp11         |0903:1233[NP]|987    |db file sequential read |020dm5u2512uf 0|,     |0     |[MVG6]
3012,37845,@2  |* User I/O      |665 |3590    |SYS [MVG9]|oracle    |sqlplus@ln|lnxorasp11         |0903:1249[NP]|0      |                        |2fq3ffuxrsp2d 4|,     |0     |[MVG9]
3582,3715,@2   |* Other         |318 |1570    |SYS [MVG2]|oracle    |sqlplus@ln|lnxorasp11         |0903:1248[NP]|76     |message from dblink     |4c2gjqn14g85g 0|,     |0     |[MVG2]
1895,49735,@2  |* Other         |336 |2704    |SYS [MVG7]|oracle    |sqlplus@ln|lnxorasp11         |0903:1249[NP]|59     |message from dblink     |5qyvzhahfgwpk 0|,     |0     |[MVG7]
881,425,@2     |* Network       |359 |2709    |SYS [MVG4]|oracle    |sqlplus@ln|lnxorasp11         |0903:1249[NP]|59     |message from dblink     |9jttag2garcx6 0|,     |0     |[MVG4]
497,41331,@2   |* Other         |644 |3572    |SYS [MVG1]|oracle    |sqlplus@ln|lnxorasp11         |0903:1249[NP]|3      |                        |9mcyhwv4y2cr8 0|,     |0     |[MVG1]
247,32047,@2   |* User I/O      |610 |3548    |SYS [MVG3]|oracle    |sqlplus@ln|lnxorasp11         |0903:1249[NP]|5      |                        |bjg169rjjufgy 0|,     |0     |[MVG3]
3124,40261,@2  |* User I/O      |410 |29411   |SYS [MVG5]|oracle    |sqlplus@ln|lnxorasp11         |0903:1245[NP]|298    |db file scattered read  |cm7t86u7skvxm 0|,     |0     |[MVG5]

172 rows selected.


