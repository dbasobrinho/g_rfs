--##  
-- -------------------------------------------------------------------------------------------------
-- Nome do Arquivo : https://github.com/dbasobrinho/g_gold/blob/main/tun_plan.display_awr.sql
-- Autor           : Roberto Fernandes Sobrinho	
-- Descrição       : Exibe Plano de Acesso com sequencia de execução
-- Requisitos      : DBA
-- Sintaxe Chamada : @tun_plan.display_awr.sql 
-- Dependência     : DBMS_XPLAN
-- Data de Criação : 24/03/2024
-- Versão do Banco : 11g Acima 
-- Comentários     : 
-- -------------------------------------------------------------------------------------------------
--##
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss'; 
COLUMN current_instance NEW_VALUE current_instance NOPRINT; 
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | https://github.com/dbasobrinho/g_gold/blob/main/tun_plan.display_awr.sql                  |
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | Report   : DBMS_XPLAN.DISPLAY_CURSOR                             +-+-+-+-+-+-+-+-+-+-+-+  |
PROMPT | Instance : &current_instance                                     |d|b|a|s|o|b|r|i|n|h|o|  |
PROMPT | Version  : 1.1                                                   +-+-+-+-+-+-+-+-+-+-+-+  |
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT |        1 : SQL_ID                                                                         |
PROMPT |        2 : SQL_CHILD_NUMBER                                                               |
PROMPT | FORMAT 3 : ADVANCED allstats last                            [DEFAULT]                    |
PROMPT |          : TYPICAL allstats +peeked_binds last                                            |
PROMPT |          : ALL allstats +peeked_binds -alias last                                         | 
PROMPT |          : ALLSTATS LAST +cost +bytes                                                     | 
PROMPT |          : ALL iostats +peeked_binds -alias last                                          |  
PROMPT |          : SERIAL allstats  +peeked_binds last                                            |  
PROMPT +-------------------------------------------------------------------------------------------+

SET LINES       201
SET PAGES       300  
--Desative a quebra automática
SET WRAP OFF;  
--desative a impressão de cabeçalhos repetidos
SET PAGES 0;    
SET FEEDBACK OFF
SET TERMOUT OFF;
alter session set statistics_level = all; 
SET TRIMOUT     ON
SET FEEDBACK    OFF
SET ECHO        OFF
SET HEADING     ON
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMSPOOL   ON
SET VERIFY      OFF

COL sql_id               FOR A16;
COL predicate            FOR A70;
COL object_owner         FOR A21; 
COL object_name          FOR A35;
COL policy_group         FOR A21; 
COL PLAN_TABLE_OUTPUT    FOR A500 word_wrapped
accept XX_SQLID      char prompt 'SQLID  (*): '
accept XX_PLAN_HASH  char prompt 'PLAN_HASH : ' default "0"
accept XX_FORMAT     char prompt 'FORMAT    : ' default "ADVANCED allstats last"
--========================================================================
SELECT * FROM TABLE (dbms_xplan.display_awr('&XX_SQLID','&XX_PLAN_HASH',null,'&XX_FORMAT'));
--========================================================================
UNDEF XX_FORMAT
UNDEF XX_SQLID
UNDEF XX_PLAN_HASH
SET TERMOUT OFF;
--@$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;

--->>   DBMS_XPLAN.DISPLAY_AWR( 
--->>      sql_id            IN      VARCHAR2,
--->>      plan_hash_value   IN      NUMBER DEFAULT NULL,
--->>      db_id             IN      NUMBER DEFAULT NULL,
--->>      format            IN      VARCHAR2 DEFAULT TYPICAL);