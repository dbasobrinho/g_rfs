-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/10g/flashback_db_info.sql
-- Author       : Tim Hall
-- Description  : Displays information relevant to flashback database.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @flashback_db_info
-- Last Modified: 21/12/2004
-- -----------------------------------------------------------------------------------
PROMPT 
PROMPT +======================================================================================================+
PROMPT | FLASHBACK ON / OFF                                                                                   |
PROMPT | 1-)shutdown immediate;                                                                               |
PROMPT | 2-)startup mount;                                                                                    |
PROMPT | 3-)alter database flashback on / off;                                                                |
PROMPT | 4-)alter database open;                                                                              |
PROMPT +======================================================================================================+
PROMPT +======================================================================================================+
PROMPT | CREATE RESTORE POINT                                                                                 |
PROMPT | 1-)create restore point <NAME_R_POINT> guarantee flashback database;                                 |
PROMPT +======================================================================================================+
PROMPT +======================================================================================================+
PROMPT | RECOVER RESTORE POINT                                                                                |
PROMPT | 1-)shutdown immediate;                                                                               |
PROMPT | 2-)startup mount;                                                                                    |
PROMPT | 3-)flashback database to restore point <NAME_R_POINT> ;                                              |
PROMPT | 4-)alter database open resetlogs;                                                                    |
PROMPT |    AGUARDAR TESTES ANTES DE EXECUTAR DROP                                                            |
PROMPT | 5-)drop restore point <NAME_R_POINT>;                                                                |
PROMPT +======================================================================================================+
PROMPT 
set echo off
set feed OFF
set timing off
set lines 1000 
set pages 1000
column name                            format A30
column value                           format A50
column SCN                             format 9999999999
column INCARNATION                     format 9999999999
column GUARANTEE                       format A10
column STORAGE_SIZE_MB                 format 9999999999
column TIME                            format A21
column RESTORE_POINT_TIME              format A21
column PRESERVED                       format A8
column NAME                            format A60
col INST_ID                            format 99      HEADING  "INST_ID|-"               JUSTIFY CENTER
col OLDEST_FLASHBACK_SCN               format A20     HEADING  "OLDEST|FLASHBACK_SCN"  
col OLDEST_FLASHBACK_TIME              format A21     HEADING  "OLDEST|FLASHBACK_TIME"  
col RETENTION_TARGET                   format 9999999 HEADING  "RETENTION|TARGET(MIN)"      JUSTIFY right
col FLASHBACK_SIZE                     format A16     HEADING  "FLASHBACK|SIZE"             JUSTIFY right      
col ESTIMATED_FLASHBACK_SIZE           format A16     HEADING  "FLASHBACK|ESTIMATED SIZE"   JUSTIFY right     
PROMPT ========================================================================================================
PROMPT Flashback Status
PROMPT ================
select flashback_on from v$database;
PROMPT
PROMPT ========================================================================================================
PROMPT Flashback Parameters
PROMPT ====================
select name, value
from   v$parameter
where  name in ('db_flashback_retention_target', 'db_recovery_file_dest','db_recovery_file_dest_size')
order by name;
PROMPT
PROMPT ========================================================================================================
PROMPT Flashback Restore Points
PROMPT ========================
select SCN, DATABASE_INCARNATION# INCARNATION, GUARANTEE_FLASHBACK_DATABASE as GUARANTEE, STORAGE_SIZE/1024/1024 as STORAGE_SIZE_MB, to_char(TIME,'dd/mm/yyyy hh24:mi:ss') TIME,
       to_char(RESTORE_POINT_TIME,'dd/mm/yyyy hh24:mi:ss') RESTORE_POINT_TIME, PRESERVED, NAME
from gv$restore_point;
PROMPT
PROMPT ========================================================================================================
PROMPT Flashback Logs
PROMPT ==============
select INST_ID, 
       to_char(OLDEST_FLASHBACK_SCN) OLDEST_FLASHBACK_SCN, 
	   to_char(OLDEST_FLASHBACK_TIME,'dd/mm/yyyy hh24:mi:ss') OLDEST_FLASHBACK_TIME, 
	   RETENTION_TARGET, 
	   lpad(dbms_xplan.format_size(FLASHBACK_SIZE),16,' ')            FLASHBACK_SIZE , 
	   lpad(dbms_xplan.format_size(ESTIMATED_FLASHBACK_SIZE),16,' ')  ESTIMATED_FLASHBACK_SIZE
from gv$flashback_database_log;
PROMPT
PROMPT ========================================================================================================
PROMPT Flashback Usage
PROMPT ==============
select * from v$flash_recovery_area_usage;
PROMPT
PROMPT ========================================================================================================
PROMPT
set feed on
