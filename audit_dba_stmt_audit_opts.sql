------
set pages 5000
set lines 5000
column username format a30
column owner    format a15
column obj_name format a33
column extended_timestamp format a35
column dt_extended_time format a21
select * from dba_stmt_audit_opts;

