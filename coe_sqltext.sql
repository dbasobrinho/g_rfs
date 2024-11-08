set echo off
set verify off
define _sql_id=&1

set pages 1000
set lines 1000
set long 999999999
set verify off 
set feedback off 
set linesize 200 
set heading on 
set termout on

COLUMN SQL_TEXT    FORMAT a150 word_wrapped
COLUMN i     FORMAT 9 word_wrapped
select z.SQL_TEXT from (
select distinct  SQL_TEXT, piece
from gv$sqltext
where sql_id = '&_sql_id'
order by piece ) z
/

UNDEF _sql_id
