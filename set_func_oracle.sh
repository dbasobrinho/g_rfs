
##########################
# Geral
##########################
if [ "$LOGNAME" = "oracle" ]
then
export CONN="/ as sysdba"
else
export CONN="outra/senha"
fi

##########################
# Funcao que lista sessoes do banco para um usuario
# do sistema operacional
# Argumentos: nome_usuario
##########################
ls_usu_ora ()
{
sqlplus -S /nolog<<!
set feedback off
set verify off
set pagesize 50
col dbuser format a10
col osuser format a10
col sid format 999999999
col term format a10
col prog format a14
conn ${CONN}
var usu char(8)
exec :usu := '$1'
select sid sid,
osuser osuser,
username dbuser,
substr(program,1,14) prog,
terminal term
from v\$session
where osuser = trim(:usu)
and username != 'SUPORTE'
and status != 'KILLED'
/
!
}

##########################
# Funcao que finaliza sessoes do banco
# Argumentos: sid e serial
##########################
kill_sid_ora ()
{
sqlplus -S /nolog<<!
set head off
set serveroutput on
conn ${CONN}
alter system kill session '$1' immediate;
!
}
##########################
# Funcao para listar indices de tabelas do Oracle
# Argumentos: owner tabela
##########################
list_ind_ora ()
{
sqlplus -S /nolog<<!
conn ${CONN}
set serveroutput on
declare
v_contador      number(10);
v_linha varchar2(2000);
--
cursor c1 is
select index_name, tablespace_name, uniqueness
from   dba_indexes
where  owner = upper('$1')
and    table_name = upper('$2')
order by 1;
--
cursor c2 (p_indice in varchar2) is
select column_name
from   dba_ind_columns
where  index_owner = upper('$1')
and    index_name = p_indice
order by column_position;
begin
for r1 in c1
loop
dbms_output.put_line(r1.index_name || ' ---> ' || r1.tablespace_name || ' --> ' || r1.uniqueness);
--
v_contador := 1;
v_linha    := '';
--
for r2 in c2 (r1.index_name)
loop
if v_contador = 1
then
v_linha := v_linha || '...';
else
v_linha := v_linha || ', ';
end if;
--
if length(v_linha || r2.column_name) < 250
then
v_linha := v_linha || r2.column_name;
end if;
--
v_contador := v_contador + 1;
end loop;
dbms_output.put_line(v_linha);
end loop;
end;
/
!
}
##########################
# Funcao para verificar espaco nos tablespaces do Oracle
# Argumentos: nome_usuario
##########################
dbsp_ora ()
{
sqlplus -S /nolog <<!
set feedback off
conn ${CONN}
cl scr
col tbspace heading 'Name' format a20
col "msize" heading 'MBytes' format 9999999
col "mfree" heading 'MBFree' format 9999999
col "%free" heading '%Free' format 999
col "%used" heading '%Used' format 999
col "dtfile" heading 'Datafiles' format a50
col "incr"  heading 'MBIncr' format 9999999
col "max"   heading 'Max. MB' format 9999999
col "ts#"   format 999
set linesize 200
set pagesize 100
set heading on
break on report
compute sum of MBytes on report
compute sum of MBFree on report
prompt TABLESPACES
prompt ===========
select /*+ALL_ROWS */ t.tablespace_name "tbspace",
v.ts#,
round(t.bytes/1024/1024) "msize",
nvl(round(sum(f.bytes)/1024/1024),0) "mfree",
round(sum(f.bytes)*100/t.bytes) "%free",
round((t.bytes-sum(f.bytes))*100/t.bytes) "%used",
round(t.maxbytes/1024/1024) "max",
a.extent_management "Ext_Manag",
a.status "Status"
from  (select  /*+ALL_ROWS */
tablespace_name,
sum(bytes) bytes,
sum(maxbytes) maxbytes
from  dba_data_files
group by tablespace_name) t,
dba_free_space f,
dba_tablespaces a,
v\$tablespace v
where t.tablespace_name = f.tablespace_name(+)
and   t.tablespace_name = a.tablespace_name
and   t.tablespace_name = v.name
group by t.tablespace_name, v.ts#, t.bytes, t.maxbytes, a.extent_management, a.contents, a.status
order by v.ts#
/
!
echo "\nPressione <ENTER>"
read
sqlplus -S /nolog <<!
set feedback off
conn ${CONN}
cl scr
col tbspace heading 'Name' format a20
col "msize" heading 'MBytes' format 9999999
col "mfree" heading 'MBFree' format 9999999
col "%free" heading '%Free' format 999
col "%used" heading '%Used' format 999
col "dtfile" heading 'Datafiles' format a50
col "incr"  heading 'MBIncr' format 9999999
col "max"   heading 'Max. MB' format 9999999
col "ts#"   format 999
set linesize 200
set pagesize 100
set heading on
break on report
prompt
prompt TEMP TABLESPACES
prompt ================
select /*+ALL_ROWS */ a.tablespace_name "tbspace",
v.ts#,
a.file_name "dtfile",
round(a.bytes/1024/1024) "msize"
from   dba_temp_files a,
v\$tablespace v
where  a.tablespace_name = v.name
order by v.ts#
/
prompt
prompt UNDO TABLESPACES
prompt ================
select sum(RSSIZE/1024/1024/1024) "UTILIZADO (GB)"
from     sys.v_\$rollstat a, sys.v_\$rollname b
where    a.USN=b.USN
/
prompt
prompt ** Undo Extents Status **
SELECT tablespace_name, status, COUNT(*) AS HOW_MANY
FROM dba_undo_extents
GROUP BY tablespace_name, status
/
!
echo "\nPressione <ENTER>"
read
sqlplus -S /nolog <<!
set feedback off
conn ${CONN}
col tbspace heading 'Name' format a20
col "msize" heading 'MBytes' format 9999999
col "mfree" heading 'MBFree' format 9999999
col "%free" heading '%Free' format 999
col "%used" heading '%Used' format 999
col "dtfile" heading 'Datafiles' format a50
col "incr"  heading 'MBIncr' format 9999999
col "max"   heading 'Max. MB' format 9999999
col "ts#"   format 999
set linesize 200
set pagesize 100
set heading on
break on report
compute sum of MBytes on report
compute sum of MBFree on report
prompt
prompt DATAFILES
prompt =========
select /*+ALL_ROWS */ d.file_name "dtfile",
v.ts#,
d.bytes/1024/1024 "msize",
sum(nvl(f.bytes,0)/1024/1024) "mfree",
(increment_by*p.value)/1024/1024 "incr",
round(d.maxbytes/1024/1024) "max"
from   dba_data_files d,
dba_free_space f,
v\$parameter p,
v\$tablespace v
where  d.file_id = f.file_id(+)
and    p.name = 'db_block_size'
and    d.tablespace_name = v.name
group by d.tablespace_name, d.file_name, d.bytes, d.maxbytes, d.increment_by, p.value, v.ts#
order by v.ts#
/
prompt
prompt
!
echo "\n"
}
####################################
# FUNCAO QUE VERIFICA LOCK DE TABELA
####################################
verlock ()
{
sqlplus -S /nolog<<!
set linesize 200
column sid              format 9990;
column serial#          format 99990;
column username         format a10
column osuser           format a10
column object_name      format a25
column trancando_desde  format a10
column logon            format a14
column rollback_seg     format a10
column lock_mode        format a13
column req_mode         format a13
conn ${CONN}

select d.sid
,d.serial#                        serial#
,a.oracle_username                username
,a.os_user_name                   osuser
,b.owner || '.' || b.object_name  object_name
,decode(f.lmode,0,'--Waiting--',
1,'No Lock',
2,'Row Share',
3,'Row Exclusive',
4,'Share',
5,'Sha Row Exclusive',
6,'Exclusive', 'Other') lock_mode
,decode(f.request,0,' ',
1,'No Lock',
2,'Row Share',
3,'Row Exclusive',
4,'Share',
5,'Sha Row Exclusive',
6,'Exclusive', 'Other') req_mode
,to_char(d.logon_time,'DD/MM/RR HH24:MI') logon
,f.ctime
from   v\$locked_object          a
,dba_objects              b
,v\$rollname               c
,v\$transaction            e
,v\$session                d
,v\$lock                   f
where  b.object_id = a.object_id
and    c.usn       = a.xidusn
and    d.sid       = a.session_id
and    e.addr(+)   = d.taddr
and    f.sid       = a.session_id
and    f.id1       = a.object_id
order by b.owner, b.object_name
/
!
}
###############################################################
# FUNCAO QUE VERIFICA PROCESSO ORACLE REFERENTE AO PROCESSO AIX
###############################################################
verproc ()
{
sqlplus -S /nolog<<!
set linesize 200
column sid      format 99990;
column serial#  format 999990;
column spid     format 999990;
column osuser   format a22;
column username format a15;
column machine  format a22;
column program  format a20;
conn ${CONN}
var processo char(18)
exec :processo := '$1'

select a.sid
,a.serial#
,b.spid
,a.username
,a.osuser
,a.status
,a.machine
--      ,decode(a.username, '', 'oracle (' || c.name || ')' , substr(a.program,1,20)) program
from   v\$session a
,v\$process b
,v\$bgprocess c
where  b.addr(+)  = a.paddr
and    c.paddr(+) = a.paddr
and    b.spid = :processo
/
!
}
###############################################
# FUNCAO QUE VERIFICA SESSOES DO BANCO DE DADOS
###############################################
orasess ()
{
sqlplus -S /nolog<<!
set linesize 200
column x        format a1
column sid      format 9990;
column serial#  format 99990;
column spid     format 999990;
column osuser   format a15;
column username format a10;
column server   format a1;
column machine  format a18;
#column program format a20;
column program  format a18;
column logon    format a14;
column client_info format a15;
conn ${CONN}

select decode(a.audsid, userenv('sessionid'), '*', ' ') x
,a.sid
,a.serial#
,b.spid
,a.username
,a.osuser
,substr(a.client_info,1,15) client_info
,a.status
,decode(a.server, 'DEDICATED', 'D', 'S') server
,a.machine
,decode(a.username, '', 'oracle (' || c.name || ')' , substr(a.program,1,20)) program
,to_char(a.logon_time,'DD/MM/RR HH24:MI') logon
from   v\$session a
,v\$process b
,v\$bgprocess c
where  b.addr(+)  = a.paddr
and    c.paddr(+) = a.paddr
order by a.sid
/
!
}

###################################################
# FUNCAO QUE VERIFICA A OCUPACAO DOS SHARED SERVERS
###################################################
ver_shared_servers ()
{
sqlplus -S /nolog<<!
set linesize 200

conn ${CONN}
select name "NAME",
paddr,
requests,
(busy/(busy + idle)) * 100 "%TIME BUSY",
status
from v\$shared_server
order by "%TIME BUSY" desc

/
!
}
###################################################
# FUNCAO QUE VERIFICA A OCUPACAO DOS SHARED SERVERS
###################################################
ver_shared_servers_sess ()
{
sqlplus -S /nolog<<!
Set lines 250
set Pages 10000
set feedback on
set Heading on
column username format a15 heading "Usu.Oracle"
column osuser format a15 heading "Usu.Sist.Oper"
column machine format a25 heading "Maquina do Usuario"
column sid format 999999 heading "Sid"
column serial# heading "Serial#"
column s_pid format a8 heading "PID"
column program format a30
conn ${CONN}

select s.osuser,
s.machine,
p.spid s_pid,
s.username,
s.sid,
s.serial#,
s.program,
s.server,
c.server
from v\$process p ,
v\$session s,
v\$sesstat ss,
v\$sess_io si,
v\$bgprocess bg,
v\$circuit c
where s.paddr=p.addr
and s.saddr=c.saddr
and ss.sid=s.sid
and ss.statistic#=12
and si.sid=s.sid
and bg.paddr(+)=p.addr
and c.server <> '00'
order by 3,4
/
!
}

###############################################
# FUNCAO QUE VERIFICA O SQL DA SESSAO INFORMADA
###############################################
ver_sql ()
{
sqlplus -S /nolog<<!
set linesize 200
conn ${CONN}
var sessao number
exec :sessao := '$1'

select --+ use_hash (a, b)
b.sql_text
from   v\$session a
,v\$sqltext b
where  a.sid = :sessao
and    b.address = a.sql_address
and    b.hash_value = a.sql_hash_value
order by b.piece
/
!
}

###############################################
# FUNCAO QUE VERIFICA O WAIT de determinada SESSAO
###############################################
sessionwait ()
{
sqlplus -S /nolog<<!
set linesize 200
col sid format 99999
col event format a30
col text format a40
col wait_class format a20
col wait_time format 99999
conn ${CONN}
var sessao number
exec :sessao := '$1'

select SID, EVENT,
P1TEXT||P1||' '|| P2TEXT||P2||' '|| P3TEXT||P3 TEXT,
WAIT_CLASS, WAIT_TIME,
SECONDS_IN_WAIT, STATE
from v\$session_wait
where sid = :sessao
/
!
}

###############################################
# FUNCAO QUE GERA TRACE DE SQL DE UMA SESSAO
###############################################
tracesql ()
{
sqlplus -S /nolog<<!
set feedback off
set linesize 200
conn ${CONN}
var sessao number
exec :sessao := '$1'
var serial number
exec :serial := '$2'
exec sys.dbms_system.set_sql_trace_in_session(:sessao,:serial,true);
!
}
###############################################
# FUNCAO PARA CRIAR USUARIO NO ORACLE
# Parametros:
#  1 - Nome do usuario
#  2 - Tablespace que o usuário irá acessar
#  3 - Quota na Tablespace ( Se nao for informado sera unlimited)
##############################################
criauser ()
{

validauser $1   # Funcao que valida se o usuario deve ser criado entre aspas duplas

sqlplus -S /nolog<<!
conn ${CONN}
create user $Usuario identified by $Usuario
default tablespace $2
quota $3 on $2;
grant resource,connect to $Usuario;
revoke unlimited tablespace from $Usuario;
!
}
############################################
# FUNCAO PARA CRIAR TABLESPACE NO ORACLE
# Parametros:
#   1 - Nome da Tablespace
#   2 - Nome do Datafile
#   3 - Tamanho do Datafile
############################################
criatbs ()
{
sqlplus -S /nolog<<!
conn ${CONN}
create tablespace $1 datafile '$2' size $3 autoextend off;
!
}
############################################
# FUNCAO PARA ADICIONAR DATAFILE NA TABLESPACE NO ORACLE
# Parametros:
#   1 - Nome da Tablespace
#   2 - Nome do Datafile
#   3 - Tamanho do Datafile
###########################################
adicionadatafileora ()
{
sqlplus -S /nolog<<!
conn ${CONN}
alter tablespace $1 add datafile '$2' size $3 autoextend off;
!
}

##########################
# Funcao que mostra resultados de auditoria de determinado objeto
# Argumentos: objeto de auditoria
##########################
show_audit ()
{
sqlplus -S /nolog<<!
conn ${CONN}
set verify off
col data format a20
col db_user format a10
col schema format a10
col object_name format a25
col policy_name format a25
col sql_text format a50
set linesize 200
set pagesize 50
select
TO_CHAR(TIMESTAMP,'DD/MM/YYYY HH24:MI:SS') DATA,
DB_USER,OBJECT_SCHEMA "SCHEMA",
OBJECT_NAME, POLICY_NAME,SQL_TEXT
from
dba_fga_audit_trail
WHERE
OBJECT_NAME=upper('$1')
/
!
}
##########################
# Funcao que mostra a sessao associada ao shared server
##########################
ver_sessao_shared_server ()
{
sqlplus -S /nolog<<!
conn ${CONN}
set pages 100
set lines 200
column username format a15 heading "USER ORACLE"
column osuser format a15 heading "USER SIST.OPER"
column sid format 999999 heading "SID"
column serial# heading "SERIAL#"

select ss.name,
ss.status,
s.sid,
s.serial#,
s.username,
s.osuser
from v\$session s,
v\$shared_server ss
where s.paddr = ss.paddr
order by 1;
!
}


##########################
# Funcao que mostra a sessao associada ao shared server
##########################
ver_lock_block ()
{
sqlplus -S /nolog<<!
conn ${CONN}
set pages 100
set lines 200
select  (select 'Usuário '||osuser||' S:'||a.sid||' P:'||process from v\$session where sid=a.sid)||
' bloqueou a tabela '||so.name||' ====> bloqueando '|| (select osuser||' S:'||b.sid||' P:'||process from v\$session where sid=b.sid)||' / '||
(select s.sql_text from v\$session z, v\$sqlarea s where z.sid=b.sid and z.sql_address = s.address) "LOCK"
from v\$lock a, v\$lock b, v\$locked_object o, sys.obj\$ so
where a.block = 1
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2
and o.session_id = a.sid
and o.object_id = so.obj#
/
!
}

################################################
#Funcao que exibe as informacoes dos discos ASM
###############################################

lista_asm () {
if [ "$LOGNAME" = "oracle" ]
then
export ORACLE_SID=`grep -i asm /etc/oratab |grep -v "^#" | cut -d ":" -f1`
sqlplus -S /nolog <<!
connect / as sysdba
select name, total_mb,free_mb from v\$asm_diskgroup;
!
else
echo "Para consultar o espaco no ASM você devera utilizar o usuario oracle"
fi
}

open_user () {
sqlplus -S /nolog<<!
conn ${CONN}
alter user $1 account unlock;
!
}

###############################################
# FUNCAO QUE VERIFICA SESSOES BLOQUEADORAS DO BANCO DE DADOS em RAC
###############################################
verlockrac () {
sqlplus -S /nolog<<!
conn ${CONN}
set linesize 200
column sid_blocker   format a15;
column sid_blocked   format a15;
column s_osuser    format a10;
column s_username  format a10;
column w_osuser    format a10;
column w_username  format a10;
column h_event format a30;
column w_event format a30;
select s.inst_id|| ':' || s.sid sid_blocker,
s.username s_username,
s.osuser s_osuser,
w.inst_id|| ':' || w.sid sid_blocked,
w.username w_username,
w.osuser w_osuser,
s.event h_event,
w.event w_event
from gv\$session s, gv\$session w
where w.blocking_session = s.sid
and w.blocking_instance = s.inst_id
/
!
}

###############################################
# FUNCAO QUE VERIFICA SESSOES DO BANCO DE DADOS
###############################################
orasessrac ()
{
sqlplus -S /nolog<<!
conn ${CONN}
set linesize 200
column x         format a1
column INST_ID   format 999;
column sid       format 9990;
column serial#   format 99990;
column spid      format 999990;
column osuser    format a10;
column username  format a10;
column server    format a1;
column machine   format a15;
#column program  format a20;
column program   format a18;
column logon     format a14;
column idle      format 999990;
column client_info format a15;

select decode(a.audsid, userenv('sessionid'), '*', ' ') x
,a.inst_id INST_ID
,a.sid
,a.serial#
,b.spid
,a.username
,a.osuser
,substr(a.client_info,1,15) client_info
,a.status
,decode(a.server, 'DEDICATED', 'D', 'S') server
,a.machine
,decode(a.username, '', 'oracle (' || c.name || ')' , substr(a.program,1,20)) program
,to_char(a.logon_time,'DD/MM/RR HH24:MI') logon
,(a.last_call_et/60) idle
from   gv\$session a
,gv\$process b
,gv\$bgprocess c
where  b.addr(+)  = a.paddr
and    c.paddr(+) = a.paddr
and    b.inst_id(+) = a.inst_id
and    c.inst_id(+) = a.inst_id
order by a.sid
/
!
}



###############################################
# Displays information on all long operations.
###############################################
show_longops ()
{
sqlplus -S /nolog<<!
conn ${CONN}
COLUMN inst_id FORMAT 99
COLUMN sid FORMAT 9999
COLUMN serial# FORMAT 99999
COLUMN username FORMAT A24
COLUMN module FORMAT A40
COLUMN progress_pct FORMAT 999
COLUMN elapsed FORMAT A10
COLUMN remaining FORMAT A10

SELECT s.inst_id,
       s.sid,
       s.serial#,
       s.sql_address,
       s.username,
       s.module,
       START_TIME,
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/(sl.totalwork+1)*100, 2) progress_pct,
       sysdate + TIME_REMAINING/3600/24 end_at
FROM   gv\$session s,
       gv\$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.inst_id = sl.inst_id
AND    s.serial# = sl.serial#
and   sl.sofar < sl.totalwork
ORDER BY progress_pct
/
!
}

###############################################
# List database schedulers jobs
###############################################
show_schedulers ()
{
sqlplus -S /nolog<<!
conn ${CONN}
set feed off
set long 5000
set arraysize 5
set lin 1000
set pages 200

col program_name for a40
col job_action for a50
col owner for a20
col REPEAT_INTERVAL for a30
col last_start_date for a43
col NEXT_RUN_DATE for a43

prompt
prompt +++++++++++++++++
prompt +++ SCHEDULES +++
prompt +++++++++++++++++
select owner, job_name, repeat_interval, enabled, last_start_date, next_run_date  from dba_scheduler_jobs;

prompt
prompt ++++++++++++
prompt +++ JOBS +++
prompt ++++++++++++
select owner, job_name, program_name, job_action, state from dba_scheduler_jobs;

prompt
prompt ++++++++++++++++++++
prompt +++ SCHEDULER LOGS +
prompt ++++++++++++++++++++
select * from dba_jobs_running;
!
}

###############################################
# List database jobs
###############################################
show_jobs ()
{
sqlplus -S /nolog<<!
conn ${CONN}
set feed off
set long 5000
set arraysize 5
set lin 1000
set pages 100

column job format 999999999
column log_user format a14
column what format a60
column interval format a40
column fail for  999

prompt
prompt ++++++++++++++++
prompt +++ JOBS +++++++
prompt ++++++++++++++++
select job,
       log_user,
       last_date,
       next_date,
       broken,
       failures fail,
       interval,
       substr(what, 1, 90) what
from   dba_jobs;

prompt
prompt +++++++++++++++++++
prompt +++ JOBS RUNNIG +++
prompt +++++++++++++++++++
select * from dba_jobs_running;
!
}

#Show active sessions
show_active_sess () {
sqlplus -S /nolog<<!
conn ${CONN}
set pagesize 100
set linesize 400
set pause off
set verify off

col username       format a10
col inst_id        format 9999999
col os_pid         format 9999999
col sessao         format a15
col machine        format a8
col programa       format a15 truncate
col machine_osuser format a20 truncate heading "MACHINE: OSUSER"
col log_time       format a10  heading 'HORARIO|DO LOGIN' justify right
col inicio_ult_cmd format a14 heading 'TEMPO ATIVO|OU INATIVO' justify right
col module         format a15 truncate
col event          format a30 truncate
col client_info    format a15 truncate
col opn                    format a15 truncate

select s.username,
       s.inst_id,
       to_number(p.spid) as os_pid,
                   p.pname,
       '''' || to_char(s.sid) || ',' || to_char(s.serial#) ||',@'||s.inst_id ||'''' as sessao,
       s.machine || ': ' || s.osuser as machine_osuser,
       SUBSTR(SUBSTR(s.program,INSTR(s.program,'\',-1)+1),1,30) as programa,
       decode( trunc(sysdate-s.logon_time),            -- dias conectado
               0, to_char(s.logon_time,'hh24:mi:ss'),  -- se menos de um dia
                  to_char(trunc(sysdate-s.logon_time, 1), 'fm99.0') || ' dias'
             ) as log_time,
       decode( trunc(last_call_et/86400),  -- 86400 seg = 1 dia
               0, '     ',                 -- se 0 dias, coloca brancos
                  to_char(trunc(last_call_et/60/60/24), '0') || 'd, ')
       || to_char( to_date(mod(last_call_et, 86400), 'SSSSS'),
                              'hh24"h"MI"m"SS"s"'
                 ) as inicio_ult_cmd,
       SUBSTR(SUBSTR(s.module,INSTR(s.module,'\',-1)+1),1,30)   as module,
      s.client_info,
          c.command_name opn,
      s.event,
          s.sql_id
from gv\$session s, gv\$process p, v\$sqlcommand c
where s.username is not null
and s.paddr = p.addr
and s.status = 'ACTIVE'
and s.inst_id = p.inst_id
and s.command=c.command_type
order by inicio_ult_cmd, status, s.username;
!
}
