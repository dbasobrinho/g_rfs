conn / as sysdba
set echo on
declare
    cursor sid is
      select b.sid sid, b.serial# serial, '@'||B.inst_id inst_id, b.seconds_in_wait, b.username,
      'alter system kill session ''' || b.sid || ',' ||b.serial# || ',@' ||b.inst_id||''' immediate ' comando
        from gv$session b
       where b.status   = 'INACTIVE'
       and b.seconds_in_wait > 600
	   and b.username is not null
	   and (   select trunc((z.processes*100)/y.limit) prc
				from(select count(*) processes from gv$session) z
				   ,(select VALUE limit from v$parameter where UPPER(name) like UPPER('processes')) y ) > 75
       order by  b.seconds_in_wait desc;
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
set echo off
EXIT
/







[11:38] Anderson Santos Pedreira
col machine format a30
col process format 999999
select p.spid,b.sid, p.pid, b.process as process_for_db_link, machine, logon_time, status
from v$session b, v$process p
where b.paddr=p.addr
and b.username = 'DBLNK_AAS'
order by 6
/

select * from v_$session@ACCOUNT_DATA_LINK b

13565

     select count(1)
        from gv$session b
       where b.status   = 'INACTIVE'
       and b.seconds_in_wait > 8000
