set pagesize 20000

set linesize 180

set pause off

set serveroutput on

set feedback on

set echo on

set numformat 999999999999999

alter session set nls_date_format = 'dd-mon-yyyy hh24:mi:ss';

archive log list;

select name,dbid,controlfile_type,open_mode,checkpoint_change#,archive_change# from v$database;

col name for a75

select file#,name,status,enabled from v$datafile;

select file#,name,recover,fuzzy,checkpoint_change#,checkpoint_time,creation_change#,creation_time from v$datafile_header;

select group#,thread#,sequence#,members,archived,status,first_change#  from v$log;

select group#,substr(member,1,60) from v$logfile;

select count(*),fhsta from x$kcvfh group by fhsta;

select count(*),fhrba_seq from x$kcvfh group by fhrba_seq;

select count(*),fhscn from x$kcvfh group by fhscn;

select count(*),fhafs from x$kcvfh group by fhafs;

select fhdbn,fhdbi,hxfil,fhsta,fhscn,fhafs,fhrba_seq,fhtnm tbs_name from x$kcvfh;

SELECT f.name,b.status,b.change#,b.time FROM v$backup b,v$datafile f WHERE b.file# = f.file# AND b.status='ACTIVE';

select FILE#,ABSOLUTE_FUZZY_CHANGE#,CHECKPOINT_CHANGE# from v$backup_datafile;

select min(FHSCN) "LOW FILEHDR SCN" , max(FHSCN) "MAX FILEHDR SCN" , max(FHAFS) "Min PITR ABSSCN" from X$KCVFH ;

select * from v$database_incarnation;