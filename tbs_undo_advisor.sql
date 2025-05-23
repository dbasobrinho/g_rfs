--Script: UNDO_ADVISOR 
--Data:   24/12/2015
--Autor: Marcio Guimaraes
--Consideracao: Deve ser executa com usuario com permissao de DBA
--Finalidade: Mostra se o undo está dimensionado de forma apropriada
SET SERVEROUT ON SIZE 1000000
DECLARE
 pro VARCHAR2(200);
 rec VARCHAR2(200);
 rtn VARCHAR2(200);
 ret NUMBER;
 utb NUMBER;
 retval NUMBER;
BEGIN
 DBMS_OUTPUT.PUT_LINE(DBMS_UNDO_ADV.UNDO_ADVISOR(1));
 DBMS_OUTPUT.PUT_LINE('Required Undo Size (megabytes): ' || DBMS_UNDO_ADV.REQUIRED_UNDO_SIZE
(900));
 retval := DBMS_UNDO_ADV.UNDO_HEALTH(pro, rec, rtn, ret, utb);
 DBMS_OUTPUT.PUT_LINE('Problem: ' || pro);
 DBMS_OUTPUT.PUT_LINE('Advice: ' || rec);
 DBMS_OUTPUT.PUT_LINE('Rational: ' || rtn);
 DBMS_OUTPUT.PUT_LINE('Retention: ' || TO_CHAR(ret));
 DBMS_OUTPUT.PUT_LINE('UTBSize: ' || TO_CHAR(utb));
END;