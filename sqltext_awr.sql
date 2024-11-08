--> Purpose:    Script to display the SQL text  for a specific SQL_ID. 
-->             It returns the SQL_TEXT.
--> Parameters: sql_id
--> To Run:     @sqltext.sql sql_id 
--> Example:    @sqltext.sql 27b3qfm5x89xn
--> 
--> Copyright 2019@dbaparadise.com
-->
--> Warning! You must have AWR license to run this script!!!

set echo off
set define '&'
set verify off
define _sql_id=&1

set verify off 
set feedback off 
set linesize 200 
set heading on 
set termout on

col sql_text format a550 word_wrapped

select to_char(substr(sql_text,1,4000)) sql_text from dba_hist_sqltext where sql_id='&_sql_id'
union ALL
select to_char(substr(sql_text,4001,4000)) sql_text from dba_hist_sqltext where sql_id='&_sql_id';
