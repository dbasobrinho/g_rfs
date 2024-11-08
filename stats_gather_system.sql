--#============================================================================================================
--#Referencia : stats_gather_system.sh
--#Assunto    : Estatisticas de carga de trabalho, chamada sqlplus 
--#Criado por : Roberto Fernandes Sobrinho  
--#Data       : 25/07/2019
--#Ref        : https://www.oracle.com/technetwork/database/bi-datawarehousing/twp-bp-optimizer-stats-04042012-1577139.pdf 
--#           : https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_stats.htm
--#           : https://www.oracle.com/technetwork/database/bi-datawarehousing/twp-optimizer-stats-concepts-110711-1354477.pdf
--#Alteracoes :   
--#           :  
--#============================================================================================================
ALTER SESSION ENABLE PARALLEL DDL;
ALTER SESSION SET NLS_DATE_FORMAT                 = 'DD/MM/YYYY HH24:MI:SS';
purge dba_recyclebin 
/ 
begin execute immediate 'create table gather_system_stats_hist as select sysdate dt, ''START'' TP, pname, pval1 from sys.aux_stats$ where sname = ''SYSSTATS_MAIN'' order by 1';  execute immediate 'truncate table gather_system_stats_hist'; exception when others then null; end;
/
declare  
  e_resource_busy_ora_exp exception;
  PRAGMA EXCEPTION_INIT(e_resource_busy_ora_exp, -54);
  v_msg  varchar2(500);
  v_prc  varchar2(500);  
begin
	begin execute immediate 'ALTER SESSION SET DDL_LOCK_TIMEOUT=300'; exception when others then null; end;
	begin execute immediate 'ALTER SESSION SET DB_FILE_MULTIBLOCK_READ_COUNT=128'; exception when others then null; end;
	begin execute immediate 'ALTER SESSION SET COMMIT_LOGGING=BATCH'; exception when others then null; end; 
	begin execute immediate 'ALTER SESSION SET COMMIT_WAIT=NOWAIT'; exception when others then null; end; 
	begin execute immediate 'ALTER SESSION SET "_OPTIMIZER_JOIN_FACTORIZATION"=FALSE'; exception when others then null; end; 

    v_msg := 'STAT! WORKING [GATHER_SYSTEM]. . . [CRONTAB]';
    dbms_application_info.set_module( module_name => v_msg, action_name =>  v_msg);
    dbms_stats.flush_database_monitoring_info;
	--
    BEGIN
	    BEGIN DBMS_STATS.GATHER_SYSTEM_STATS; END; --#NO-WORKLOAD 
	    -->> SELECT PNAME, PVAL1 FROM SYS.AUX_STATS$ where SNAME = 'SYSSTATS_MAIN'; 
	    v_prc := '[GATHER_SYSTEM_STATS]';
	    dbms_system.ksdwrt (2, 'ORA-00444 -> INICIO  : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);
		insert into gather_system_stats_hist select sysdate dt, 'START' TP, pname, pval1 from sys.aux_stats$ where sname = 'SYSSTATS_MAIN' order by 1;
	    commit;
        DBMS_STATS.gather_system_stats('START');
		DBMS_LOCK.SLEEP(3600);
		DBMS_STATS.GATHER_SYSTEM_STATS('STOP');
		insert into gather_system_stats_hist select sysdate dt, 'STOP' TP, pname, pval1 from sys.aux_stats$ where sname = 'SYSSTATS_MAIN' order by 1;
	    commit;		
	    dbms_system.ksdwrt (2, 'ORA-00444 -> FIM     : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);			
	EXCEPTION  
	WHEN e_resource_busy_ora_exp THEN	
		DBMS_STATS.GATHER_SYSTEM_STATS('STOP');
		dbms_system.ksdwrt (2, 'ORA-00900 -> ERROR(1): '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc||' -> SQLERRM: '||substr(sqlerrm, 1, 300)||' -> '||dbms_utility.format_error_backtrace); 
	WHEN OTHERS THEN
	    DBMS_STATS.GATHER_SYSTEM_STATS('STOP');
        dbms_system.ksdwrt (2, 'ORA-00900 -> ERROR(2): '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc||' -> SQLERRM: '||substr(sqlerrm, 1, 300)||' -> '||dbms_utility.format_error_backtrace); 	
	END;			  
    --
END;
/	

-----_____    EXEC DBMS_STATS.GATHER_SYSTEM_STATS; --#NO-WORKLOAD 									