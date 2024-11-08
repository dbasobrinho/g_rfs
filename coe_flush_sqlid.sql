SET VERIFY OFF;
SET SERVEROUTPUT ON;
SET TERMOUT OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';
SET TERMOUT ON;
set FEEDBACK off;
SET LINES 600;
SET PAGES 600;
prompt .  
prompt . 
prompt -------------------------------------------------------->
ACCEPT v_sql_id CHAR PROMPT 'Informe o SQL_ID: ';
prompt -------------------------------------------------------->
prompt .  
prompt . 
BEGIN
    FOR sql_row IN (
        SELECT DISTINCT inst_id, sql_id, hash_value, address
        FROM GV$SQL
        WHERE SQL_ID = '&&v_sql_id'
        ORDER BY inst_id
    ) LOOP
        DBMS_SCHEDULER.CREATE_JOB(
            job_name      => '"PBUM_' || sql_row.sql_id || '_' || sql_row.inst_id || '"',
            job_type      => 'PLSQL_BLOCK',
            job_action    => 'BEGIN SYS.DBMS_SHARED_POOL.PURGE (''' || sql_row.address || ',' || sql_row.hash_value || ''',''C''); END;',
            start_date    => SYSDATE,
            enabled       => TRUE,
            auto_drop     => TRUE,
            comments      => 'O Guina não tinha dó e removeu o SqlID: ' || sql_row.sql_id || ' na instância ' || sql_row.inst_id
        );
        
        DBMS_SCHEDULER.SET_ATTRIBUTE(name => '"PBUM_' || sql_row.sql_id || '_' || sql_row.inst_id || '"', attribute => 'INSTANCE_ID', value => sql_row.inst_id);
        
        DBMS_OUTPUT.PUT_LINE('JOB: "PBUM_' || sql_row.sql_id || '_' || sql_row.inst_id || '" Plan Hash Value: ' || sql_row.hash_value || ' SYS.DBMS_SHARED_POOL.PURGE (''' || sql_row.address || ',' || sql_row.hash_value || ''',''C'');');
    END LOOP;
    --/
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------->');
    DBMS_OUTPUT.PUT_LINE('Executando a Limpeza! Aguarde! . . .');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------->');
    DBMS_OUTPUT.PUT_LINE('.    ');
    DBMS_OUTPUT.PUT_LINE('.    ');
    --/
    DBMS_LOCK.SLEEP(15);
END;
/
SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_NAME LIKE 'PBUM%';
prompt .  
prompt . 
COLUMN LOG_DATE FORMAT A40
COLUMN JOB_NAME FORMAT A40    
COLUMN STATUS   FORMAT A11  
SELECT log_date, job_name, STATUS FROM dba_scheduler_job_log WHERE JOB_NAME LIKE 'PBUM%' and JOB_NAME  LIKE '%&&v_sql_id%' AND log_date >= TRUNC(SYSDATE) ORDER BY log_date;
prompt .  
prompt . 

SET FEEDBACK ON;
