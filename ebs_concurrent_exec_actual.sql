Select substr(Concurrent_Queue_Name,1,12) Manager,fu.user_name,fcp.user_Concurrent_Program_Name full_name,
substr(Fcp.Concurrent_Program_Name,1,35) short_name,fcr.concurrent_program_id "PROGRAM ID",Request_Id Request,
REQUEST_DATE,
to_char(actual_start_date, ' DAY DD-MON-YY HH:MI AM') ACTUAL_START_DATE ,
--to_char(SYSDATE, 'DAY DD-MON-YY HH:MI AM') CURRENT_TIME,
floor(((ACTUAL_START_DATE-request_date)*24*60*60)/3600)|| ' Hrs ' ||
floor((((ACTUAL_START_DATE-request_date)*24*60*60) -
floor(((ACTUAL_START_DATE-request_date)*24*60*60)/3600)*3600)/60)|| ' Mins ' ||
round((((ACTUAL_START_DATE-request_date)*24*60*60) -
floor(((ACTUAL_START_DATE-request_date)*24*60*60)/3600)*3600 -
(floor((((ACTUAL_START_DATE-request_date)*24*60*60) -
floor(((ACTUAL_START_DATE-request_date)*24*60*60)/3600)*3600)/60)*60) ))|| ' Secs ' "DELAYED_START",
floor(((SYSDATE-ACTUAL_START_DATE)*24*60*60)/3600)|| ' Hrs ' ||
floor((((SYSDATE-ACTUAL_START_DATE)*24*60*60) -
floor(((SYSDATE-ACTUAL_START_DATE)*24*60*60)/3600)*3600)/60)|| ' Mins ' ||
round((((SYSDATE-ACTUAL_START_DATE)*24*60*60) -
floor(((SYSDATE-ACTUAL_START_DATE)*24*60*60)/3600)*3600 -
(floor((((SYSDATE-ACTUAL_START_DATE)*24*60*60) -
floor(((SYSDATE-ACTUAL_START_DATE)*24*60*60)/3600)*3600)/60)*60) ))|| ' Secs ' "RUNNING_SINCE",
argument_text,
vs.sid,vs.serial#,vs.sql_id,vs.event,vs.blocking_session,vs.status,vs.osuser,
vs.machine,vs.program,vs.module,vs.action,
--Status_code,
fcr.ofile_size,
fcr.lfile_size
from 
apps.Fnd_concurrent_Queues Fcq, 
apps.Fnd_Concurrent_Requests Fcr,
apps.Fnd_Concurrent_Programs_vl Fcp, 
apps.Fnd_User Fu, 
apps.Fnd_Concurrent_Processes Fpro,
v$session vs,
v$process vp
where
Phase_Code = 'R' 
And Status_Code <> 'W' 
And Fcr.Controlling_Manager = Concurrent_Process_Id 
And (Fcq.Concurrent_Queue_Id = Fpro.Concurrent_Queue_Id    
And Fcq.Application_Id      = Fpro.Queue_Application_Id ) 
And (Fcr.Concurrent_Program_Id = Fcp.Concurrent_Program_Id 
And Fcr.Program_Application_Id = Fcp.Application_Id )     
And Fcr.Requested_By = User_Id                            
And fcr.ORACLE_PROCESS_ID=vp.sPID                          
And vs.PADDR=vp.addr
--AND fcp.user_Concurrent_Program_Name='Inventory transaction worker'
--AND fu.USER_NAME='502525468'
--AND FCR.ACTUAL_START_DATE>SYSDATE-2/24
--AND fcr.argument_text like '3831511256, 3, ,%'
order by fcp.user_Concurrent_Program_Name,ACTUAL_START_DATE desc;