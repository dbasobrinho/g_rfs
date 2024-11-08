-- 
-----------------------------------------------------------------------------
--
--  NAME
--    dplant.sql
--
--  DESCRIPTION
--    Lista plano de execução de um determinado sql com maior precisão de elapse time
--
--  HISTORY
--    27/04/2023 => Valter J. de Aquino
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


COLUMN id FORMAT 99
COLUMN operation FORMAT a40
COLUMN options FORMAT a30
COLUMN actual_time FORMAT 99999999.9999999999 HEADING "Actual|Time"
COLUMN object_name FORMAT a40 HEADING "Object|Name"
COLUMN last_starts FORMAT 9999999 HEADING "Last|Starts"
COLUMN actual_rows FORMAT 9999999 HEADING "Actual|Rows"
 
SELECT id
       ,LPAD (' ', DEPTH) || operation operation
       ,options
       ,last_elapsed_time / 1000000 actual_time
       ,object_name
       ,last_starts
       ,last_output_rows actual_rows
  FROM v$sql_plan_statistics_all
 WHERE sql_id = '&sql_id'
   AND child_number = NVL('&child_no',0)
 ORDER BY id;

set verify on timing on pages 100 lines 200;

undef sql_id
undef child_no