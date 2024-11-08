--#============================================================================================================
--#Referencia : stats_gather_dictionary.sql
--#Assunto    : Estatisticas para objetos de dicionário, chamada sqlplus
--#Criado por : Roberto Fernandes Sobrinho
--#Data       : 25/07/2019
--#Ref        : https://www.oracle.com/technetwork/database/bi-datawarehousing/twp-bp-optimizer-stats-04042012-1577139.pdf
--#           : https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_stats.htm
--#           : https://www.oracle.com/technetwork/database/bi-datawarehousing/twp-optimizer-stats-concepts-110711-1354477.pdf
--#Alteracoes :
--#           :
--#============================================================================================================

ALTER SESSION ENABLE PARALLEL DDL;
ALTER SESSION SET NLS_DATE_FORMAT  = 'DD/MM/YYYY HH24:MI:SS';
purge dba_recyclebin
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
        --/
    v_msg := 'STAT! WORKING [GATHER_DICTIONARY]. . . [CRONTAB]';
    dbms_application_info.set_module( module_name => v_msg, action_name =>  v_msg);
    dbms_stats.flush_database_monitoring_info;
        --
    BEGIN
            v_prc := '[GATHER_FIXED_OBJECTS_STATS]';
            dbms_system.ksdwrt (2, 'ORA-00444 -> INICIO  : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);
        DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
                dbms_system.ksdwrt (2, 'ORA-00444 -> FIM     : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);
        EXCEPTION
        WHEN e_resource_busy_ora_exp THEN
                NULL;
    WHEN OTHERS THEN
                dbms_system.ksdwrt (2, 'ORA-09000 -> ERROR(1): '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc||' -> SQLERRM: '||substr(sqlerrm, 1, 300)||' -> '||dbms_utility.format_error_backtrace);
        END;
    --
    BEGIN
            v_prc := '[GATHER_DICTIONARY_STATS[GATHER STALE]]';
            dbms_system.ksdwrt (2, 'ORA-00444 -> INICIO  : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);
        DBMS_STATS.GATHER_DICTIONARY_STATS(OPTIONS         =>'GATHER STALE',
                                          estimate_percent => dbms_stats.auto_sample_size,
                                          method_opt       => 'FOR ALL COLUMNS SIZE SKEWONLY',
                                          cascade          => TRUE,
                                          degree           => DBMS_STATS.AUTO_DEGREE,
                                          no_invalidate    => TRUE);
        dbms_system.ksdwrt (2, 'ORA-00444 -> FIM     : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);
        EXCEPTION
        WHEN e_resource_busy_ora_exp THEN
                NULL;
    WHEN OTHERS THEN
                dbms_system.ksdwrt (2, 'ORA-00900 -> ERROR(2): '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc||' -> SQLERRM: '||substr(sqlerrm, 1, 300)||' -> '||dbms_utility.format_error_backtrace);
        END;
        --
        BEGIN
            v_prc := '[GATHER_DICTIONARY_STATS[GATHER EMPTY]]';
            dbms_system.ksdwrt (2, 'ORA-00444 -> INICIO  : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);
        DBMS_STATS.GATHER_DICTIONARY_STATS(OPTIONS         =>'GATHER EMPTY',
                                          estimate_percent => dbms_stats.auto_sample_size,
                                          method_opt       => 'FOR ALL COLUMNS SIZE SKEWONLY',
                                          cascade          => TRUE,
                                          degree           => DBMS_STATS.AUTO_DEGREE,
                                          no_invalidate    => DBMS_STATS. AUTO_INVALIDATE);
            dbms_system.ksdwrt (2, 'ORA-00444 -> FIM     : '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc);
        EXCEPTION
        WHEN e_resource_busy_ora_exp THEN
                NULL;
    WHEN OTHERS THEN
                dbms_system.ksdwrt (2, 'ORA-00900           -> ERROR(3): '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')||' -> '||v_msg||' -> '||v_prc||' -> SQLERRM: '||substr(sqlerrm, 1, 300)||' -> '||dbms_utility.format_error_backtrace);
        END;
    --
END;
/
