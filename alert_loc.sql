col inst_id form 9999 head inst
col name form a25
col value form a60 wrap
spool diag_info.lst
set lines 120
select * from v$diag_info
order by name
/