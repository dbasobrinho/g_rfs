set serveroutput on
set timing on 
declare
    cursor sid is
        select x.* 
        from (
        SELECT level levelx,
               LPAD(' ', (level-1)*2, ' ') || NVL(s.username, '(oracle)') AS username,
               s.sid, s.serial# serial,s.inst_id,
               'alter system kill session ''' || s.sid || ',' ||s.serial# || ',@' ||s.inst_id||''' immediate ' comando
        FROM   gv$session s
        WHERE  level > 1
        OR     EXISTS (SELECT 1
                       FROM   v$session
                       WHERE  blocking_session = s.sid)
        CONNECT BY PRIOR s.sid = s.blocking_session
        START WITH s.blocking_session IS NULL) x
        where x.levelx = 1;
       v varchar2(600);
       v_tot number;
begin
    v_tot :=0;
    for a in sid
    loop
        begin 
           execute immediate a.comando;
           dbms_output.put_line('Killed: sid: '||lpad(a.sid,4,'0')||' serial#: '||lpad(a.serial,6,'0')||' inst_id: '||lpad(a.inst_id,6,'0')|| ' ok!');
           v_tot := v_tot +1;
        exception
        when others then
            dbms_output.put_line('Error Kill: sid: '||lpad(a.sid,4,'0')||' serial#: '||lpad(a.serial,6,'0')||' inst_id: '||lpad(a.inst_id,6,'0'));
        end;
    end loop;
    dbms_output.put_line(' ');
    dbms_output.put_line('----------------------------------------------------------------');
    dbms_output.put_line(' T O T A L   K I L L : '||LPAD(v_tot,8,'0'));
    dbms_output.put_line('----------------------------------------------------------------');
end;
/
