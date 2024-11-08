-- 
-----------------------------------------------------------------------------
--
--  NAME
--    dplana.sql
--
--  DESCRIPTION
--    Lista plano de execução de um determinado sql buscando no AWR
--
--  ATTENTION
--    A execução deste script requer licença da OPTION DIAGNOSTIC & TUNING PACK
--
--  HISTORY
--    15/05/2020 => Valter J. de Aquino
-- 
-----------------------------------------------------------------------------


set verify off
set timing off;
set linesize 600;
set trimspool on;
set echo off;
set pagesize 999

PROMPT '========================================================================'
PROMPT '= INFORME UM DOS PARAMETROS ABAIXO:  SQL_ID E/OU  CHILD_NO             ='
PROMPT '========================================================================'

ACCEPT sql_id   PROMPT 'SQL_ID...: '


SELECT * FROM TABLE (DBMS_XPLAN.display_awr ('&sql_id',null, null,  'ADVANCED' ));


set verify on timing on pages 100 lines 200;

undef sql_id
undef child_no