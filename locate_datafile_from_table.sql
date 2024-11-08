select FILE#,df.NAME datafile_name,
       df.STATUS status_datafile,
       df.BYTES/1024/1024/1024 tam_GB,
       ts.NAME tablespace_name,
       tambem.TABLE_NAME obj_name,
       'TABLE' obj_type
from   v$datafile df,
       v$tablespace ts,
       dba_tables tambem
where  ts.TS# = df.TS#
and    tambem.TABLESPACE_NAME = ts.NAME
and    tambem.TABLE_NAME ='CT_CONTRACT'
/

select e.FILE_ID, F.FILE_NAME, E.OWNER, E.SEGMENT_NAME,E.SEGMENT_TYPE
from dba_extents E 
     join dba_data_files F 
          on E.FILE_ID = F.FILE_ID
where E.OWNER='SYSCT' 
and E.SEGMENT_NAME='CT_CONTRACT';