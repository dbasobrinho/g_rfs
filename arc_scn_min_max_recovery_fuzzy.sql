 select hxfil FILE#,fhsta STAT,fhscn SCN,
 fhthr thr, fhrba_Seq SEQUENCE,
 round((fhfsz * fhbsz)/1024/1024,0) mb,
 fhtnm TABLESPACE
 from x$kcvfh 
-- where hxfil not in (select FILE# from v$datafile_header where status = 'OFFLINE')
 order by fhrba_Seq, SEQUENCE
/ 