undef user


accept user prompt 'Qual o Usuário você deseja verificar? '

---------------------------- Session ---------------------------------------------------------
-- duplica a qtde de sessões que estão no banco por conta da gv$process

clear columns
set linesize 200
column USERNAME format a10
column STATUS format a8
column OSUSER format a8
column MACHINE format a15
column PROGRAM format a20
column LOGON_TIME format a19
column EVENT format a30
column SID format a7
column SERIAL# format a7
column "Inst Bloq" format a1
column "Instancia" format a1
column "Time" format a6
column "Block" format a7
column "SPID" format a10
alter session set nls_date_format="dd-mm-yyyy hh24:mi:ss";


select 
to_char(s.inst_id) "Instancia",
to_char(s.SID) "SID",
to_char(s.SERIAL#) "SERIAL#",
s.USERNAME,
s.STATUS,
--s.OSUSER,
s.MACHINE,
s.PROGRAM,
s.LOGON_TIME,
to_char(s.LAST_CALL_ET) "Time",
s.SQL_ID,
s.PREV_SQL_ID,
s.EVENT,
--p.SPID "SPID",
to_char(s.BLOCKING_INSTANCE) "Inst Bloq",
to_char(s.BLOCKING_SESSION) "Block"
from gv$session s
inner join gv$process p on p.ADDR=s.PADDR
where s.username in UPPER('&user');

