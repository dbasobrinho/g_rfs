---- Mostrar instance(s) do banco
set lines 350
set pages 50000
set time on
set timing on
col HOST_NAME format a15
col VERSION format a10
col status format a10
col instance_name format a10
col name format a15
col logins format a10
col open_mode format a10
col database_role format a15
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';:> 
SET TERMOUT ON;
set timing off


PROMPT
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : TPS DETALHADO PERIODO                 +-+-+-+-+-+-+-+-+-+-+ |
PROMPT | Instance : &current_instance                     |r|f|s|o|b|r|i|n|h|o| |
PROMPT | Version  : 1.0                                   +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
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
SET COLSEP '|'

---- Mostrar instance(s) do banco
set lines 350
set pages 50000
set time on
set timing off
col HOST_NAME format a30
col VERSION format a20
col status format a10
col instance_name format a10
col name format a15
col logins format a10
col open_mode format a10
col database_role format a15
select a.INST_ID, INSTANCE_NAME, HOST_NAME, VERSION, NAME, STARTUP_TIME, STATUS, OPEN_MODE,DATABASE_ROLE, LOGINS, SYSDATE
  from gv$instance a,gv$database b
  where a.INST_ID = b.INST_ID;

col PRCT format 999.99
col DESCRIPTION format a40
col PRCT format 999.99
col DESCRIPTION format a60

PROMPT +------------------------------------------------------------------------+
PROMPT | +-+-+-+-+-+-+-+-+-+-+  ENTRE COM OS PARAMETROS   +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT DATA_INI CHAR PROMPT 'Data Inicial (DD/MM/YYYY HH24:MI:SS) = '
ACCEPT DATA_FIM CHAR PROMPT 'Data Final   (DD/MM/YYYY HH24:MI:SS) = '
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | +-+-+-+-+-+-+-+-+-+-+  RESUMIDO                  +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
PROMPT
select *  from
(SELECT  /* +PARALLEL (8) */ TO_CHAR(TRANSACTION_BEGIN_TIME, 'YYYY/MM/DD HH24:MI') AS DT_HORARIO,
       COUNT(*) AS TPS--,  AU.ID_RESPONSE_CODE, substr(CD.DESCRIPTION,1,40) DESCRIPTION
        FROM AU_OPEN_TRANSACTION AU, AU_RESPONSE_CODE CD
       WHERE  AU.ID_RESPONSE_CODE = CD.ID_RESPONSE_CODE
	   and ID_TRANSACTION >=
             ((SELECT MAX(ID_TRANSACTION) - 1000000
                 FROM AU_OPEN_TRANSACTION AUOT))
         AND AU.TRANSACTION_PAN NOT IN ('4058801720859010')
         AND AU.TRANSACTION_BEGIN_TIME >= to_date('&DATA_INI', 'dd/mm/yyyy hh24:mi:ss')
         AND AU.TRANSACTION_BEGIN_TIME <= to_date('&DATA_FIM', 'dd/mm/yyyy hh24:mi:ss')
       GROUP BY TO_CHAR(TRANSACTION_BEGIN_TIME,'YYYY/MM/DD HH24:MI') --,AU.ID_RESPONSE_CODE, substr(CD.DESCRIPTION,1,40)
       ORDER BY to_char(TRANSACTION_BEGIN_TIME,'YYYY/MM/DD HH24:MI') DESC, TPS desc) --where TPS > 150
/
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | +-+-+-+-+-+-+-+-+-+-+  DETALHADO                 +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
PROMPT
select *  from
(SELECT  /* +PARALLEL (8) */ TO_CHAR(TRANSACTION_BEGIN_TIME, 'YYYY/MM/DD HH24:MI') AS DT_HORARIO,
       COUNT(*) AS TPS,  AU.ID_RESPONSE_CODE, substr(CD.DESCRIPTION,1,40) DESCRIPTION
        FROM AU_OPEN_TRANSACTION AU, AU_RESPONSE_CODE CD
       WHERE  AU.ID_RESPONSE_CODE = CD.ID_RESPONSE_CODE
	   and ID_TRANSACTION >=
             ((SELECT MAX(ID_TRANSACTION) - 1000000
                 FROM AU_OPEN_TRANSACTION AUOT))
         AND AU.TRANSACTION_PAN NOT IN ('4058801720859010')
         AND AU.TRANSACTION_BEGIN_TIME >= to_date('&DATA_INI', 'dd/mm/yyyy hh24:mi:ss')
         AND AU.TRANSACTION_BEGIN_TIME <= to_date('&DATA_FIM', 'dd/mm/yyyy hh24:mi:ss')
       GROUP BY TO_CHAR(TRANSACTION_BEGIN_TIME,'YYYY/MM/DD HH24:MI'),AU.ID_RESPONSE_CODE, substr(CD.DESCRIPTION,1,40)
       ORDER BY to_char(TRANSACTION_BEGIN_TIME,'YYYY/MM/DD HH24:MI') DESC, TPS desc) --where TPS > 150
/

set timing on

UNDEF DATA_INI
UNDEF DATA_FIM
