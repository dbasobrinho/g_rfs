-- |----------------------------------------------------------------------------|
-- | Objetivo   : DBMS_ADVANCED_REWRITE                                         |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 16/10/220 >> Aproveitando e fazendo no pelo                   |
-- | Exemplo    : coe_rewrite_equivalence                                       |
-- | Arquivo    : coe_rewrite_equivalence.sql                                   | 
-- | https://www.morganslibrary.org/reference/pkgs/dbms_adv_rewrite.html                                                              | 
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
col fn new_value banco;
SELECT 'Nome do Arquivo_'||TO_CHAR(SYSDATE, 'YYMMDD')||'.log' as fn from dual;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DBMS_ADVANCED_REWRITE                                       |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT
PROMPT

---SET TERMOUT OFF;
---col fn new_value banco;
---SELECT '&&sql_id'||'_sql_patch_apaga_depois_nao_esquece_'||TO_CHAR(SYSDATE, 'YYYYMMDD_hh24miss')||'.sql' as fn from dual;
---SET TERMOUT ON;


set serveroutput on size 9999
set echo on;
DECLARE
    m_clob  clob;
	d_clob  clob;
	v_sqlid_origem varchar2(20);
BEGIN
     v_sqlid_origem := '8xgm1uzy4kcwc';
     d_clob :=' select a.* from SYSCS.vw_job_PJD_PR_ALE_MS_BI_P_card a';
			
    SELECT sql_fulltext into m_clob
      FROM v$sql
     WHERE sql_id = v_sqlid_origem
       AND child_number = 0 ;
 
  SYS.DBMS_ADVANCED_REWRITE.declare_rewrite_equivalence (
     name             => 'RFS_rewrite_'||v_sqlid_origem,
     source_stmt      => m_clob,
     destination_stmt => d_clob,
     validate         => FALSE,
     rewrite_mode     => 'TEXT_MATCH');
	 --https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_advrwr.htm
END;
/
set echo off;
set lines 200
SELECT OWNER, NAME, REWRITE_MODE FROM dba_rewrite_equivalences
/
select 'BEGIN sys.drop_rewrite_equivalence(name => ''RFS_rewrite_8xgm1uzy4kcwc''); END; '||chr(10)||'/' as SE_QUISER_APAGAR from dual
/
UNDEFINE sql_id 
UNDEFINE m_child_no
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT


create drop view SYSCS.vw_job_PJD_PR_ALE_MS_BI_P_card as 
WITH GUINA AS (
select  /*+ parallel(p, 4) parallel(CT, 4)  parallel(BCV, 4) parallel(TORO, 4) */
P.CODE, P.PRODUCT_NAME, CT.ID_CONTRACT, CT.ID_COMPANY, CT.CONTRACT_NUMBER, TORO.LEGAL_NAME, TORO.FANTASY_NAME  
from  BC_PRODUCT P, CT_CONTRACT CT, BC_VENDOR BCV, TOR_ORGANIZATION TORO
where CT.ID_PRODUCT = P.ID_PRODUCT 
and BCV.ID_VENDOR = CT.ID_VENDOR
and TORO.ID_ORGANIZATION = BCV.ID_VENDOR)
SELECT  /*+ parallel(z, 4) parallel(CY, 4)  parallel(PM, 4) parallel(MS, 4) parallel(C, 4) parallel(MST, 4)  parallel(AC, 4) parallel(ACC, 4) */
 TRIM(Z.CODE) COD_PRODUTO,
 TRIM(Z.PRODUCT_NAME) PRODUTO,
 Z.CONTRACT_NUMBER,
 TRIM(CY.LEGAL_NAME) RAZAO_SOCIAL,
 TRIM(C.DOCUMENT_NUMBER) CPF,
 TRIM(C.CUSTOMER_NAME) NOME,
 TO_CHAR(AC.ACCOUNT_NUMBER) CONTA,
 FC_CS_CUSTOMER_LOGIN(PM.ID_MEDIA_SUPPORT) PROXY,
 TO_CHAR(MS.EXTERNAL_NUMBER) CARTAO,
 TRIM(MST.DESCRIPTION) STATUS,
 CASE
   WHEN C.DOCUMENT_NUMBER IS NULL THEN
    'Nao'
   ELSE
    'Sim'
 END AS ASSOCIADO,
 ACC.AVAILABLE_AMNT SALDO,
 AC.ID_CUSTOMER_ACCOUNT,
 (SELECT TO_CHAR(MAX(TXCT.PURCHASE_DATE), 'dd/mm/yyyy hh24:mi:ss')
    FROM TX_CONFIRMED_TRANSACTION TXCT
   INNER JOIN AC_CUSTOMER_MOVEMENT ACCM
      ON ACCM.ID_CUSTOMER_MOVEMENT = TXCT.ID_CUSTOMER_MOVEMENT
   WHERE TXCT.ID_PAYMENT_MEDIA = PM.ID_PAYMENT_MEDIA
     AND ACCM.ID_MOVEMENT_TYPE = 1) AS PURCHASE_DATE,
 Z.LEGAL_NAME,
 Z.FANTASY_NAME
FROM GUINA Z, CT_COMPANY CY, CS_PAYMENT_MEDIA PM, CS_MEDIA_SUPPORT MS, CS_CUSTOMER C, BC_MEDIA_SUPPORT_STATUS MST, AC_CUSTOMER_ACCOUNT AC, SYSEP.AU_CUSTOMER_ACCOUNT ACC
WHERE CY.ID_COMPANY = Z.ID_COMPANY
AND PM.ID_CONTRACT = Z.ID_CONTRACT
AND MS.ID_MEDIA_SUPPORT = PM.ID_MEDIA_SUPPORT
AND C.ID_CUSTOMER = MS.ID_CUSTOMER
AND MST.ID_MEDIA_SUPPORT_STATUS = MS.ID_MEDIA_SUPPORT_STATUS
AND AC.ID_CUSTOMER_ACCOUNT = PM.ID_CUSTOMER_ACCOUNT
AND ACC.ID_ACCOUNT = PM.ID_CUSTOMER_ACCOUNT 
/
