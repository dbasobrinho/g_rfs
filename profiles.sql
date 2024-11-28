-- |----------------------------------------------------------------------------|
-- | Objetivo   : Validação de parametros                                       |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 18/19/2024                                                    |
-- | Exemplo    : @profile                                                            |
-- | Arquivo    : profile.sql                                                         |
-- | Modificacao: V2.1 - 18/19/2024 - rfsobrinho                                |
-- +----------------------------------------------------------------------------+
-- |kill -9 $(ps -ef | grep -v grep | grep 'LOCAL=NO' | grep pbackS | awk '{print $2}')
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Validação de parametros             +-+-+-+-+-+-+-+-+-+-+   |
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

BREAK ON profile SKIP 1

col profile        format a25
col limit     format a40

SELECT profile,
       resource_type,
       resource_name,
       limit
FROM   dba_profiles
--WHERE  profile LIKE (DECODE(UPPER('&1'), 'ALL', '%', UPPER('%&1%')))
ORDER BY profile, resource_type, resource_name
/

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

