--nohup sqlplus "/ as sysdba" @index_rebuild_all.sql > index_rebuild_all_shback.log &
SET PAGESIZE 0 
SET FEEDBACK OFF
SET VERIFY OFF
exec dbms_application_info.set_module(module_name => 'IDX_REBUILD [GUINA]',action_name => 'IDX_REBUILD [GUINA]');
column dt new_value _dt 
select 'index_rebuild_all_'||INSTANCE_NAME||'.sql' dt from v$INSTANCE; 
spool &_dt
SELECT 'ALTER INDEX ' ||A.OWNER||'.'|| a.index_name || ' rebuild parallel 10; '||chr(10)||
       'ALTER INDEX ' ||A.OWNER||'.'|| a.index_name || ' noparallel ; '
FROM   DBA_indexes a
WHERE OWNER IN (
SELECT username 
FROM  dba_users 
where username NOT IN 
('OPS$ORACLE', 'SALT', 'TVTSPI','XS$NULL', 'SQLTXPLAIN', 'FVS_PROXY', 'OGGADMIN','TVTMON', 'ZBXODBC','ZABBIX', 'OGG_EXTRACT','PERFSTAT','ADVISOR','OERR','ORDDATA','OUTLN','TRCANLZR','SQLTXADMIN'
,'DBLINK_BACK'
,'APEX_040200'
,'APEX_PUBLIC_USER'
,'APPQOSSYS'
,'AUDSYS'
,'BI'
,'CTXSYS'
,'DBSNMP'
,'DIP'
,'DVF'
,'DVSYS'
,'EXFSYS'
,'FLOWS_FILES'
,'GSMADMIN_INTERNAL'
,'GSMCATUSER'
,'GSMUSER'
,'HR'
,'IX'
,'LBACSYS'
,'MDDATA'
,'MDSYS'
,'OE'
,'ORACLE_OCM'
,'ORDDATA'
,'ORDPLUGINS'
,'ORDSYS'
,'OUTLN'
,'PM'
,'SCOTT'
,'SH'
,'SI_INFORMTN_SCHEMA'
,'SPATIAL_CSW_ADMIN_USR'
,'SPATIAL_WFS_ADMIN_USR'
,'SYS'
,'SYSBACKUP'
,'SYSDG'
,'SYSKM'
,'SYSTEM'
,'WMSYS'
,'XDB'
,'SYSMAN'
,'RMAN'
,'RMAN_BACKUP'
,'OWBSYS'
,'OWBSYS_AUDIT'
,'APEX_030200'
,'MGMT_VIEW'
,'OJVMSYS'
))
/
prompt exit;
SPOOL OFF
@&_dt
SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON



