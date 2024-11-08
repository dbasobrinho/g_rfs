--Modificado por Morien H. Bendinelli em 28/03/2022
 
COL DATA         FOR a22
COL message_text FOR a150
SET ECHO        OFF
SET HEADING     ON
SET LINES       600
SET PAGES       600
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON

SET FEEDBACK    OFF
SET SERVEROUTPUT ON
SET VERIFY OFF
SET TERMOUT OFF;
    DECLARE
        cmd VARCHAR2(128);
    BEGIN
    SELECT
            CASE WHEN
                NOT EXISTS (SELECT 1 FROM dba_objects WHERE object_name = 'V_ALERT_LOG' AND OBJECT_TYPE = 'VIEW')
            THEN 'CREATE VIEW V_ALERT_LOG AS SELECT * FROM X$DBGALERTEXT'
            END  
            INTO cmd
            FROM dual;
            --DBMS_OUTPUT.PUT_LINE(cmd);
    IF cmd IS NOT NULL THEN
        EXECUTE IMMEDIATE cmd;
    END IF;
    SELECT
            CASE WHEN
                NOT EXISTS (SELECT 1 FROM dba_objects WHERE object_name = 'V_ALERT_LOG' AND OBJECT_TYPE = 'SYNONYM')
            THEN 'CREATE PUBLIC SYNONYM V_ALERT_LOG FOR SYS.V_ALERT_LOG'
            END  
            INTO cmd
            FROM dual;
            --DBMS_OUTPUT.PUT_LINE(cmd);
    IF cmd IS NOT NULL THEN
        EXECUTE IMMEDIATE cmd;
    END IF;
END;
/
SET TERMOUT ON;
--   script para ver se houve erros no alert.log ultimos 2 dias.
col data         for a22
col message_text for a150
SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     ON
SET LINES       600
SET PAGES       600
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
PROMPT**********************************************************
PROMPT******************  ULTIMAS 300 LINHAS  ******************
PROMPT**********************************************************
 select to_char (ORIGINATING_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') data, message_text
                from v_alert_log
                where indx > (select count(*)-300 from v_alert_log )
/
PROMPT
PROMPT**********************************************************
PROMPT************ ERROS ENCONTRADOS ULTIMOS 2 DIAS ************
PROMPT**********************************************************
 select to_char (ORIGINATING_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') data, message_text
                from v_alert_log
                where trunc(ORIGINATING_TIMESTAMP) >  trunc((SYSDATE) -2)
                  and (message_text like '%ORA-%' or message_text like '%cannot allocate new log%' or message_text like 'TNS-%')
/
PROMPT**********************************************************
PROMPT . . .
SET FEEDBACK    ON