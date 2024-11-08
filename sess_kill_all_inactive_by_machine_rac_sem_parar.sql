set serveroutput on
set timing on
exec dbms_application_info.set_module( module_name => 'KILL ALL SQLID . . . [DBA TIVIT]', action_name =>  'KILL ALL SQLID . . . [DBA TIVIT]');
declare
    cursor sid is
      select b.sid sid, b.serial# serial, '@'||B.inst_id inst_id,
      'alter system kill session ''' || b.sid || ',' ||b.serial# || ',@' ||b.inst_id||''' immediate ' comando
        from gv$session b
     WHERE MACHINE = 'lnxorarjr03'
	 and status  = 'INACTIVE'
	 and last_call_et > 300
       order by b.sid desc;
       v varchar2(600);
       v_tot number;
begin
    WHILE 1 = 1
	loop
    v_tot :=0;
    for a in sid
    loop
        begin
           execute immediate a.comando;
           dbms_output.put_line('Killed: sid: '||lpad(a.sid,4,'0')||' serial#: '||lpad(a.serial,6,'0')|| ' ok!');
           v_tot := v_tot +1;
        exception
        when others then
            dbms_output.put_line('Error Kill: sid: '||lpad(a.sid,4,'0')||' serial#: '||lpad(a.serial,6,'0'));
        end;
    end loop;
    dbms_output.put_line(' ');
    dbms_output.put_line('----------------------------------------------------------------');
    dbms_output.put_line(' T O T A L   K I L L : '||LPAD(v_tot,8,'0'));
    dbms_output.put_line('----------------------------------------------------------------');
	end loop;
end;
/

lnxorarjr03


select count(*) qtde, inst_id, service_name, username  from gv$session where machine = 'lnxorarjr03' group by inst_id, service_name,  service_name, username;