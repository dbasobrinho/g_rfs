SET LINES 200 PAGES 50000
col rows_por_exec FORM 999,999,999
col cursor        FORM a10
col ADDRESS       FORM a20
col name          FORM a30
col owner          FORM a15
col hash_value    FORM 999999999999
col full_hash_value    FORM a33
col type          FORM a15
col LOCKED_TOTAL  FORM 999999999999
col PINNED_TOTAL  FORM 999999999999
col EXECUTIONS    FORM 999999999999
col NAMESPACE     FORM 999999999999

spo .guina_tmp.sql
prompt SET echo ON 
--select owner , object_name, object_type from dba_objects where object_name = '<OBJECT_NAME>';      
select nvl2(owner,'exec dbms_shared_pool.markhot('||''''||owner||''''||','||''''||name||''''||',1); ',null) command1,
       nvl2(owner,'exec dbms_shared_pool.markhot('||''''||owner||''''||','||''''||name||''''||',2); ',null) command2,
       nvl2(owner,'exec dbms_shared_pool.markhot('||''''||owner||''''||','||''''||name||''''||',3); ',null) command3,	
	   nvl2(owner,null,'exec dbms_shared_pool.markhot(hash=>'||''''||full_hash_value||''''||','||'NAMESPACE=>0); ') command5  
from(
Select distinct owner, name, full_hash_value
  from (Select case
                 when (kglhdadr = kglhdpar) then
                  'Parent'
                 else
                  'Child ' || kglobt09
               end cursor,
               kglhdadr ADDRESS,
			   (select max(owner) from dba_objects where object_name = kglnaobj ) owner,
               substr(kglnaobj, 1, 30) name,
               kglnahsh hash_value,
			   (select max(full_hash_value) from v$db_object_cache where hash_value = kglnahsh) full_hash_value,
               kglobtyd type,
               kglobt23 LOCKED_TOTAL,
               kglobt24 PINNED_TOTAL,
               kglhdexc EXECUTIONS,
               kglhdnsp NAMESPACE
          from x$kglob
         order by kglobt24 desc)
 where rownum <= 20 ) z
 order by owner
/
spo off
prompt =====================================
prompt @.guina_tmp.sql
prompt =====================================
prompt =====================================
REPHEADER OFF