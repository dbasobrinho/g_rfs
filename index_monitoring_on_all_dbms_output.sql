set serveroutput on
ALTER SESSION ENABLE PARALLEL DDL;
ALTER SESSION SET DDL_LOCK_TIMEOUT= 10;
set echo on
exec dbms_application_info.set_module( module_name => ' !! [ZAS] !! SQLPLUS_SYS', action_name => '!! [ZAS] !! ATIVAR INDEX MONITORING USAGE');
PROMPT .
PROMPT ========================================================================
PROMPT 03 - ATIVANDO TODOS NOMONITORING INDEX [working. . .]
PROMPT ========================================================================
PROMPT .
declare
v_temp varchar2(1500);
begin
  execute immediate 'purge dba_recyclebin';

  for c1 in (select --'alter index ' || x.owner || '.' || x.segment_name || ' nomonitoring usage' as comm_off
                'alter index '||x.owner||'.'||x.segment_name||' monitoring usage;'   as comm_on
             --- ,x.owner||'.'||x.segment_name                                        as msg
               from dba_segments x
               where x.segment_type='INDEX'  
                and not exists (select 1 from dba_recyclebin l where l.owner = x.owner and l.object_name = x.segment_name)
        and exists (select 1 from dba_indexes l where l.owner = x.owner and l.INDEX_NAME = upper(x.segment_name) and UNIQUENESS <> 'UNIQUE')
                /* --/ p_tipo=0 --> Somente Habilitar 
                 and ((0 = 0 and not exists 
                                                 (select 1
                                                    from  SYS.V$ALL_OBJECT_USAGE h 
                                                    where h.monitoring = 'YES'
                                                      and h.owner      = x.owner
                                                      and h.index_name = x.segment_name))
                  --/ p_tipo=1 --> Excluir e Habilitar
                   or (0 = 1 and exists 
                                                 (select 1
                                                    from  SYS.V$ALL_OBJECT_USAGE h 
                                                    where h.monitoring = 'YES'
                                                      and h.used       = 'YES'
                                                      and h.owner      = x.owner
                                                      and h.index_name = x.segment_name)))     */                                                 
                 and not exists (select a.index_owner, a.index_name 
                                from dba_constraints   A   
                               where constraint_type in ('P', 'U', 'R')  
                                 and a.index_owner = x.owner
                                 and a.index_name  = x.segment_name) --AND x.owner = 'SYS'
                 and x.owner not in('SYS','SYSTEM','OPS$ORACLE','ANONYMOUS','BI','CTXSYS','DBSNMP','SYSMAN',
                                    'DIP','DMSYS','TSMSYS','PERFSTAT','EXFSYS','HR','IX','LBACSYS',
                                    'MDDATA','MDSYS','MGMT_VIEW','ODM','ODM_MTR','OE','OLAPSYS',
                                    'ORDPLUGINS','ORDSYS','OUTLN','PM','SCOTT','SH','SI_INFORMTN_SCHEMA',
                                    'SYSMAN','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','WEBSYS','WK_PROXY',
                                    'WKSYS','WK_TEST','WMSYS','XDB','OSE$HTTP$ADMIN','AURORA$JIS$UTILITY$',
                                    'AURORA$ORB$UNAUTHENTICATED','XS$NULL','ORACLE_OCM','ORDDATA','OWBSYS',
                                    'OWBSYS_AUDIT','APPQOSSYS','APEX_030200','COLLECTOR_ADM','SQLTXPLAIN')
             
             ) loop
    begin
      v_temp := c1.comm_on;
	  dbms_output.put_line( c1.comm_on );
      --execute immediate c1.comm_on;
    exception
      when others then
         dbms_output.put_line( c1.comm_on );
    end;
  end loop;
    exception
      when others then
  dbms_output.put_line( v_temp );
end;
/
PROMPT .
PROMPT ========================================================================
PROMPT 03 - ATIVOU TODOS NOMONITORING INDEX [OK]
PROMPT ========================================================================
PROMPT .
PROMPT =====T O T A I S =======================================================
PROMPT .
select count(1) tot, MONITORING from V$ALL_OBJECT_USAGE group by MONITORING
/
PROMPT ========================================================================
