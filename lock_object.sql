-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : lock01.sql                                                      |
-- | CLASS    :                                                                 |
-- | PURPOSE  :                                                                 |
-- | NOTE     :                                                                 |
-- |                                                                            |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sessoes em Locked      [lock01.sql]                         |
PROMPT | Instance : &current_instance                                           |
prompt +------------------------------------------------------------------------+

set echo        off
set feedback    6
set heading     on
set linesize    500
set pagesize    50000
set termout     on
set timing      off
set trimout     on
set trimspool   on
set verify      off

clear columns
clear breaks
clear computes

set lines 400
set pages 100
column sess                     format a16
column "user/os_user"           format a15
column object        			format a40
column state          			format a60

column sopid        			format a07
column logon_time   			format a20
column idle         			format a10
column ST           			format a2
column machine      			format a15
column module       			format a15
column type         			format a4
column dslmode      			format a15	
column dsrequest    			format a15	
column req          			format 999
column command_kill 			format a74		

SELECT s.sid || ',' || s.serial#|| case when s.inst_id is not null then ',@' || s.inst_id end as sess
      , substr(nvl(s.username,'(oracle)'),1,7)||'/'||substr(s.osuser,1,8) "USER/OS_USER"
	  , substr(a.OBJECT_TYPE||'-'||a.owner||'.'||a.object_name,1,40) object
	  , decode(s.state,'WAITING','Waiting '||seconds_in_wait,'Working '||wait_time / 100)||' '||event state
	  , s.sql_id
      --, s.last_call_et
      --, s.seconds_in_wait
      --,p1
      --,p2
      --,P3
 --      decode(b.locked_mode, 0, 'None', 
 --                           1, 'Null (NULL) ()', 
 --                           2, 'Row-S (SS)   (Lock indica que a transação possui linhas ""locada"s" exclusivamente, mas ainda não as alterou)', 
 --                           3, 'Row-X (SX)   (Lock indica que a transação possui linhas "locadas" exclusivamente e já as alterou)', 
 --                           4, 'Share (S)    (Lock indica que foi obtido através da instrução "LOCK TABLE table IN SHARE MODE")', 
 --                           5, 'S/Row-X (SSX)(Lock indica que somente uma transação pode obtê-lo por vez)', 
 --                           6, 'Exclusive (X)(Lock indica que permite apenas que as outras sessões acessem a tabela através de instruções SELECTs) ', 
 --                           b.locked_mode) locked_mode
  from dba_objects a, gv$locked_object b, gv$session s
 where a.object_id = b.object_id
   and s.sid       = b.session_id
   and s.inst_id   = b.inst_id
 order by seconds_in_wait desc, s.machine, nvl(b.oracle_username, '(oracle)')
/


