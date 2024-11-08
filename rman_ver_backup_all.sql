@conn_param.sql

set feed off timing off


prompt **********************************************************************
prompt BACKUP HISTORY
prompt BACKUP_TYPE:  DB FULL, DB INCR, CONTROLFILE, ARCHIVELOG
prompt **********************************************************************
ACCEPT BBTYPE CHAR PROMPT 'BACKUP_TYPE (ALL) = ' DEFAULT ALL
ACCEPT DDDXXX CHAR PROMPT 'DAYS        (30 ) = ' DEFAULT 30
prompt *********************************************************************
prompt ...

column session_recid      heading "Session|RECID"    format 999999
column start_time         heading 'Started'          format a20
column end_time           heading 'Finished'         format a20
column gbytes_processed   heading "Processed|GBytes" format 9,999,999,999
column status             heading 'Status'           format a25 
column backup_type        heading 'Backup Type'      format a20
column time_total         heading "Time Taken"       format a15 JUSTIFY CENTER
column output_device_type heading "Device Type"      format a15 
column separator          heading "!"                format a1

--alter session set optimizer_mode=RULE;

select   
  /*+ RULE */
  st.session_recid, 
  '|' separator,
  to_char(st.start_time, 'Dy dd/mm/yyyy hh24:mi') start_time, '|' separator, to_char(st.end_time, 'Dy dd/mm/yyyy hh24:mi') end_time,
  '|' separator,
  round(st.mbytes_processed/1024,2) gbytes_processed, '|' separator, lower(st.status) as status,'|' separator,
  lower(case 
    when st.object_type = 'DB INCR' and i1=0 then 'Incr Lvl 0 (FULL)'
    when st.object_type = 'DB INCR' and i1>0 then 'Incr Lvl 1'
    when st.object_type = 'DB INCR' and i0 is NULL and i1 is NULL then st.object_type
  else 
    st.object_type end) as backup_type, '|' separator, 
  TO_CHAR( TRUNC( ((st.end_time-st.start_time)* 24 * 60 * 60) / 60 / 60 ), '999' ) ||':'|| trim(TO_CHAR( TRUNC( MOD( ((st.end_time-st.start_time)* 24 * 60 * 60), 3600 ) / 60 ), '09' )) ||':'|| trim(TO_CHAR( MOD( MOD( ((st.end_time-st.start_time)* 24 * 60 * 60), 3600 ), 60 ), '09' )) as time_total,
  '|' separator,
   dt.output_device_type,
   '|' separator
from v$rman_backup_job_details dt,
	 v$rman_status st 
left join (select  /*+ RULE */
                   d.session_recid, d.session_stamp,
                   sum(case when d.backup_type||d.incremental_level = 'D'  then d.pieces else 0 end) DF,
                   sum(case when d.backup_type||d.incremental_level = 'D0' then d.pieces else 0 end) I0,
                   sum(case when d.backup_type||d.incremental_level = 'I1' then d.pieces else 0 end) I1
             from V$BACKUP_SET_DETAILS d join V$BACKUP_SET s on (s.set_stamp = d.set_stamp and s.set_count = d.set_count)
            where s.input_file_scan_only = 'NO'
			--AND d.backup_type =  DECODE('&&BBTYPE','ALL',d.backup_type ,'&&BBTYPE')
            group by d.session_recid, d.session_stamp) x
    on x.session_recid = st.session_recid and x.session_stamp = st.session_stamp 
Where st.start_time > (sysdate - &&DDDXXX)
  and st.object_type is not null 
  and st.object_type =  DECODE('&&BBTYPE','ALL',st.object_type ,'&&BBTYPE')
  and st.session_recid = dt.session_recid
order by st.start_time ;

set feed on timing on

prompt
prompt

@conn_param.sql