SET LINESIZE 150
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEAD OFF
SET PAGES 1000
SET LINES 1000
SET TERMOUT OFF
SET SERVEROUTPUT ON

DECLARE

  V_SQL      V$SQL.SQL_TEXT%TYPE;
  vNewUser   VARCHAR2(100) ;
  vPassWord  VARCHAR2(100)  := 'tivit123';
  vUserModel VARCHAR2(100) ;

  /*DBA_USERS*/
  CURSOR C1 IS
    SELECT DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, PROFILE
      FROM DBA_USERS
     WHERE USERNAME = UPPER(vUserModel);

  /*DBA_ROLE_PRIVS*/
  CURSOR C2 IS
    SELECT GRANTED_ROLE, ADMIN_OPTION
      FROM DBA_ROLE_PRIVS
     WHERE GRANTEE = UPPER(vUserModel);

  /*DBA_SYS_PRIVS*/
  CURSOR C3 IS
    SELECT PRIVILEGE, ADMIN_OPTION
      FROM DBA_SYS_PRIVS
     WHERE GRANTEE = UPPER(vUserModel);

  /*DBA_TAB_PRIVS*/
  CURSOR C4 IS
    SELECT PRIVILEGE, OWNER, TABLE_NAME, GRANTABLE
      FROM DBA_TAB_PRIVS
     WHERE GRANTEE = UPPER(vUserModel);

  /*DBA_COL_PRIVS*/
  CURSOR C5 IS
    SELECT PRIVILEGE, COLUMN_NAME, OWNER, TABLE_NAME
      FROM DBA_COL_PRIVS
     WHERE GRANTEE = UPPER(vUserModel);

  /*DBA_ROLE_PRIVS*/
  CURSOR C6 IS
    SELECT GRANTED_ROLE
      FROM DBA_ROLE_PRIVS
     WHERE GRANTEE = UPPER(vUserModel)
       AND DEFAULT_ROLE = 'YES';

  /*DBA_TS_QUOTAS*/
  CURSOR C7 IS
    SELECT MAX_BYTES, TABLESPACE_NAME
      FROM DBA_TS_QUOTAS
     WHERE USERNAME = UPPER(vUserModel);

BEGIN
for cao in (select username from dba_users)
loop
  vNewUser   := cao.username;
  vUserModel := cao.username;
  FOR A IN C1 LOOP
  
    V_SQL := 'CREATE USER ' || Upper(vNewUser) || ' IDENTIFIED BY ' ||
             vPassWord || ' DEFAULT TABLESPACE ' || A.DEFAULT_TABLESPACE ||
             ' TEMPORARY TABLESPACE ' || A.TEMPORARY_TABLESPACE ||
             ' PROFILE ' || A.PROFILE || ';';
  
    DBMS_OUTPUT.PUT_LINE(V_SQL);
  END LOOP;

  V_SQL := NULL;

  FOR B IN C2 LOOP
  
    V_SQL := 'GRANT ' || B.GRANTED_ROLE || ' TO ' || vNewUser ||
             ' WITH ADMIN OPTION' || ';';
  
    DBMS_OUTPUT.PUT_LINE(V_SQL);
  
  END LOOP;

  V_SQL := NULL;

  FOR C IN C3 LOOP
  
    V_SQL := 'GRANT ' || C.PRIVILEGE || ' TO ' || vNewUser ||
             ' WITH ADMIN OPTION' || ';';
  
    DBMS_OUTPUT.PUT_LINE(V_SQL);
  
  END LOOP;

  V_SQL := NULL;

  FOR D IN C4 LOOP
  
    V_SQL := 'GRANT ' || D.PRIVILEGE || ' ON ' || D.OWNER || '.' ||
             D.TABLE_NAME || ' TO ' || vNewUser || ' WITH ADMIN OPTION' || ';';
  
    DBMS_OUTPUT.PUT_LINE(V_SQL);
  
  END LOOP;

  V_SQL := NULL;

  FOR E IN C5 LOOP
  
    V_SQL := 'GRANT ' || E.PRIVILEGE || '(' || E.COLUMN_NAME || ') ON ' ||
             E.OWNER || '.' || E.TABLE_NAME || ' TO ' || vNewUser || ';';
  
    DBMS_OUTPUT.PUT_LINE(V_SQL);
  
  END LOOP;

  V_SQL := NULL;

  FOR F IN C6 LOOP
  
    V_SQL := 'ALTER USER ' || vNewUser || ' DEFAULT ROLE ' ||
             F.GRANTED_ROLE || ';';
  
    DBMS_OUTPUT.PUT_LINE(V_SQL);
  
  END LOOP;

  V_SQL := NULL;

  FOR G IN C7 LOOP
  
    V_SQL := 'ALTER USER ' || vNewUser || ' QUOTA ' || G.MAX_BYTES ||
             ' ON ' || G.TABLESPACE_NAME || ';';
  
    DBMS_OUTPUT.PUT_LINE(V_SQL);
  
  END LOOP;
end loop; --cao
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    DBMS_OUTPUT.PUT_LINE('Erro na execução da query.');
    DBMS_OUTPUT.PUT_LINE('Entre em contato com o administrador.');
    DBMS_OUTPUT.PUT_LINE('Código Oracle: ' || SQLCODE);
    DBMS_OUTPUT.PUT_LINE('Mensagem Oracle: ' || SUBSTR(SQLERRM,1,100));
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
END;
/
