set serveroutput on
ALTER SESSION ENABLE PARALLEL DDL;
ALTER SESSION SET DDL_LOCK_TIMEOUT= 10;
set echo on
exec dbms_application_info.set_module( module_name => ' !! [ZAS] !! SQLPLUS_SYS', action_name => '!! [ZAS] !! ATIVAR INDEX MONITORING USAGE');
PROMPT .
PROMPT ========================================================================
PROMPT 02 - DESATIVANDO TODOS NOMONITORING INDEX [working. . .]
PROMPT ========================================================================
PROMPT .
declare
v_temp varchar2(1500);
begin
  execute immediate 'purge dba_recyclebin';

  for c1 in (select 'alter index ' || x.owner || '.' || x.segment_name || ' nomonitoring usage' as comm_off
             --   ,'alter index '||x.owner||'.'||x.segment_name||' monitoring usage'   as comm_on
             -- ,x.owner||'.'||x.segment_name                                        as msg
               from dba_segments x
              where x.segment_type = 'INDEX'
              and exists
              (select 1
                       from dba_indexes l
                      where l.owner = x.owner
                        and l.INDEX_NAME = upper(x.segment_name))
                 and x.owner not  in('SYS','SYSTEM','OPS$ORACLE','ANONYMOUS','BI','CTXSYS','DBSNMP','SYSMAN',
                                    'DIP','DMSYS','TSMSYS','PERFSTAT','EXFSYS','HR','IX','LBACSYS',
                                    'MDDATA','MDSYS','MGMT_VIEW','ODM','ODM_MTR','OE','OLAPSYS',
                                    'ORDPLUGINS','ORDSYS','OUTLN','PM','SCOTT','SH','SI_INFORMTN_SCHEMA',
                                    'SYSMAN','TRACESRV','MTSSYS','OASPUBLIC','OLAPSYS','WEBSYS','WK_PROXY',
                                    'WKSYS','WK_TEST','WMSYS','XDB','OSE$HTTP$ADMIN','AURORA$JIS$UTILITY$',
                                    'AURORA$ORB$UNAUTHENTICATED','XS$NULL','ORACLE_OCM','ORDDATA','OWBSYS',
                                    'OWBSYS_AUDIT','APPQOSSYS','APEX_030200','SQLTXPLAIN')
                                                
             ) loop
    begin
      v_temp := c1.comm_off;
      dbms_output.put_line( c1.comm_off );
      --execute immediate c1.comm_off;
    exception
      when others then
         dbms_output.put_line( c1.comm_off );
    end;
  end loop;
    exception
      when others then
  dbms_output.put_line( v_temp );
end;
/
PROMPT .
PROMPT ========================================================================
PROMPT 02 - DESATIVOU TODOS NOMONITORING INDEX [OK]
PROMPT ========================================================================
PROMPT .
PROMPT =====T O T A I S =======================================================
PROMPT .
select count(1) tot, MONITORING from V$ALL_OBJECT_USAGE group by MONITORING
/
PROMPT ========================================================================

--select * from V$ALL_OBJECT_USAGE where MONITORING = 'YES' AND USED = 'YES' ORDER BY start_monitoring DESC;
