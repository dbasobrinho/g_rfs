--wonka_mon_full.sql
SET TERMOUT OFF;
SET PAGES 400
SET LINES 400 
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
begin dbms_application_info.set_module( module_name => 'WONKA - MONITOR DATABASE. . . WORKING [RFS]. . .', action_name =>  'WONKA - MONITOR DATABASE. . . WORKING [RFS]'); end;
/
col MONITORACAO         format a16
col SAIDA               format a85
col STATUS              format a10				
col DESCRICAO           format a85			
col MSG                 format a130	
col SEND_ALL            format 999		
SET TERMOUT ON;   		     
SELECT MONITORACAO, STATUS, DESCRICAO MSG, SEND_ALL  FROM TABLE(TVTSPI.pkg_wonka_monitor.fnc_pipe_mon('ALL')) order by STATUS||MONITORACAO desc
/ 