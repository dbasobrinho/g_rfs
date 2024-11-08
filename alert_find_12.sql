col name format a10
col value format a60
select inst_id,name,value from v$diag_info where name = 'Diag Trace'
/