set serveroutput on
set verify off
SET FEEDBACK   off
alter session set timed_statistics=true;
alter session set max_dump_file_size = unlimited;
ALTER SESSION SET TRACEFILE_IDENTIFIER = 'ZAS08';
SET FEEDBACK   on
prompt
prompt Liga trace de sessao
prompt ====================
prompt
accept v_sid number prompt 'Entre com o SID da sessao: '
declare
v_trace varchar2(2000);
begin
  for lst in (select s.sid, s.serial#, s.username, s.osuser, s.machine, s.program,
                     i.instance_name, i.host_name, p.spid, s.sql_hash_value, s.status
              from v$session s, v$process p, v$instance i
              where s.sid = &v_sid
                and s.paddr = p.addr) loop
    dbms_output.put(chr(10));
    dbms_output.put_line('Sid..............: ' || lst.sid);
    dbms_output.put_line('Serial#..........: ' || lst.serial#);
    dbms_output.put_line('Status...........: ' || lst.status);
    dbms_output.put_line('Username.........: ' || lst.username);
    dbms_output.put_line('Maquina..........: ' || lst.machine);
    dbms_output.put_line('Programa.........: ' || lst.program);
    dbms_output.put_line('SQL hash value...: ' || lst.sql_hash_value);
    dbms_output.put_line('OS User..........: ' || lst.osuser);
    dbms_output.put_line('Host.............: ' || lst.host_name);
    dbms_output.put_line('Instance.........: ' || lst.instance_name);
    dbms_output.put_line('PID..............: ' || lst.spid);

    sys.dbms_system.set_bool_param_in_session(lst.sid, lst.serial#, 'timed_statistics', true);
    sys.dbms_system.set_int_param_in_session(lst.sid, lst.serial#, 'max_dump_file_size', 536870912);
    sys.dbms_system.set_ev(lst.sid, lst.serial#, 10046, 8, '');
    
	SELECT p.tracefile
	 INTO v_trace
      FROM v$session s JOIN v$process p ON s.paddr = p.addr
     WHERE  s.sid = &v_sid;	
	
	dbms_output.put_line(chr(10) || 'Trace ligado! ' || v_trace||chr(10));
	dbms_output.put_line('tkprof TRACE_FILENAME result.txt sys=no waits=yes sort=exeela,fchel');
  end loop;
end;
/

