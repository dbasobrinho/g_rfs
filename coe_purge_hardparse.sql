-->>#===========================================================================================================
-->>#Referencia : coe_purge_hardparse.sql
-->>#Assunto    : Remove SQLID da SHAREDPOOL quando nao usa BIND
-->>#Criado por : Roberto Fernandes Sobrinho
-->>#Data       : 30/06/2019 
-->>#Ref        : 
-->>#Alteracoes :
-->>#           :
-->>#============================================================================================================
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : PURGE HARDPARSE SHAREDPOOL          +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       600
SET PAGES       600 
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
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
@sga_shared_pool_used.sql
PRO ********************
PRO *** BEFORE FLUSH ***
PRO ********************
select u.username ,  PLAN_HASH_VALUE, child_number, sum(executions) executions, is_shareable, count(distinct(sql_id)) tot
from   gv$sql, dba_users u
where PLAN_HASH_VALUE > 0
and PARSING_USER_ID = u.USER_ID and u.USER_ID <> 0
group by u.username ,  PLAN_HASH_VALUE, child_number,  is_shareable 
having count(distinct(sql_id)) > 50
order by PLAN_HASH_VALUE
/

----SELECT  /*+ PARALLEL */address, hash_value
----  FROM v$sqlarea
----  where PLAN_HASH_VALUE in (
----select distinct z.PLAN_HASH_VALUE
----from(
----select  PLAN_HASH_VALUE, count(distinct(sql_id)) tot
----from   gv$sql, dba_users u
----where PLAN_HASH_VALUE > 0
----and PARSING_USER_ID = u.USER_ID and u.USER_ID <> 0
----group by u.username ,  PLAN_HASH_VALUE, child_number,  is_shareable 
----having count(distinct(sql_id)) > 50) z
----)
----/
set echo on;
BEGIN
  FOR i IN (SELECT  address, hash_value
			  FROM v$sqlarea
			  where PLAN_HASH_VALUE in (
			select distinct z.PLAN_HASH_VALUE
			from(
			select  PLAN_HASH_VALUE, count(distinct(sql_id)) tot
			from   gv$sql, dba_users u
			where PLAN_HASH_VALUE > 0
			and PARSING_USER_ID = u.USER_ID and u.USER_ID <> 0
			group by u.username ,  PLAN_HASH_VALUE, child_number,  is_shareable 
			having count(distinct(sql_id)) > 50) z ))
    LOOP
    SYS.DBMS_SHARED_POOL.PURGE(i.address || ',' || i.hash_value, 'C');
  END LOOP;
END;
/
set echo off;
PRO ********************
PRO *** AFTER  FLUSH ***
PRO ********************
select u.username ,  PLAN_HASH_VALUE, child_number, sum(executions) executions, is_shareable, count(distinct(sql_id)) tot
from   gv$sql, dba_users u
where PLAN_HASH_VALUE > 0
and PARSING_USER_ID = u.USER_ID and u.USER_ID <> 0
group by u.username ,  PLAN_HASH_VALUE, child_number,  is_shareable 
having count(distinct(sql_id)) > 50
order by PLAN_HASH_VALUE
/
@sga_shared_pool_used.sql