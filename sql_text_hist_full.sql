set pages 1000
set lines 1000
set long 999999999

ACCEPT sqlid char   PROMPT 'SQL ID = '

COLUMN SQL_TEXT    FORMAT a150

select t.sql_id, t.sql_text
from DBA_HIST_SQLTEXT t
where t.sql_id  = '&sqlid'
and rownum = 1;