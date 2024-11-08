SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | KILL SQLID AND INSTANCE, TO STOP (CTRC +C)     +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT . . .
PROMPT . . 
PROMPT . 
ACCEPT iinst_id char   PROMPT 'INSTANCE ID                      = '
ACCEPT sssql_id char   PROMPT 'SQL ID FULL KILL IN LOOP NO STOP = '
PROMPT . . .
PROMPT . . 
PROMPT . 
set timing on
set echo on
exec dbms_application_info.set_module( module_name => 'KILL ALL SQLID . . . [DBA TIVIT]', action_name =>  'KILL ALL SQLID . . . [DBA TIVIT]');
declare
    cursor sid is
      select b.sid sid, b.serial# serial, '@'||B.inst_id inst_id,
      'alter system kill session ''' || b.sid || ',' ||b.serial# || ',@' ||b.inst_id||''' immediate ' comando
        from gv$session b
       where b.sql_id = '&sssql_id'
	   and b.status = 'ACTIVE'
	   and b.inst_id  = '&iinst_id'
       order by b.sid desc;
       v varchar2(600);
       v_tot number;
begin
loop
    DBMS_LOCK.sleep(5);
    v_tot :=0;
    for a in sid
    loop
        begin
           execute immediate a.comando;
           --dbms_output.put_line('Killed: sid: '||lpad(a.sid,4,'0')||' serial#: '||lpad(a.serial,6,'0')|| ' ok!');
           v_tot := v_tot +1;
        exception
        when others then
            dbms_output.put_line('Error Kill: sid: '||lpad(a.sid,4,'0')||' serial#: '||lpad(a.serial,6,'0'));
        end;
    end loop;
    --dbms_output.put_line(' ');
    --dbms_output.put_line('----------------------------------------------------------------');
    --dbms_output.put_line(' T O T A L   K I L L : '||LPAD(v_tot,8,'0'));
    --dbms_output.put_line('----------------------------------------------------------------');
end loop;	
end;
/
set echo off
UNDEF sssql_id
UNDEF iinst_id