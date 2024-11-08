-- 
-----------------------------------------------------------------------------
--
--  NAME
--    dplan.sql
--
--  DESCRIPTION
--    Lista plano de execução de um determinado sql
--
--  HISTORY
--    14/11/2014 => Valter J. de Aquino 
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
ACCEPT child_no PROMPT 'CHILD_NO.: '


SELECT * FROM TABLE (DBMS_XPLAN.display_cursor ('&sql_id', '&child_no', 'TYPICAL IOSTATS LAST +PEEKED_BINDS'));


set verify on timing on pages 100 lines 200;

undef sql_id
undef child_no