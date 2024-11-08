CREATE OR REPLACE PROCEDURE "SYS"."DEPTREE_FILL" (type char, schema char, name char) is
  obj_id number;
begin
  delete from deptree_temptab;
  commit;
  select object_id into obj_id from all_objects
    where owner        = upper(deptree_fill.schema)
    and   object_name  = upper(deptree_fill.name)
    and   object_type  = upper(deptree_fill.type);
  insert into deptree_temptab
    values(obj_id, 0, 0, 0);
  insert into deptree_temptab
    select object_id, referenced_object_id,
        level, deptree_seq.nextval
      from public_dependency
      connect by prior object_id = referenced_object_id
      start with referenced_object_id = deptree_fill.obj_id;
exception
  when no_data_found then
    raise_application_error(-20000, 'ORU-10013: ' ||
      type || ' ' || schema || '.' || name || ' was not found.');
end;
/
  CREATE VIEW "SYS"."DEPTREE" ("NESTED_LEVEL", "TYPE", "SCHEMA", "NAME", "SEQ#") AS
  select d.nest_level, o.object_type, o.owner, o.object_name, d.seq#
  from deptree_temptab d, dba_objects o
  where d.object_id = o.object_id (+)
union all
  select d.nest_level+1, 'CURSOR', '<shared>', '"'||c.kglnaobj||'"', d.seq#+.5
  from deptree_temptab d, x$kgldp k, x$kglob g, obj$ o, user$ u, x$kglob c,
      x$kglxs a
    where d.object_id = o.obj#
    and   o.name = g.kglnaobj
    and   o.owner# = u.user#
    and   u.name = g.kglnaown
    and   g.kglhdadr = k.kglrfhdl
    and   k.kglhdadr = a.kglhdadr   /* make sure it is not a transitive */
    and   k.kgldepno = a.kglxsdep   /* reference, but a direct one */
    and   k.kglhdadr = c.kglhdadr
    and   c.kglhdnsp = 0 /* a cursor */
/	
 

 
 CREATE SEQUENCE  "SYS"."DEPTREE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 601 CACHE 200 NOORDER  NOCYCLE ;

 CREATE TABLE "SYS"."DEPTREE_TEMPTAB"
   (    "OBJECT_ID" NUMBER,
        "REFERENCED_OBJECT_ID" NUMBER,
        "NEST_LEVEL" NUMBER,
        "SEQ#" NUMBER
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "SYSTEM" ;


create public synonym DEPTREE_SEQ for "SYS"."DEPTREE_SEQ" ;
 
create public synonym DEPTREE_TEMPTAB for "SYS"."DEPTREE_SEQ" ;

create public synonym DEPTREE for "SYS"."DEPTREE" ;
  




  