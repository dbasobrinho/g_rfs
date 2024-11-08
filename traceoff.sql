--
--
--   NOME
--     rstrcoff.sql
--
--   DESCRICAO
--     Desliga trace de sessao.
--
--   HISTORICO
--     19/05/05(Ricardo Scholze) - Implementacao.
--
-----------------------------------------------------------------------------
-- InterSolution            The Right Choice         www.intersolution.inf.br
-- Simplex              Simplificando a sua vida           www.simplex.com.br
-----------------------------------------------------------------------------

set serveroutput on
set verify off

prompt
prompt Desliga trace de sessao
prompt =======================
prompt
accept v_sid number prompt 'Entre com o SID da sessao: '
declare
v_dec  number;
begin
  for lst in (select s.sid, s.serial#, s.username, s.osuser, s.machine, s.program,
                     i.instance_name, i.host_name, p.spid, s.sql_hash_value, s.status
              from gv$session s, gv$process p, gv$instance i
              where s.sid = &v_sid
                and s.paddr = p.addr
                and p.inst_id = i.inst_id ) loop
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

    sys.dbms_system.set_bool_param_in_session(lst.sid, lst.serial#, 'sql_trace', false);
	DBMS_SYSTEM.set_sql_trace_in_session(sid=>lst.sid, serial#=>lst.serial#, sql_trace=>FALSE); 

    dbms_output.put_line(chr(10) || 'Trace desligado !' || chr(10));
  end loop;
  --/
  for c1 in(SELECT p.tracefile, s.sid 
              FROM v$session s JOIN v$process p ON s.paddr = p.addr
             WHERE s.SQL_TRACE = 'ENABLED')
  loop
    if v_dec is null then
        dbms_output.put_line('.............. TRACES ATIVOS ..............');
		v_dec :=1;
    end if;
    dbms_output.put_line('Sid..............: ' || c1.sid);
    dbms_output.put_line('Tracefile........: ' || c1.tracefile||chr(10));
  end loop;  
 end;
/

--
-- Fim
--

