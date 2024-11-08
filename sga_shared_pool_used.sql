col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a16  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a19
col logon_time   format a13 
col hold         format a06
col sessionwait  format a24
col status       format a08
col hash_value   format a10 
col sc_wait      format a06 HEADING 'WAIT'
col SQL_ID       format a15 HEADING 'SQL_ID/CHILD'
col module       format a08 HEADING 'MODULE'
SET COLSEP '|'

select u.username ,  PLAN_HASH_VALUE, child_number, sum(executions) executions, is_shareable, count(distinct(sql_id)) sql
from   gv$sql, dba_users u
where PLAN_HASH_VALUE > 0
and PARSING_USER_ID = u.USER_ID and u.USER_ID <> 0
group by u.username ,  PLAN_HASH_VALUE, child_number,  is_shareable 
having count(distinct(sql_id)) > 50
order by PLAN_HASH_VALUE
/
set serveroutput on;  
set feedback off; 
declare 
        object_mem number;  
        shared_sql number;  
        cursor_mem number;  
        mts_mem number;  
        used_pool_size number;  
        free_mem number;  
        pool_size varchar2(512); -- mesmo com V$PARAMETER.VALUE  
begin 
-- Objetos Armazenados (packages, views)  
select sum(sharable_mem) into object_mem from v$db_object_cache;  
-- Uso de cursores pelos Usuários -- executar este durante pico de uso.
-- assume 250 bytes por cursores abertos, para cada usuário concorrente.
select sum(250*users_opening) into cursor_mem from v$sqlarea;   
-- Para um teste no sistema - pega o uso de um usuário, multiplica-o pelos # usuários  
-- select (250 * value) bytes_per_user  
-- from v$sesstat s, v$statname n  
-- where s.statistic# = n.statistic#  
-- and n.name = 'opened cursors current'  
-- and s.sid = 25; -- aonde 25 é o SID do processo.  
   
-- MTS (Multithreaded Shared Servers) memória necessita manter a informação das sessões para compartilhar com os usuários do servidor.
-- Este comando computa um total para todos os usuário conectados correntemente. (executar
-- durante um período de pico). Alternativamente calcular para um único usuário e
-- multiplica-o pelos # usuários.  
select sum(value) into mts_mem from v$sesstat s, v$statname n  
       where s.statistic#=n.statistic#  
       and n.name='session uga memory max';   
-- Livre (Não usado) memória na SGA: dá uma indicação da quantidade de memória
-- que está sendo desperdiçada do total alocada.  
select bytes into free_mem from v$sgastat   where name = 'free memory' and pool='shared pool';  
-- Para não MTS adicionar objetos, shared sql, cursores e 30% acima.  
used_pool_size := round(1.3*(object_mem+cursor_mem));  
-- Para MTS mts precisa contribuir para ser incluído (commentado nas linhas anteriores)
-- used_pool_size := round(1.3*(object_mem+shared_sql+cursor_mem+mts_mem));  
select value into pool_size from v$parameter where name='shared_pool_size';  
-- Mostrando os Resultados 
dbms_output.put_line ('==============================================================================='); 
dbms_output.put_line ('-----------------------S H A R E D    P O O L    U S E D-----------------------'); 
dbms_output.put_line ('==============================================================================='); 
dbms_output.put_line ('OBJECT MEM------------------------: '||lpad(to_char(object_mem    ),15,' ') || ' BYTES ' || '>>'|| lpad(to_char(round(object_mem/1024/1024,2    )) || ' MB',15,' '));
dbms_output.put_line ('CURSORS---------------------------: '||lpad(to_char(cursor_mem    ),15,' ') || ' BYTES ' || '>>'|| lpad(to_char(round(cursor_mem/1024/1024,2    )) || ' MB',15,' '));
dbms_output.put_line ('MTS SESSION-----------------------: '||lpad(to_char(mts_mem       ),15,' ') || ' BYTES ' || '>>'|| lpad(to_char(round(mts_mem/1024/1024,2       )) || ' MB',15,' '));
dbms_output.put_line ('FREE MEMORY-----------------------: '||lpad(to_char(free_mem      ),15,' ') || ' BYTES ' || '>>'|| lpad(to_char(round(free_mem/1024/1024,2      )) || ' MB',15,' '));  
dbms_output.put_line ('SHARED POOL UTILIZATION (TOTAL)---: '||lpad(to_char(used_pool_size),15,' ') || ' BYTES ' || '>>'|| lpad(to_char(round(used_pool_size/1024/1024,2)) || ' MB',15,' '));  
dbms_output.put_line ('SHARED POOL ALLOCATION (ACTUAL)---: '||lpad(to_char(pool_size     ),15,' ') || ' BYTES ' || '>>'|| lpad(to_char(round(pool_size/1024/1024,2     )) || ' MB',15,' '));  
dbms_output.put_line ('-------------------------------------------------------------------------------'); 
dbms_output.put_line ('PERCENTAGE UTILIZED---------------: '||lpad(to_char(round(used_pool_size/pool_size*100)),15,' ') || ' %');  
dbms_output.put_line ('==============================================================================='); 
dbms_output.put_line (':)'); 
end;  
/
set feedback on;