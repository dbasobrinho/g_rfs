-- |----------------------------------------------------------------------------|
-- | Objetivo   : LOCALIZAR MOTIVO DO CHILD CURSOR                              |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 05/10/2018                                                    | 
-- | Exemplo    : @child_cursor_by_sqlid 4hm6rqjhshv2s                          |
-- | Arquivo    : child_cursor_by_sqlid.sql                                     | 
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : LOCALIZAR MOTIVO DO CHILD CURSOR    +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    on
SET HEADING     ON
SET LINES       10000
SET PAGES       10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a17  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a20
col logon_time   format a10
col hold         format a06
col sessionwait  format a25
col status       format a08
col hash_value   format a10
col sc_wait      format a06 HEADING 'WAIT'
col module       format a08 HEADING 'MODULE'
SET COLSEP '|'
COLUMN INST_ID          FORMAT 99      head "INST_ID|"
COLUMN sql_ids          FORMAT 999999  head "SQL_IDS|"
COLUMN cursors          FORMAT 999999  head "CURSORS|"
COLUMN CHEILD#          FORMAT 999999  head "CHEILD#|"
COLUMN PARSE_CALLS      FORMAT 999999  head "PARSE|CALLS"
COLUMN SQL_ID           FORMAT A13     head "SQL_ID|"
COLUMN reason_not_shared FORMAT A80    HEAD "REASON_NOT_SHARED"
COLUMN val              FORMAT A13     head "VAL|"
COLUMN L_VERSIONS       FORMAT 999999  head "LOADED|VERSIONS"
COLUMN OPEN_VERSIONS    FORMAT 999999  head "OPEN|VERSIONS"
COLUMN OBJECT_STATUS    FORMAT A08     head "OBJECT|STATUS"
COLUMN FIRST_LOAD_TIME  FORMAT A19     head "FIRST|LOAD_TIME"
COLUMN LAST_LOAD_TIME   FORMAT A19     head "LAST|LOAD_TIME"

--ACCEPT sssql_txt  char   PROMPT 'SQL_ID = '

select INST_ID, SQL_ID, reason_not_shared, count(*) cursors, count(distinct sql_id) sql_ids, val
from gv$sql_shared_cursor
unpivot(val for reason_not_shared in(
  UNBOUND_CURSOR,SQL_TYPE_MISMATCH,OPTIMIZER_MISMATCH,OUTLINE_MISMATCH,
  STATS_ROW_MISMATCH,LITERAL_MISMATCH,FORCE_HARD_PARSE,EXPLAIN_PLAN_CURSOR,
  BUFFERED_DML_MISMATCH,PDML_ENV_MISMATCH,INST_DRTLD_MISMATCH,SLAVE_QC_MISMATCH,
  TYPECHECK_MISMATCH,AUTH_CHECK_MISMATCH,BIND_MISMATCH,DESCRIBE_MISMATCH,
  LANGUAGE_MISMATCH,TRANSLATION_MISMATCH,BIND_EQUIV_FAILURE,INSUFF_PRIVS,
  INSUFF_PRIVS_REM,REMOTE_TRANS_MISMATCH,LOGMINER_SESSION_MISMATCH,INCOMP_LTRL_MISMATCH,
  OVERLAP_TIME_MISMATCH,EDITION_MISMATCH,MV_QUERY_GEN_MISMATCH,USER_BIND_PEEK_MISMATCH,
  TYPCHK_DEP_MISMATCH,NO_TRIGGER_MISMATCH,FLASHBACK_CURSOR,ANYDATA_TRANSFORMATION,
  PDDL_ENV_MISMATCH,TOP_LEVEL_RPI_CURSOR,DIFFERENT_LONG_LENGTH,LOGICAL_STANDBY_APPLY,
  DIFF_CALL_DURN,BIND_UACS_DIFF,PLSQL_CMP_SWITCHS_DIFF,CURSOR_PARTS_MISMATCH,
  STB_OBJECT_MISMATCH,CROSSEDITION_TRIGGER_MISMATCH,PQ_SLAVE_MISMATCH,TOP_LEVEL_DDL_MISMATCH,
  MULTI_PX_MISMATCH,BIND_PEEKED_PQ_MISMATCH,MV_REWRITE_MISMATCH,ROLL_INVALID_MISMATCH,
  OPTIMIZER_MODE_MISMATCH,PX_MISMATCH,MV_STALEOBJ_MISMATCH,FLASHBACK_TABLE_MISMATCH,
  LITREP_COMP_MISMATCH,PLSQL_DEBUG,LOAD_OPTIMIZER_STATS,ACL_MISMATCH,
  FLASHBACK_ARCHIVE_MISMATCH,LOCK_USER_SCHEMA_FAILED,REMOTE_MAPPING_MISMATCH,LOAD_RUNTIME_HEAP_FAILED,
  HASH_MATCH_FAILED,PURGED_CURSOR,BIND_LENGTH_UPGRADEABLE,USE_FEEDBACK_STATS
))
where SQL_ID = '&1'
and val = 'Y'
group by reason_not_shared, val, INST_ID, SQL_ID
order by CURSORS||val desc , reason_not_shared desc, 3, 1
/

UNDEF 1
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;
