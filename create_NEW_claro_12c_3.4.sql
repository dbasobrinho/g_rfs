-- CLARO BRASIL
-- DESCRICAO: SCRIPT PARA AUTOMATIZACAO DE ATIVIDADES PARA CRIACAO DE AMBIENTE

SET SERVEROUTPUT ON
SET ECHO OFF
SET LINES 300 PAGES 1000

-- VERIFY FUNCTION

CREATE OR REPLACE  FUNCTION SYS.VERIFY_FUNCTION
        (username varchar2,
        password varchar2,
        old_password varchar2)
        RETURN BOOLEAN IS
        n boolean;
        m integer;
        differ integer;
        isdigit boolean;
        ischar  boolean;
        ispunct boolean;
        isforbidden boolean;
        isrepeated boolean;
        digitarray varchar2(20);
        punctarray varchar2(25);
        chararray varchar2(52);
        forbiddenarray varchar2(55);
        forbiddenchar char(1);
        cont integer;
        repete boolean;

        BEGIN
        digitarray := '0123456789';
        chararray  := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        punctarray := '!#$%&()*+,-:;<=>?.';
        forbiddenarray := '@/';


        -- Check if the password is same as or contains the username
        IF instr( NLS_LOWER(password), NLS_LOWER(username) ) != 0 THEN
                raise_application_error(-20001, 'Password nao pode ser igual ou conter o username!');
        END IF;


        -- Check for the minimum length of the password
        IF length(password) < 8 THEN
                raise_application_error(-20002, 'Password menor que 8 caracteres!');
        END IF;

        -- Check if the password is too simple. A dictionary of words may be
        -- maintained and a check may be made so as not to allow the words
        -- that are too simple for the password.
        IF NLS_LOWER(password)
                        IN ('welcome', 'database', 'account', 'user',
                                'password', 'oracle', 'computer', 'abc', 'atl',
                                'system','manager','xxx') THEN

                raise_application_error(-20003, 'Password nao autorizada!');
        END IF;


        -- Check if the password contains at least one letter, one digit and one
        -- punctuation mark.

        -- 1. Check for the digit
        isdigit:=FALSE;
        m := length(password);
        FOR i IN 1..10 LOOP
                FOR j IN 1..m LOOP
                        IF substr(password,j,1) = substr(digitarray,i,1) THEN
                                isdigit:=TRUE;
                                GOTO findchar;
                        END IF;
                END LOOP;
        END LOOP;
        IF isdigit = FALSE THEN
                raise_application_error(-20004, 'Password deve conter pelo menos um digito, um caracter alfabetico e um caracter especial ou de pontuacao. Nao existe digito!');
        END IF;

        -- 2. Check for the character
        <<findchar>>
        ischar:=FALSE;
        FOR i IN 1..length(chararray) LOOP
                FOR j IN 1..m LOOP
                        IF substr(password,j,1) = substr(chararray,i,1) THEN
                                ischar:=TRUE;
                                GOTO findpunct;
                        END IF;
                END LOOP;
        END LOOP;
        IF ischar = FALSE THEN
                raise_application_error(-20005, 'Password deve conter pelo menos um digito, um caracter alfabetico e um caracter especial ou de pontuacao. Nao existe caracter alfabetico!');
        END IF;

        -- 3. Check for the punctuation
        <<findpunct>>
        ispunct:=FALSE;
        FOR i IN 1..length(punctarray) LOOP
                FOR j IN 1..m LOOP
                        IF substr(password,j,1) = substr(punctarray,i,1) THEN
                                ispunct:=TRUE;
                                GOTO findforbidden;
                        END IF;
                END LOOP;
        END LOOP;
        IF ispunct = FALSE THEN
                raise_application_error(-20006, 'Password deve conter pelo menos um digito, um caracter alfabetico e um caracter especial ou de pontuacao. Nao existe caracter especial ou de pontuacao!');
        END IF;

        -- 4. Check for the forbidden characters
        <<findforbidden>>
        isforbidden:=FALSE;
        FOR i IN 1..length(forbiddenarray) LOOP
                FOR j IN 1..m LOOP
                        IF substr(password,j,1) = substr(forbiddenarray,i,1) THEN
                                isforbidden:=TRUE;
                                forbiddenchar := substr(forbiddenarray,i,1);
                                GOTO forbiddenfound;
                        END IF;
                END LOOP;
        END LOOP;
        <<forbiddenfound>>
        IF isforbidden = TRUE THEN
                raise_application_error(-20007, 'Password contem o seguinte caracter nao permitido: '''||forbiddenchar||'''.  Os caracteres nao permitidos sao: '''||forbiddenarray||'''');
        END IF;
        <<endsearch1>>

        -- Check if the password differs from the previous password by at least
        -- 3 letters
        IF old_password != '' THEN
                differ := length(old_password) - length(password);
                IF abs(differ) < 3 THEN
                        IF length(password) < length(old_password) THEN
                                m := length(password);
                        ELSE
                                m := length(old_password);
                        END IF;
                        differ := abs(differ);
                        FOR i IN 1..m LOOP
                                IF substr(password,i,1) != substr(old_password,i,1) THEN
                                        differ := differ + 1;
                                END IF;
                        END LOOP;
                        IF differ < 3 THEN
                                raise_application_error(-20008,'Password deve ser diferente em 3 caracteres da antiga password!');
                        END IF;
                END IF;
        END IF;


        -- Check if the password has not three consecutive characters in any position
        isrepeated := FALSE;
        FOR i IN 1..length(password) LOOP
                IF instr(password, lpad(substr(password,i,1), 3, substr(password,i,1) ) ) != 0 THEN
                        isrepeated := TRUE;
                        GOTO endsearch3;
                END IF;
        END LOOP;
        <<endsearch3>>
        IF isrepeated = TRUE THEN
                raise_application_error(-20009, 'Password nao pode conter mais que tres caracteres identicos consecutivos!');
        END IF;


        -- Everything is fine; return TRUE ;
        RETURN(TRUE);
        END;
/



--------------------------------------------------------------------------------------------------------------------------------------------

DECLARE
    V_CHECK         VARCHAR2(60);
        V_VERSION               NUMBER(2);
        V_PDB                   VARCHAR2(40);
        V_CDB                   VARCHAR2(10);
        V_COUNT                 NUMBER:=0;
        P_FILE UTL_FILE.FILE_TYPE;
BEGIN

        -- CHECK VERSION
        BEGIN
                SELECT TO_NUMBER(SUBSTR(VERSION,1,2)) INTO V_VERSION FROM V$INSTANCE;
        END;

        -- CHECK CDB
        BEGIN
        IF V_VERSION >= '12' THEN
                SELECT CDB INTO V_CDB FROM V$DATABASE;
        ELSE
                NULL;
        END IF;
        END;

        -- CHECK PDB
        BEGIN
        IF V_VERSION >= '12' THEN
                SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO V_PDB FROM DUAL;
        ELSE
                NULL;
        END IF;
        END;

        -- CHECK DIRECTORY WAS CREATED
        BEGIN
        IF ( V_VERSION >='12' and V_CDB ='YES' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                execute immediate 'create or replace directory DB_CHECKLIST as ''/tmp''';
        ELSE
                NULL;
        END IF;
    END;

        -- OPEN UTL_FILE
        P_FILE := UTL_FILE.FOPEN('DB_CHECKLIST', 'DEPLOY_'||V_PDB||'_'||to_char(SYSDATE,'DD_MM_YYYY_HH24_MI')||'.log', 'w');

        UTL_FILE.NEW_LINE (P_FILE,1);
        UTL_FILE.PUTF(P_FILE, '                                                 SCRIPT DE CHECKLIST CLARO BRASIL                \n');
        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHECK VERIFY FUNCTION WAS CREATED
        BEGIN
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK FUNCTION VERIFY_FUNCTION : ');
        SELECT STATUS INTO V_CHECK FROM DBA_OBJECTS WHERE OBJECT_NAME='VERIFY_FUNCTION' and owner='SYS' AND STATUS='VALID';
        EXCEPTION WHEN NO_DATA_FOUND THEN
                UTL_FILE.PUTF(P_FILE, 'NOTOK');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);


  --CHECK DB_CREATE_FILE_DEST
  BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                        BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK DB_CREATE_FILE_DEST : ');
                        SELECT distinct VALUE INTO V_CHECK FROM GV$PARAMETER WHERE NAME='DB_CREATE_FILE_DEST';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                        SELECT DISTINCT trim(SUBSTR(FILE_NAME , 0, INSTR(FILE_NAME, '/')-1)) INTO V_CHECK FROM DBA_DATA_FILES where trim(SUBSTR(FILE_NAME , 0, INSTR(FILE_NAME, '/')-1)) is not null;
                                        EXECUTE IMMEDIATE 'ALTER SYSTEM SET DB_CREATE_FILE_DEST='''||V_CHECK||''' SCOPE=BOTH';
                                        UTL_FILE.PUTF(P_FILE, 'OK');
                        END;
                END IF;
  END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- ENABLE RESUMABLE
        BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                        BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK RESUMABLE TIMEOUT : ');
                        SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('RESUMABLE_TIMEOUT') and value='7200';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER SYSTEM SET RESUMABLE_TIMEOUT=7200 SCOPE=BOTH';
                                UTL_FILE.PUTF(P_FILE, '7200 ');
                        END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- ENABLE RESOURCE_LIMIT
        BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                        BEGIN
                        V_COUNT:=V_COUNT+1;
                                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK RESOURCE LIMIT : ');
                                SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('RESOURCE_LIMIT') and value='TRUE';
                                EXCEPTION WHEN NO_DATA_FOUND THEN
                                        execute immediate 'ALTER SYSTEM SET RESOURCE_LIMIT=TRUE SCOPE=BOTH';
                                        UTL_FILE.PUTF(P_FILE, 'TRUE. ');
                        END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- ENABLE SEC_CASE_SENSITIVE_LOGON
    BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK SEC_CASE_SENSITIVE_LOGON : ');
                        SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('SEC_CASE_SENSITIVE_LOGON') and value='TRUE';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON=TRUE SCOPE=BOTH';
                                UTL_FILE.PUTF(P_FILE, 'TRUE. ');
                        END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- INCREASE SESSION_CACHED_CURSORS
    BEGIN
        IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                BEGIN
                V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK SESSION_CACHED_CURSORS : ');
                SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('session_cached_cursors') and value<='400';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER SYSTEM SET SESSION_CACHED_CURSORS=400 SCOPE=spfile';
                                UTL_FILE.PUTF(P_FILE, '400');
                END;
        END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- DISABLE RECYCLEBIN
        BEGIN
        IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                BEGIN
                V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK RECYCLEBIN : ');
                SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('RECYCLEBIN') and UPPER(value)=UPPER('OFF');
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        execute immediate 'ALTER SYSTEM SET RECYCLEBIN=OFF SCOPE=spfile';
                        UTL_FILE.PUTF(P_FILE, 'OFF. ');
                        END;
        END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHANGE INMEMORY_SIZE TO 1Gb
        BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                        BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK INMEMORY_SIZE : ');
                        SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('INMEMORY_SIZE') and value>='536870912';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER SYSTEM SET INMEMORY_SIZE=512M scope=spfile';
                                UTL_FILE.PUTF(P_FILE, '1GB. ');
                        END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHANGE INMEMORY_CLAUSE_DEFAULT WITH HCC
        BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                        BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK INMEMORY_CLAUSE_DEFAULT : ');
                        SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('INMEMORY_CLAUSE_DEFAULT') and value='INMEMORY MEMCOMPRESS FOR QUERY HIGH';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER SYSTEM SET INMEMORY_CLAUSE_DEFAULT="INMEMORY MEMCOMPRESS FOR QUERY HIGH" SCOPE=spfile';
                                UTL_FILE.PUTF(P_FILE, 'ALTERADO PARA INMEMORY MEMCOMPRESS FOR QUERY HIGH. ');
                        END;
                END IF;
        END;


        UTL_FILE.NEW_LINE (P_FILE,1);

        -- INCREASE PROCESSES
        BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK PROCESS : ');
                        SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('PROCESSES') and value<='400';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER SYSTEM SET PROCESSES=1000 SCOPE=spfile';
                                UTL_FILE.PUTF(P_FILE, '1000 ');
                END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- INCREASE AUDIT_SYS_OPERATIONS
        BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK AUDIT_SYS_OPERATIONS : ');
                        SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('AUDIT_SYS_OPERATIONS') and value='TRUE';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER SYSTEM SET AUDIT_SYS_OPERATIONS=TRUE SCOPE=spfile';
                                UTL_FILE.PUTF(P_FILE, 'TRUE ');
                END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHANGE AUTO DOP
        BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT' ) or ( V_VERSION >='12' and V_CDB ='NO' ) THEN
                        BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK AUTO DOP : ');
                        SELECT VALUE INTO V_CHECK FROM V$PARAMETER WHERE UPPER(NAME)=UPPER('PARALLEL_DEGREE_POLICY') and value='AUTO';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER SYSTEM SET PARALLEL_DEGREE_POLICY=AUTO SCOPE=spfile';
                                UTL_FILE.PUTF(P_FILE, 'AUTO ');
                        END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHANGE DB_FILES
        BEGIN
                IF ( V_VERSION >='12' and V_CDB ='YES' and V_PDB='CDB$ROOT') or ( V_VERSION >='12' and V_CDB ='NO') THEN
                BEGIN
                        V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK DB_FILES : ');
                        SELECT to_number(VALUE) INTO V_CHECK FROM V$PARAMETER WHERE UPPER(name)=UPPER('DB_FILES');
                        IF V_CHECK < 600 THEN
                                BEGIN
                                        execute immediate 'ALTER SYSTEM SET DB_FILES=600 SCOPE=spfile';
                                        UTL_FILE.PUTF(P_FILE, '600 ');
                                END;
                        END IF;
                END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- MOVE AUD$ AND FGA_LOG$ TO ANOTHER TBS AND CONFIGURE AUTOMATIC CLEAN
        BEGIN
                BEGIN
                V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK EXIST TABLESPACE TBS_AUDIT : ');
                select tablespace_name INTO V_CHECK from dba_tablespaces where tablespace_name='TBS_AUDIT';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        execute immediate 'create tablespace TBS_AUDIT datafile size 50M autoextend on next 1G maxsize unlimited';
                        UTL_FILE.PUTF(P_FILE, 'CRIADO. ');
                        commit;
                END;

                UTL_FILE.NEW_LINE (P_FILE,1);

                V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK TABLE AUD$ : ');
                SELECT tablespace_name into V_CHECK FROM dba_tables WHERE  table_name='AUD$';
                IF V_CHECK !='TBS_AUDIT' THEN
                        BEGIN
                                DBMS_AUDIT_MGMT.set_audit_trail_location(
                                audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
                                audit_trail_location_value => 'TBS_AUDIT');
                        END;
                UTL_FILE.PUTF(P_FILE, 'ALTERADO A AUD$ PARA A TBS_AUDIT. ');
                END IF;

                UTL_FILE.NEW_LINE (P_FILE,1);

                V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK TABLE FGA_LOG$ : ');
                SELECT tablespace_name into V_CHECK FROM dba_tables WHERE  table_name='FGA_LOG$';
                IF V_CHECK !='TBS_AUDIT' THEN
                        BEGIN
                                DBMS_AUDIT_MGMT.set_audit_trail_location(
                                audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
                                audit_trail_location_value => 'TBS_AUDIT');
                        END;
                UTL_FILE.PUTF(P_FILE, 'ALTERADO A FGA_LOG$ PARA A TBS_AUDIT. ');
                END IF;

                UTL_FILE.NEW_LINE (P_FILE,1);

                V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK TIME OF AUDIT : ');
                SELECT PARAMETER_VALUE into V_CHECK FROM dba_audit_mgmt_config_params WHERE  parameter_name='AUDIT FILE MAX AGE' and AUDIT_TRAIL='XML AUDIT TRAIL';
                IF V_CHECK != '90' THEN
                        BEGIN
                                DBMS_AUDIT_MGMT.set_audit_trail_property(
                                audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
                                audit_trail_property       => DBMS_AUDIT_MGMT.OS_FILE_MAX_AGE,
                                audit_trail_property_value => 90);
                        END;
                UTL_FILE.PUTF(P_FILE, 'ALTERADO PARA 90 DIAS. ');
                END IF;

                UTL_FILE.NEW_LINE (P_FILE,1);

                BEGIN
                V_COUNT:=V_COUNT+1;
                        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK INTERVAL OF CLEAN UP : ');
                        SELECT distinct PARAMETER_VALUE into V_CHECK FROM dba_audit_mgmt_config_params WHERE parameter_name='DEFAULT CLEAN UP INTERVAL';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                        IF V_CHECK != '24' THEN
                                BEGIN
                                DBMS_AUDIT_MGMT.init_cleanup(
                                        audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
                                        default_cleanup_interval => 24);
                                END;
                        UTL_FILE.PUTF(P_FILE, 'ALTERADO O INTERVALO PARA CADA 24HRS. ');
                        END IF;
                END;

                UTL_FILE.NEW_LINE (P_FILE,1);

                V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK RETENTION AUD$ : ');
                SELECT PARAMETER_VALUE into V_CHECK FROM dba_audit_mgmt_config_params WHERE  parameter_name='AUDIT FILE MAX AGE' and AUDIT_TRAIL='XML AUDIT TRAIL';
                IF V_CHECK !='120' then
                        BEGIN
                        DBMS_AUDIT_MGMT.set_last_archive_timestamp(
                                audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
                                last_archive_time => SYSTIMESTAMP-120);
                        END;
                UTL_FILE.PUTF(P_FILE, 'ALTERADO PARA 120 DIAS. ');
                END IF;

                UTL_FILE.NEW_LINE (P_FILE,2);

                BEGIN
                IF DBMS_AUDIT_MGMT.is_cleanup_initialized(DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD) THEN
                        DBMS_OUTPUT.put_line('YES');
                        UTL_FILE.PUTF(P_FILE, 'INICIADO O PROCESSO DO CLEANUP DE AUDITORIA. ');
                ELSE
                        DBMS_OUTPUT.put_line('NO');
                END IF;
                END;
        END;

        UTL_FILE.NEW_LINE (P_FILE,2);

        -- CHANGE LIMITS FROM DEFAULT PROFILE
        BEGIN
        V_COUNT:=V_COUNT+1;
            UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK DEFAULT LIMITS PROFILE : ');
                execute immediate 'ALTER PROFILE DEFAULT LIMIT COMPOSITE_LIMIT UNLIMITED CONNECT_TIME UNLIMITED CPU_PER_CALL UNLIMITED CPU_PER_SESSION UNLIMITED FAILED_LOGIN_ATTEMPTS UNLIMITED IDLE_TIME UNLIMITED LOGICAL_READS_PER_CALL UNLIMITED LOGICAL_READS_PER_SESSION UNLIMITED PASSWORD_GRACE_TIME UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_LOCK_TIME UNLIMITED PASSWORD_REUSE_MAX UNLIMITED PASSWORD_REUSE_TIME UNLIMITED PASSWORD_VERIFY_FUNCTION NULL PRIVATE_SGA UNLIMITED SESSIONS_PER_USER UNLIMITED ';
                UTL_FILE.PUTF(P_FILE, 'CHANGE DEFAULT LIMITS PROFILE DEFAULT.');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE PROFILE SEG_AUDIT
    BEGIN
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK ROLE SEG_AUDIT : ');
        IF V_VERSION >= '12' AND V_PDB = 'CDB$ROOT' THEN
                EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
        END IF;
                SELECT DISTINCT ROLE INTO V_CHECK FROM DBA_ROLES WHERE ROLE = 'SEG_AUDIT';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        EXECUTE IMMEDIATE 'CREATE ROLE SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.AUD$ TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.V_$INSTANCE TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_ROLES TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_PROFILES TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_ROLE_PRIVS TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_SYS_PRIVS TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_TAB_PRIVS TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_USERS TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_OBJ_AUDIT_OPTS TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_STMT_AUDIT_OPTS TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_PRIV_AUDIT_OPTS TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_AUDIT_TRAIL TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_AUDIT_SESSION TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_AUDIT_STATEMENT TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_AUDIT_OBJECT TO SEG_AUDIT';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_AUDIT_EXISTS TO SEG_AUDIT';
                        UTL_FILE.PUTF(P_FILE, 'CRIADO. ');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE PROFILE ADM_01
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK PROFILE ADM_01 : ');
                IF V_PDB = 'CDB$ROOT' THEN
                        EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                END IF;
                SELECT DISTINCT PROFILE INTO V_CHECK FROM DBA_PROFILES WHERE PROFILE = 'ADM_01';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        BEGIN
                                execute immediate 'CREATE PROFILE ADM_01 LIMIT COMPOSITE_LIMIT DEFAULT CONNECT_TIME DEFAULT CPU_PER_CALL DEFAULT CPU_PER_SESSION DEFAULT FAILED_LOGIN_ATTEMPTS 5 IDLE_TIME 60 LOGICAL_READS_PER_CALL DEFAULT LOGICAL_READS_PER_SESSION DEFAULT PASSWORD_GRACE_TIME 5 PASSWORD_LIFE_TIME 60 PASSWORD_LOCK_TIME UNLIMITED PASSWORD_REUSE_MAX 6 PASSWORD_REUSE_TIME 365 PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION PRIVATE_SGA DEFAULT SESSIONS_PER_USER DEFAULT';
                                EXCEPTION WHEN OTHERS THEN
                                UTL_FILE.PUTF(P_FILE, 'NOTOK. ');
                        END;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE PROFILE ADM_DBMON
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK PROFILE ADM_DBMON : ');
                IF V_PDB = 'CDB$ROOT' THEN
                EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                END IF;
                SELECT DISTINCT PROFILE INTO V_CHECK FROM DBA_PROFILES WHERE PROFILE = 'ADM_DBMON';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        BEGIN
                                execute immediate 'CREATE PROFILE ADM_DBMON LIMIT COMPOSITE_LIMIT UNLIMITED CONNECT_TIME 60 CPU_PER_CALL UNLIMITED CPU_PER_SESSION UNLIMITED FAILED_LOGIN_ATTEMPTS UNLIMITED IDLE_TIME 60 LOGICAL_READS_PER_CALL UNLIMITED LOGICAL_READS_PER_SESSION UNLIMITED PASSWORD_GRACE_TIME UNLIMITED PASSWORD_LIFE_TIME UNLIMITED PASSWORD_LOCK_TIME UNLIMITED PASSWORD_REUSE_MAX UNLIMITED PASSWORD_REUSE_TIME UNLIMITED PRIVATE_SGA UNLIMITED SESSIONS_PER_USER UNLIMITED';
                                EXCEPTION WHEN OTHERS THEN
                                UTL_FILE.PUTF(P_FILE, 'NOTOK. ');
                        END;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE PROFILE APL_01
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK PROFILE APL_01 : ');
                IF V_PDB = 'CDB$ROOT' THEN
                EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                END IF;
                SELECT DISTINCT PROFILE INTO V_CHECK FROM DBA_PROFILES WHERE PROFILE = 'APL_01';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        BEGIN
                                execute immediate 'CREATE PROFILE APL_01 LIMIT COMPOSITE_LIMIT DEFAULT CONNECT_TIME DEFAULT CPU_PER_CALL DEFAULT CPU_PER_SESSION DEFAULT FAILED_LOGIN_ATTEMPTS DEFAULT IDLE_TIME DEFAULT LOGICAL_READS_PER_CALL DEFAULT LOGICAL_READS_PER_SESSION DEFAULT PASSWORD_GRACE_TIME DEFAULT PASSWORD_LIFE_TIME DEFAULT PASSWORD_LOCK_TIME DEFAULT PASSWORD_REUSE_MAX DEFAULT PASSWORD_REUSE_TIME DEFAULT PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION PRIVATE_SGA DEFAULT SESSIONS_PER_USER UNLIMITED';
                                EXCEPTION WHEN OTHERS THEN
                                UTL_FILE.PUTF(P_FILE, 'NOTOK.');
                        END;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE PROFILE PRD_01
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK PROFILE PRD_01 : ');
                IF V_PDB = 'CDB$ROOT' THEN
                EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                END IF;
                SELECT DISTINCT PROFILE INTO V_CHECK FROM DBA_PROFILES WHERE PROFILE = 'PRD_01';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        BEGIN
                                execute immediate 'CREATE PROFILE PRD_01 LIMIT COMPOSITE_LIMIT DEFAULT CONNECT_TIME DEFAULT CPU_PER_CALL DEFAULT CPU_PER_SESSION DEFAULT FAILED_LOGIN_ATTEMPTS 5 IDLE_TIME 15 LOGICAL_READS_PER_CALL DEFAULT LOGICAL_READS_PER_SESSION DEFAULT PASSWORD_GRACE_TIME 5 PASSWORD_LIFE_TIME 60 PASSWORD_LOCK_TIME UNLIMITED PASSWORD_REUSE_MAX 6 PASSWORD_REUSE_TIME 365        PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION PRIVATE_SGA DEFAULT SESSIONS_PER_USER 10';
                                EXCEPTION WHEN OTHERS THEN
                                UTL_FILE.PUTF(P_FILE, 'NOTOK. ');
                        END;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE PROFILE USR_00
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK PROFILE USR_00 : ');
                IF V_PDB = 'CDB$ROOT' THEN
                EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                END IF;
                SELECT DISTINCT PROFILE INTO V_CHECK FROM DBA_PROFILES WHERE PROFILE = 'USR_00';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        BEGIN
                        execute immediate 'CREATE PROFILE USR_00 LIMIT COMPOSITE_LIMIT DEFAULT CONNECT_TIME DEFAULT CPU_PER_CALL 50 CPU_PER_SESSION 50 FAILED_LOGIN_ATTEMPTS 5 IDLE_TIME DEFAULT LOGICAL_READS_PER_CALL DEFAULT  LOGICAL_READS_PER_SESSION DEFAULT        PASSWORD_GRACE_TIME 5 PASSWORD_LIFE_TIME 60 PASSWORD_LOCK_TIME UNLIMITED PASSWORD_REUSE_MAX 6 PASSWORD_REUSE_TIME 365 PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION PRIVATE_SGA DEFAULT SESSIONS_PER_USER DEFAULT';
                        EXCEPTION WHEN OTHERS THEN
                        UTL_FILE.PUTF(P_FILE, 'NOTOK. ');
                        END;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE PROFILE USR_01
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK PROFILE USR_01 : ');
                IF V_PDB = 'CDB$ROOT' THEN
                EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                END IF;
                SELECT DISTINCT PROFILE INTO V_CHECK FROM DBA_PROFILES WHERE PROFILE = 'USR_01';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        BEGIN
                        execute immediate 'CREATE PROFILE USR_01 LIMIT COMPOSITE_LIMIT DEFAULT CONNECT_TIME DEFAULT CPU_PER_CALL 50 CPU_PER_SESSION 50 FAILED_LOGIN_ATTEMPTS 5 IDLE_TIME DEFAULT LOGICAL_READS_PER_CALL DEFAULT  LOGICAL_READS_PER_SESSION DEFAULT        PASSWORD_GRACE_TIME 5 PASSWORD_LIFE_TIME 60 PASSWORD_LOCK_TIME UNLIMITED PASSWORD_REUSE_MAX 6 PASSWORD_REUSE_TIME 365 PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION PRIVATE_SGA DEFAULT SESSIONS_PER_USER DEFAULT';
                        EXCEPTION WHEN OTHERS THEN
                        UTL_FILE.PUTF(P_FILE, 'NOTOK. ');
                        END;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);


        -- CHECK TABLESPACE USERS
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK TABLESPACE USERS : ');
                SELECT tablespace_name INTO V_CHECK FROM DBA_TABLESPACES WHERE TABLESPACE_NAME = 'USERS';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        EXECUTE IMMEDIATE 'CREATE TABLESPACE USERS DATAFILE SIZE 1G AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
                        UTL_FILE.PUTF(P_FILE,'CRIADO. ');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHECK DEFAULT TABLESPACE USERS
        BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK DEFAULT TABLESPACE : ');
                SELECT PROPERTY_VALUE INTO V_CHECK FROM DATABASE_PROPERTIES WHERE PROPERTY_NAME='DEFAULT_PERMANENT_TABLESPACE' AND PROPERTY_VALUE='USERS';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        EXECUTE IMMEDIATE 'ALTER DATABASE DEFAULT TABLESPACE USERS';
                        UTL_FILE.PUTF(P_FILE,' ALTERADO PARA USERS ');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- AWR RETENTION
        BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK AWR RETENTION : ');
                select RETENTION into V_CHECK from dba_hist_wr_control where RETENTION >= INTERVAL '40' DAY;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS ( RETENTION => 57600);
                                UTL_FILE.PUTF(P_FILE,' ALTERADO A RETENCAO DO AWR PARA 40 DIAS ');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- BLOCK CHANGE TRACKING
        BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK BLOCK CHANGE TRACKING : ');
                IF ( V_VERSION >='12' and V_CDB ='YES' and  V_PDB='CDB$ROOT') or ( V_VERSION >='12' and V_CDB ='NO') THEN
                        BEGIN
                        SELECT STATUS INTO V_CHECK FROM V$BLOCK_CHANGE_TRACKING WHERE STATUS=trim('ENABLED');
                                EXCEPTION WHEN NO_DATA_FOUND THEN
                                        EXECUTE IMMEDIATE 'ALTER DATABASE ENABLE BLOCK CHANGE TRACKING';
                                        UTL_FILE.PUTF(P_FILE,' HABILITADO.');
                        END;
                END IF;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE SEC_ORA USER
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK USER SEC_ORA : ');
                IF V_PDB = 'CDB$ROOT' THEN
                        EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                END IF;
                SELECT USERNAME INTO V_CHECK FROM DBA_USERS WHERE USERNAME = 'SEC_ORA';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        EXECUTE IMMEDIATE 'CREATE USER SEC_ORA IDENTIFIED BY ALTERAR#2007 PROFILE DEFAULT';
                        EXECUTE IMMEDIATE 'GRANT SELECT_CATALOG_ROLE,CONNECT,SEG_AUDIT,ALTER USER TO SEC_ORA';
                        BEGIN
                                EXECUTE IMMEDIATE 'ALTER USER SEC_ORA PROFILE APL_01';
                                        EXCEPTION WHEN OTHERS THEN
                                        null;
                                END;
                        UTL_FILE.PUTF(P_FILE, 'CRIADO. ');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE USER DBMON
    BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK USER DBMON : ');
                IF V_PDB = 'CDB$ROOT' THEN
                        EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                END IF;
                SELECT USERNAME INTO V_CHECK FROM DBA_USERS WHERE USERNAME = 'DBMON';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        EXECUTE IMMEDIATE 'CREATE USER DBMON IDENTIFIED BY monitor PROFILE DEFAULT';
                        EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE,UNLIMITED TABLESPACE,SELECT_CATALOG_ROLE,ALTER DATABASE,ANALYZE ANY,ANALYZE ANY DICTIONARY,ALTER SYSTEM,ADVISOR TO DBMON';
                        EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_SYSTEM  TO DBMON';
                        EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_AUTO_SQLTUNE TO DBMON';
                        BEGIN
                                EXECUTE IMMEDIATE 'ALTER USER DBMON PROFILE ADM_DBMON';
                                EXCEPTION WHEN OTHERS THEN
                                NULL;
                        END;
                        UTL_FILE.PUTF(P_FILE, 'CRIADO. ');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHECK USER DBSNMP
        BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK USER DBSNMP : ');
                EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
                select account_status into V_CHECK from dba_users where username='DBSNMP' and account_status is null;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER USER DBSNMP IDENTIFIED BY "fbac100cn" ACCOUNT UNLOCK profile DEFAULT';
                                UTL_FILE.PUTF(P_FILE, 'ALTERADO SENHA E DESBLOQUEADO');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHANGE USER SYS
        BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK USER SYS : ');
                select account_status into V_CHECK from dba_users where username='SYS' and account_status is null;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER USER SYS IDENTIFIED BY "fbac100cn" ACCOUNT UNLOCK profile DEFAULT';
                                UTL_FILE.PUTF(P_FILE, 'ALTERADO SENHA E DESBLOQUEADO');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CHANGE USER SYSTEM
        BEGIN
        V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK USER SYSTEM : ');
                select account_status into V_CHECK from dba_users where username='SYSTEM' and account_status is null;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                execute immediate 'ALTER USER SYSTEM IDENTIFIED BY "fbac100cn" ACCOUNT UNLOCK profile DEFAULT';
                                UTL_FILE.PUTF(P_FILE, 'ALTERADO SENHA E DESBLOQUEADO');
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE USER OPS$ORACLE
    BEGIN
        IF V_VERSION >= '12' AND V_PDB != 'CDB$ROOT' THEN
                EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
        END IF;
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK USER OPS$ORACLE : ');
                SELECT USERNAME INTO V_CHECK FROM DBA_USERS WHERE USERNAME = 'OPS$ORACLE';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                                EXECUTE IMMEDIATE 'CREATE USER OPS$ORACLE IDENTIFIED by fje10sd PROFILE ADM_DBMON';
                                EXECUTE IMMEDIATE 'GRANT DBA,CONNECT,SYSDBA TO OPS$ORACLE';
                                UTL_FILE.PUTF(P_FILE, 'CRIADO.');
    END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE USER N_BACENTER
    BEGIN
        IF V_VERSION >= '12' AND V_PDB != 'CDB$ROOT' THEN
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK USER N_BACENTER : ');
        begin
        SELECT USERNAME INTO V_CHECK FROM DBA_USERS WHERE USERNAME = 'N_BACENTER';
    EXCEPTION WHEN NO_DATA_FOUND THEN
        EXECUTE IMMEDIATE 'CREATE USER N_BACENTER IDENTIFIED by N_BACENTER PROFILE DEFAULT';
                    EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_DATA_FILES TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_FREE_SPACE TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_TEMP_FILES TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_OBJECTS TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.V_$DATABASE TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.V_$TEMP_EXTENT_POOL TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_TABLESPACES TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT RESOURCE TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT CONNECT TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ANY TABLE TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.FILEXT$ TO N_BACENTER';
                        EXECUTE IMMEDIATE 'GRANT SELECT ON V_$PARAMETER TO N_BACENTER';
                        EXECUTE IMMEDIATE 'alter user N_BACENTER profile APL_01';
                UTL_FILE.PUTF(P_FILE, 'CRIADO.');
                END;
                END IF;
    END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE USER HARVEST_PATCH
    BEGIN
        IF V_VERSION >= '12' AND V_PDB != 'CDB$ROOT' THEN
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK USER HARVEST_PATCH : ');
                begin
        SELECT USERNAME INTO V_CHECK FROM DBA_USERS WHERE USERNAME = 'HARVEST_PATCH';
    EXCEPTION WHEN NO_DATA_FOUND THEN
        EXECUTE IMMEDIATE 'CREATE USER HARVEST_PATCH IDENTIFIED by HARVEST_PATCH PROFILE DEFAULT';
                        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT ALTER ANY INDEX TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT ALTER ANY MATERIALIZED VIEW TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT ALTER ANY PROCEDURE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT ALTER ANY SEQUENCE  TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT ALTER ANY TABLE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT COMMENT ANY TABLE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CONNECT TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CREATE ANY INDEX TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CREATE ANY MATERIALIZED VIEW TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CREATE ANY PROCEDURE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CREATE ANY SEQUENCE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CREATE ANY TABLE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CREATE ANY VIEW TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DROP ANY INDEX TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DROP ANY MATERIALIZED VIEW TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DROP ANY PROCEDURE  TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DROP ANY SEQUENCE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DROP ANY TABLE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DROP ANY VIEW TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT GRANT ANY OBJECT PRIVILEGE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT INSERT ANY TABLE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT SELECT ANY SEQUENCE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT SELECT ANY TABLE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT UPDATE ANY TABLE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DELETE ANY TABLE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CREATE ANY TYPE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DROP ANY TYPE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT ALTER ANY TYPE TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT CREATE ANY TRIGGER TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT ALTER ANY TRIGGER TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'GRANT DROP ANY TRIGGER TO HARVEST_PATCH';
                        EXECUTE IMMEDIATE 'alter user HARVEST_PATCH profile APL_01';
                UTL_FILE.PUTF(P_FILE, 'CRIADO.');
                END;
                END IF;
    END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        -- CREATE DBA USERS

                BEGIN
                V_COUNT:=V_COUNT+1;
                UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK DBA USERS : ');

                BEGIN
                SELECT ACCOUNT_STATUS INTO V_CHECK FROM DBA_USERS WHERE USERNAME='U93237581';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                EXECUTE IMMEDIATE 'CREATE USER U93237581 IDENTIFIED by values ''7A2F598F3D7998A4'' PROFILE DEFAULT';
                                EXECUTE IMMEDIATE 'GRANT DBA,CONNECT TO U93237581';
                                BEGIN
                                        EXECUTE IMMEDIATE 'ALTER USER U93237581 PROFILE ADM_01';
                                        EXCEPTION WHEN OTHERS THEN
                                        null;
                                END;
                        UTL_FILE.PUTF(P_FILE, 'U93237581 ');
                END;
        END;

        UTL_FILE.NEW_LINE (P_FILE,1);

        BEGIN
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE, V_COUNT||' - CHECK DATABASE ARCHIVELOG : ');
        SELECT distinct LOG_MODE INTO V_CHECK FROM GV$DATABASE where LOG_MODE='ARCHIVELOG';
                EXCEPTION WHEN NO_DATA_FOUND THEN
                UTL_FILE.PUTF(P_FILE,' FAVOR HABILITAR O ARCHIVELOG ');
        END;


        UTL_FILE.NEW_LINE (P_FILE,2);
        UTL_FILE.PUTF(P_FILE,'NAO ESQUECER DE REALIZAR O RESTART DA BASE DEPOIS DE RODAR O CHECKLIST!');

        UTL_FILE.NEW_LINE (P_FILE,3);
        UTL_FILE.PUTF(P_FILE,'                          ADVERTENCIAS!           ');
        UTL_FILE.NEW_LINE (P_FILE,2);

        V_COUNT:=0;
        V_COUNT:=V_COUNT+1;

        UTL_FILE.PUTF(P_FILE,V_COUNT||'. CRIAR OS LINKS SIMBOLICOS DO TNSNAMES.ORA, SQLNET.ORA E LISTENER.ORA DO ORACLE_HOME PARA O /ETC : \n');
        UTL_FILE.PUTF(P_FILE,'ln -s /etc/sqlnet.ora $ORACLE_HOME/network/admin/sqlnet.ora \n');
        UTL_FILE.PUTF(P_FILE,'ln -s /etc/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora \n');
        UTL_FILE.PUTF(P_FILE,'ln -s /etc/listener.ora $ORACLE_HOME/network/admin/listener.ora \n');
        UTL_FILE.NEW_LINE (P_FILE,2);

        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE,V_COUNT||'. ADICIONAR AS LINHAS ABAIXO NO /etc/sqlnet.ora :\n');
        UTL_FILE.PUTF(P_FILE,'SQLNET.ALLOWED_LOGON_VERSION_SERVER=8 \n');
        UTL_FILE.PUTF(P_FILE,'SQLNET.ALLOWED_LOGON_VERSION_CLIENT=8 \n');
        UTL_FILE.PUTF(P_FILE,'SSL_CLIENT_AUTHENTICATION=TRUE \n');
        UTL_FILE.NEW_LINE (P_FILE,2);

        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE,V_COUNT||'. RMAN SE FOR PRODUCAO :\n');
        UTL_FILE.PUTF(P_FILE,V_COUNT||'.1 ADICIONAR NO /etc/tnsnames.ora O BANCO DO CATALOGO \n');
        UTL_FILE.PUTF(P_FILE,'P00RM2,p00rm2 =(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = brux0105)(PORT = 1521))(CONNECT_DATA =(SID = P00RM2)(SERVER = DEDICATED))) \n');
        UTL_FILE.PUTF(P_FILE,V_COUNT||'.2 ADICIONAR A STRING DE CONEXAO DO BANCO NO TNSNAMES.ORA DA MAQUINA BRUX0105, BRUX0721 e BRUX0074 \n');
        UTL_FILE.PUTF(P_FILE,V_COUNT||'.3 REGISTRAR O BANCO CRIADO NO CATALOGO DO RMAN \n');
        UTL_FILE.NEW_LINE (P_FILE,2);

        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE,'4. CADASTRAR BASE NA TABELA DE INVENTARIO DBMON.DATABASES PELA PAGINA http://pacaembu:8080/supora/ \n');
        UTL_FILE.NEW_LINE (P_FILE,2);

        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE,V_COUNT||'. ADICIONAR AS CHAVES DE SSH NO ~/.ssh/authorized_keys \n');
        UTL_FILE.PUTF(P_FILE,'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEApQrpSWkb/rYvVhL2DnsNZ4p9LCDIQFckjSqOAvW8JKNv6OJHh1ZnBPDVNZZGG+3BDYZeT52eXpQYWjUz6QiojcYATftLNjRDKuOL44JaNb9MxWgMU/LL/5TDqFtBmkeC2cKsYr88nswiOxRQv6bVsGa716nTLD3qkp6AO/hRIXkdLQYrtvVcqGM9hZXhEdnzXsuzNjidN5brINCuaHIH91dF6u+1wGWuIrLLnZHQOFI8MQfLWWJYcJBAZ04BNqaADoJaFkRHJ1aCr+3LFOYgHWxIIvNmPf6A2YVEDtS2D8egSzhbICt+UIPg4mMH770Lqk29zdlx5ftJI08IhKICjw== oracle@brux0156 \n');
        UTL_FILE.PUTF(P_FILE,'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+4GgNd4xMeTlZvcOZYOpV3R85/tTPFrRvTTz4pgNLlU6OqVixVNXTUSbc+RIzfp086x1NRWMr0I9jlPfRl9dFgeJY9l0UfPA/rzLYLD2XwGFgINJNZ6g2HVJixitD6Qes+N7GHDpFxyGNOzKlYIHPgXJWfU8g36ktTbbhEFvtqb2rn08LRt9e7tcKXub1TpXBmiU7WchPYkkOPtrq5LtP+ErvaHGhzb468cnmbq+plp+sr3qekx93m0exbWoRus0EUp+rHmfQvnM/3q7t9wC8Khd08clpR00qaSSEoXRvlFKopVoFa054upU8SkUx8P80RYjIv1Rk0H+HLcS/+P1V oracle@brux1279.claro.com.br \n');

        UTL_FILE.NEW_LINE (P_FILE,2);
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE,V_COUNT||'. VALIDAR SE O AGENT DO OPENVIEW ESTA INSTALADO. \n');

        UTL_FILE.NEW_LINE (P_FILE,2);
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE,V_COUNT||'. VALIDAR SE FOI APLICADO O ULTIMO PATCH NO BANCO. \n');

        UTL_FILE.NEW_LINE (P_FILE,2);
        V_COUNT:=V_COUNT+1;
        UTL_FILE.PUTF(P_FILE,V_COUNT||'. CONFIGURAR A POLITICA DO ADRCI SHORT_POLICY e LONGP_POLICY : \n');
        UTL_FILE.PUTF(P_FILE,V_COUNT||'.1.1 AMBIENTE DE TESTE / HOMOLOGACAO / DESENVOLVIMENTO : \n');
        UTL_FILE.PUTF(P_FILE,'for f in $( adrci exec="show homes" | grep -v "ADR Homes:" ); do echo "${f}:"; adrci exec="set home $f; set control \(SHORTP_POLICY = 360, LONGP_POLICY = 360\);" ; done \n');
        UTL_FILE.PUTF(P_FILE,V_COUNT||'.1.2 AMBIENTE DE PRODUCAO : \n');
        UTL_FILE.PUTF(P_FILE,'for f in $( adrci exec="show homes" | grep -v "ADR Homes:" ); do echo "${f}:"; adrci exec="set home $f; set control \(SHORTP_POLICY = 720, LONGP_POLICY = 720\);" ; done \n');

        UTL_FILE.NEW_LINE (P_FILE,1);
        UTL_FILE.FFLUSH (P_FILE);

END;

