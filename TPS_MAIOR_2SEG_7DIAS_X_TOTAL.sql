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
PROMPT | Report   : TPS AMOSTRA MAIS 2 SEG DE 7 DIAS      +-+-+-+-+-+-+-+-+-+-+ |
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
ALTER SESSION FORCE PARALLEL DML PARALLEL   8;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8;

-----create table TPS_RFS as 
SELECT /*+ parallel (5) */  lpad(round(Y.TOTAL*100/W.TOTAL_GERAL,2),'5',' ')||'%' "%_>2SEG", Y.TOTAL "TOTAL_>2SEG", Y.DT_HR as "DATA HORA", W.TOTAL_GERAL "TOTAL TRANSACOES" 
FROM (
SELECT Z.* FROM(
 select count(*) total, TO_CHAR(TRANSACTION_BEGIN_TIME, 'YYYY/MM/DD HH24') AS DT_HR
 from
 (SELECT ID_TRANSACTION, TRANSACTION_BEGIN_TIME,TRANSACTION_END_TIME,
        (TRANSACTION_BEGIN_TIME-TRANSACTION_END_TIME) as DIF, extract(SECOND FROM (TRANSACTION_END_TIME-TRANSACTION_BEGIN_TIME))  seg
         FROM AU_OPEN_TRANSACTION AU
        WHERE ID_TRANSACTION >=
              ((SELECT MAX(ID_TRANSACTION) - 1000000
                  FROM AU_OPEN_TRANSACTION AUOT))
          AND AU.TRANSACTION_PAN NOT IN ('4058801720859010')
          AND AU.TRANSACTION_BEGIN_TIME >= SYSDATE-7
		 ) 
where seg > 2	
group by TO_CHAR(TRANSACTION_BEGIN_TIME, 'YYYY/MM/DD HH24')) Z
) Y,		
(SELECT Z.* FROM(
 select count(*) total_GERAL, TO_CHAR(TRANSACTION_BEGIN_TIME, 'YYYY/MM/DD HH24') AS DT_HR
 from
 (SELECT ID_TRANSACTION, TRANSACTION_BEGIN_TIME,TRANSACTION_END_TIME,
        (TRANSACTION_BEGIN_TIME-TRANSACTION_END_TIME) as DIF, extract(SECOND FROM (TRANSACTION_END_TIME-TRANSACTION_BEGIN_TIME))  seg
         FROM AU_OPEN_TRANSACTION AU
        WHERE ID_TRANSACTION >=
              ((SELECT MAX(ID_TRANSACTION) - 1000000
                  FROM AU_OPEN_TRANSACTION AUOT))
          AND AU.TRANSACTION_PAN NOT IN ('4058801720859010')
          AND AU.TRANSACTION_BEGIN_TIME >= SYSDATE-7   ) 
group by TO_CHAR(TRANSACTION_BEGIN_TIME, 'YYYY/MM/DD HH24')) Z
) W
WHERE 	W.DT_HR = Y.DT_HR
ORDER BY to_char(TO_DATE(w.DT_HR,'YYYY/MM/DD HH24'),'hh24DD') ASC 
/


----  select lpad(round(TOTAL*100/TOTAL_GERAL,2),'5',' ')||'%' "%_>2SEG", TOTAL "TOTAL_>2SEG", DT_HR as "DATA HORA", TOTAL_GERAL "TOTAL TRANSACOES" 
----  from TPS_RFS
----  /
----  --DROP TABLE TPS_RFS
----  --/
