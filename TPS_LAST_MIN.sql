---- Mostrar instance(s) do banco
--
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
SET ECHO        OFF
set timing      OFF
SET UNDERLINE   	'-'
SET COLSEP      '|'
SET FEEDBACK    OFF
SET SQLBLANKLINES ON
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
SET TERMOUT ON;

---ACCEPT ENTER_MINUTOS CHAR FORMAT 'A20' DEFAULT '2' PROMPT 'QTDE MINUTOS [2]:  '

PROMPT
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : TPS ULTIMO MINUTO                     +-+-+-+-+-+-+-+-+-+-+ |
PROMPT | Instance : &current_instance                     |r|f|s|o|b|r|i|n|h|o| |
PROMPT | Version  : 1.0                                   +-+-+-+-+-+-+-+-+-+-+ |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    off
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
SET UNDERLINE   	'='
---- Mostrar instance(s) do banco
set lines 500
set pages 500 
set time on
col HOST_NAME format a30
col VERSION format a20
col status format a10
col instance_name format a10
col name format a15
col logins format a10
col open_mode format a10
col database_role format a15

col PRCT        format a08  HEADING  "%"        JUSTIFY CENTER
col DESCRIPTION format a40  HEADING "DESCRICAO" JUSTIFY CENTER
col QTDE        format 99999999  HEADING "QTDE" JUSTIFY CENTER
col TOTAL       format 99999999  HEADING "TOT AMOSTRA" JUSTIFY CENTER
col INICIO_CODIGO format a19  HEADING "MIN CODIGO" JUSTIFY CENTER
col FIM_CODIGO    format a19  HEADING "MAX CODIGO" JUSTIFY CENTER
col INICIO        format a19  HEADING "MIN AMOSTRA" JUSTIFY CENTER
col FIM           format a19  HEADING "MAX AMOSTRA" JUSTIFY CENTER

SELECT Z.ID, upper(Z.DESCRIPTION) DESCRIPTION, Z.QTDE, Z.INICIO_CODIGO, Z.FIM_CODIGO, Z.TOTAL, Z.INICIO, Z.FIM, lpad(to_char(Z.PRCT,'FM900D00', 'NLS_NUMERIC_CHARACTERS = '',.'''),6,' ')|| ' %' PRCT
FROM(
Select a.*,b.QTDE TOTAL, b.INICIO, b.FIM, round(a.QTDE/b.QTDE*100,2)PRCT
from
(SELECT AU.ID_RESPONSE_CODE ID, substr(CD.DESCRIPTION,1,40) DESCRIPTION, count(*) QTDE, TO_CHAR(min(AU.TRANSACTION_BEGIN_TIME),'DD/MM/YYYY HH24:MI:SS') INICIO_CODIGO, TO_CHAR(max(AU.TRANSACTION_BEGIN_TIME),'DD/MM/YYYY HH24:MI:SS') FIM_CODIGO
FROM AU_OPEN_TRANSACTION AU, AU_RESPONSE_CODE CD
WHERE AU.ID_TRANSACTION >= ((SELECT MAX(ID_TRANSACTION) - 100000 FROM AU_OPEN_TRANSACTION AUOT))
 AND AU.TRANSACTION_PAN NOT IN ('4058801720859010') 
 AND AU.TRANSACTION_BEGIN_TIME >= SYSDATE-1/24/60  
 AND AU.ID_RESPONSE_CODE = CD.ID_RESPONSE_CODE --AND AU.ID_RESPONSE_CODE = '51'
GROUP BY AU.ID_RESPONSE_CODE,  substr(CD.DESCRIPTION,1,40)) a,
(SELECT 'XX' ID, 'TOTAL' DESCRIPTION, count(*) QTDE, TO_CHAR(min(AU.TRANSACTION_BEGIN_TIME),'DD/MM/YYYY HH24:MI:SS') INICIO, TO_CHAR(max(AU.TRANSACTION_BEGIN_TIME),'DD/MM/YYYY HH24:MI:SS') FIM
FROM AU_OPEN_TRANSACTION AU, AU_RESPONSE_CODE CD
WHERE AU.ID_TRANSACTION >= ((SELECT MAX(ID_TRANSACTION) - 100000 FROM AU_OPEN_TRANSACTION AUOT))
 AND AU.TRANSACTION_PAN NOT IN ('4058801720859010') 
 AND AU.TRANSACTION_BEGIN_TIME >= SYSDATE-1/24/60 
 AND AU.ID_RESPONSE_CODE = CD.ID_RESPONSE_CODE --AND AU.ID_RESPONSE_CODE = '51'
GROUP BY 'ZZ', 'TOTAL') b
ORDER BY PRCT desc )Z
/	
SET UNDERLINE   	'-'
UNDEF ENTER_MINUTOS
