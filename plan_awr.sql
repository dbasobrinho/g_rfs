-- |----------------------------------------------------------------------------|
-- | Objetivo   : VER PLANO DE ACESSO DE UM SQLID                               |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 10/08/2019                                                    |
-- | Exemplo    : @plan_awr.sql 7a4umkg0dy4nu                                   |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DBMS_XPLAN.DISPLAY_AWR              +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
PROMPT |   FORMAT : 'DEFAULT'                                                   |
PROMPT +------------------------------------------------------------------------+
set lines 1000
set pages 1000
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
--========================================================================
select * from table(dbms_xplan.display_awr('&1'));
--========================================================================
UNDEF sssql_id
UNDEF 1
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;
