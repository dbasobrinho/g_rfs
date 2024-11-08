-- |
-- +-------------------------------------------------------------------------------------------+
-- | Objetivo   : Sessoes Ativas                                                               |
-- | Criador    : Roberto Fernandes Sobrinho                                                   |
-- | Data       : 15/12/2015                                                                   |
-- | Exemplo    : @size_fra_recovery_file_dest.sql                                             |  
-- | Arquivo    : size_fra_recovery_file_dest.sql                                              |
-- | Referncia  :                                                                              |
-- | Modificacao: 1.0 - 06/09/2024 - DBA Sobrinho                                              |
-- +-------------------------------------------------------------------------------------------+
-- |                                                                https://dbasobrinho.com.br |
-- +-------------------------------------------------------------------------------------------+
-- |"O Guina não tinha dó, se ragir, BUMMM! vira pó!"
-- +-------------------------------------------------------------------------------------------+
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS';
EXEC dbms_application_info.set_module( module_name => 's[s.sql]', action_name =>  's[s.sql]');
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | https://github.com/dbasobrinho/g_gold/blob/main/s.sql                                     |
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | Script   : Verificar Espaco da FRA                               +-+-+-+-+-+-+-+-+-+-+-+  |
PROMPT | Instancia: &current_instance                                     |d|b|a|s|o|b|r|i|n|h|o|  |
PROMPT | Versao   : 1.0                                                   +-+-+-+-+-+-+-+-+-+-+-+  |
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT
SET ECHO        OFF
SET FEEDBACK    10
SET HEADING     ON
SET LINES       188
SET PAGES       300 
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS 
CLEAR BREAKS
CLEAR COMPUTES
col nome for a32
col tamanho_mb for 999,999,999
col espaco_recuperavel_mb for 999,999,999
col utilizado_mb for 999,999,999
col pct_usado for 999
col espaco_livre_mb for 999,999,999
col limite_max_mb for 999,999,999

SELECT name AS "Nome"
     , ceil(space_limit / 1024 / 1024) AS "Tamanho_MB"
     , ceil(space_used / 1024 / 1024) AS "Utilizado_MB"
     , ceil(space_reclaimable / 1024 / 1024) AS "Espaco_Recuperavel_MB"
     , decode(nvl(space_used, 0), 0, 0, ceil(((space_used - space_reclaimable) / space_limit) * 100)) AS "Pct_Usado"
     , ceil((space_limit - space_used + space_reclaimable) / 1024 / 1024) AS "Espaco_Livre_MB"
     , ceil(space_limit / 1024 / 1024) AS "Limite_Max_MB"
  FROM v$recovery_file_dest
ORDER BY name
/
SET FEEDBACK on