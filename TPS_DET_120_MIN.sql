ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
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
SET TERMOUT ON;

PROMPT
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : TPS DETALHADO ULTIMAS 2 HORAS         +-+-+-+-+-+-+-+-+-+-+ |
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
set timing on
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
Select a.*,b.QTDE TOTAL, b.INICIO, b.FIM, round(a.QTDE/b.QTDE*100,2) PRCT
from
(SELECT AU.ID_RESPONSE_CODE, substr(CD.DESCRIPTION,1,40) DESCRIPTION, count(*) QTDE, TO_CHAR(min(AU.TRANSACTION_BEGIN_TIME),'DD/MM/YYYY HH24:MI:SS') INICIO_CODIGO, TO_CHAR(max(AU.TRANSACTION_BEGIN_TIME),'DD/MM/YYYY HH24:MI:SS') FIM_CODIGO
FROM AU_OPEN_TRANSACTION AU, AU_RESPONSE_CODE CD
WHERE AU.ID_TRANSACTION >= ((SELECT MAX(ID_TRANSACTION) - 100000 FROM AU_OPEN_TRANSACTION AUOT))
 AND AU.TRANSACTION_PAN NOT IN ('4058801720859010') 
 AND AU.TRANSACTION_BEGIN_TIME >= SYSDATE-120/24/60  
 AND AU.ID_RESPONSE_CODE = CD.ID_RESPONSE_CODE --AND AU.ID_RESPONSE_CODE = '51'
GROUP BY AU.ID_RESPONSE_CODE,  substr(CD.DESCRIPTION,1,40)) a,
(SELECT 'XX' ID_RESPONSE_CODE, 'TOTAL' DESCRIPTION, count(*) QTDE, TO_CHAR(min(AU.TRANSACTION_BEGIN_TIME),'DD/MM/YYYY HH24:MI:SS') INICIO, TO_CHAR(max(AU.TRANSACTION_BEGIN_TIME),'DD/MM/YYYY HH24:MI:SS') FIM
FROM AU_OPEN_TRANSACTION AU, AU_RESPONSE_CODE CD
WHERE AU.ID_TRANSACTION >= ((SELECT MAX(ID_TRANSACTION) - 100000 FROM AU_OPEN_TRANSACTION AUOT))
 AND AU.TRANSACTION_PAN NOT IN ('4058801720859010') 
 AND AU.TRANSACTION_BEGIN_TIME >= SYSDATE-120/24/60  
 AND AU.ID_RESPONSE_CODE = CD.ID_RESPONSE_CODE --AND AU.ID_RESPONSE_CODE = '51'
GROUP BY 'ZZ', 'TOTAL') b
ORDER BY PRCT desc
/	

