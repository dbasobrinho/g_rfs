set linesize 145
set pages 2000
select hxfil file#, substr(hxfnm, 1, 50) name, fhscn checkpoint_change#, fhafs Absolute_Fuzzy_SCN, max(fhafs) over () Min_PIT_SCN from x$kcvfh where fhafs!=0 
/
column fuzzy format a6 heading 'fuzzy'
select status,to_char(checkpoint_change#) checkpoint_change
      ,to_char(checkpoint_time, 'dd-mon-yyyy hh24:mi:ss') as checkpoint_time
      ,count(*) cnt ,fuzzy
  from v$datafile_header
 group by status,checkpoint_change#,checkpoint_time,fuzzy
 order by status,checkpoint_change#,checkpoint_time
/
