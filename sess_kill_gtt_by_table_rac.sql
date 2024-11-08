set serveroutput on
set timing on 
declare
    cursor sid is
	SELECT 'alter system kill session '''||s.sid||','||s.serial#||',@'||s.inst_id|| ''' immediate ' comando
	  FROM gv$lock l, gv$session s 
     WHERE l.id1 = (SELECT object_id FROM DBA_objects 
	                 WHERE owner = 'RTDBM' 
                       AND object_name in ('NBA_GTT_OFERTAS_PARA_PACOTE','NBA_GTT_OFERTAS','NBA_GTT_DESCONTOS' )) 
       and l.sid=s.sid and l.inst_id=s.inst_id;
       v varchar2(600);
       v_tot number;
begin
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
end;
/