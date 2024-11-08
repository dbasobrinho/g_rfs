set serveroutput on
set timing on
declare
    cursor sid is
      select b.sid sid, b.serial# serial, '@'||B.inst_id inst_id,
          'alter system kill session ''' || b.sid || ',' ||b.serial# ||''' immediate ' comando
        from gv$session b
       where b.sql_id   = '&sql_id'
       order by b.sid desc;
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
