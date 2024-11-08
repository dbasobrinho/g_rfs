-- |----------------------------------------------------------------------------|
-- | Objetivo   : VER PLANO DE ACESSO DE UM SQLID                               |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 10/08/2019                                                    |
-- | Exemplo    : @planx.sql 7a4umkg0dy4nu                                      | 
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
COLUMN current_instance NEW_VALUE current_instance NOPRINT; 
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual; 
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : XPLAN.DISPLAY_CURSOR                +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT |        1 : SQL_ID                                                      |
PROMPT |        2 : SQL_CHILD_NUMBER                                            |
PROMPT |   FORMAT : ALL allstats +peeked_binds -alias last            [DEFAULT] |
PROMPT |          : TYPICAL allstats +peeked_binds last                         |
PROMPT |          : ADVANCED allstats last                                      | 
PROMPT |          : ALLSTATS LAST +cost +bytes                                  | 
PROMPT |          : ALL iostats +peeked_binds -alias last                       |  
PROMPT |          : SERIAL allstats  +peeked_binds last                         | 
PROMPT +------------------------------------------------------------------------+
set lines 600
set pages 600
SET FEEDBACK    0
alter session set statistics_level = all; 
SET FEEDBACK    OFF
SET ECHO        OFF
SET HEADING     ON
SET LINES       600
SET PAGES       600
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
COL sql_id               FOR A16;
COL predicate            FOR A70;
COL object_owner         FOR A21; 
COL object_name          FOR A35;
COL policy_group         FOR A21; 
COL PLAN_TABLE_OUTPUT    FOR A500 word_wrapped
accept XX_FORMAT char prompt 'ENTER FORMAT : ' default "ALL allstats +peeked_binds -alias last"
--========================================================================
@tun_xplan.display_cursor.sql '&1' '&2' "&XX_FORMAT"
--========================================================================
UNDEF XX_FORMAT
UNDEF 1
UNDEF 2
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;