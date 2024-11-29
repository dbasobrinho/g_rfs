-- |
-- +-------------------------------------------------------------------------------------------+
-- | Objetivo   : SQLPATCH SQL ID, ADD HINT GATHER_PLAN_STATISTICS                             |
-- | Criador    : Roberto Fernandes Sobrinho                                                   |
-- | Data       : 29/11/2024                                                                   |
-- | Exemplo    : @tun_sqlpatch_add_gather_plan_statistics.sql                                 |  
-- | Arquivo    : tun_sqlpatch_add_gather_plan_statistics.sql                                  |
-- | Referncia  :                                                                              |
-- | Modificacao:                                                                              |
-- +-------------------------------------------------------------------------------------------+
-- |                                                                https://dbasobrinho.com.br | 
-- +-------------------------------------------------------------------------------------------+
-- |"O Guina não tinha dó, se ragir, BUMMM! vira pó!"
-- +-------------------------------------------------------------------------------------------+
WHENEVER SQLERROR EXIT SQL.SQLCODE;
WHENEVER OSERROR EXIT;
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS';
EXEC dbms_application_info.set_module( module_name => 'tun[sqlpatch_add]', action_name =>  'tun[sqlpatch_add]');
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +--------------------------------------------------------------------------------------------+
PROMPT | https://github.com/dbasobrinho/g_gold/blob/main/tun_sqlpatch_add_gather_plan_statistics.sql|
PROMPT +--------------------------------------------------------------------------------------------+
PROMPT | Script   : SQLPATCH SQL ID, ADD HINT GATHER_PLAN_STATISTICS      +-+-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instancia: &current_instance                                     |d|b|a|s|o|b|r|i|n|h|o|   |
PROMPT | Versao   : 1.0                                                   +-+-+-+-+-+-+-+-+-+-+-+   |
PROMPT +--------------------------------------------------------------------------------------------+
PROMPT
SET ECHO        OFF
SET FEEDBACK    10
SET HEADING     ON
SET LINES       188
SET PAGES       300 

PROMPT
ACCEPT vv_sql_id   CHAR PROMPT "SQL ID       [*] : "  
ACCEPT vv_child_no CHAR PROMPT "CHILD_NUMBER [0] : "  default '0'
PROMPT

SET ECHO        OFF
SET FEEDBACK    off
SET HEADING     ON
SET LINES       188
SET PAGES       300 
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
set ECHO        ON

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    m_clob  clob; 
BEGIN
    SELECT sql_fulltext into m_clob
      FROM v$sql
     WHERE sql_id = '&&vv_sql_id'
       AND child_number = &&vv_child_no ;
 
    SYS.DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH(
        sql_text    => m_clob,
        hint_text   => 'GATHER_PLAN_STATISTICS' ,
        name        => 'GUINA_Patch_&&vv_sql_id&&vv_child_no'
        ); 
END;
/
set echo off;

col name            format a50
col FORCE_MATCHING  format a08
STATUS              format a10
created             format a23

SELECT name, created,  FORCE_MATCHING, STATUS FROM dba_sql_patches where name = 'GUINA_Patch_&&vv_sql_id&&vv_child_no'
/
select 'BEGIN sys.DBMS_SQLDIAG.drop_sql_patch(name => ''GUINA_Patch_&&vv_sql_id&&vv_child_no''); END; '||chr(10)||'/' as APAGA_DEPOIS_URGENTE from dual
/
UNDEFINE vv_sql_id 
UNDEFINE vv_child_no
UNDEFINE HINT_TEXT
SET FEEDBACK  ON;
set verify ON;
PROMPT.                                                     ______ _ ___
PROMPT.                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+-+
PROMPT.                                         _   _   _   / / (_| \__ \ |d|b|a|s|o|b|r|i|n|h|o|
PROMPT.                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+-+
PROMPT.                                         
