--> Purpose:    Script to find the SQL Statement that contains a specified string. 
-->             It returns the SQL_ID, SQL_TEXT and others.
--> Parameters: sql_string
--> To Run:     @findsql_awr.sql sql_string
--> Example:    @findsql_awr.sql 27b3qfm5x89xn
--> 
--> Copyright 2020@dbaparadise.com


set echo off
set define '&'
set verify off
define sql_string=&1

set verify off 
set feedback off 
set linesize 200 
set heading on 
set termout on

col sql_text format a50 word_wrapped

select /* findsql */ sql_id, child_number, hash_value, address, executions, to_char(substr(sql_text,1,4000)) text
from dba_hist_sqltext
where command_type in (2,3,6,7,189)
and UPPER(sql_text) like UPPER('%&sql_string%')
and UPPER(sql_text) not like '%FINDSQL%';

--select to_char(substr(sql_text,1,4000)) text from dba_hist_sqltext where sql_id='&_sql_id';