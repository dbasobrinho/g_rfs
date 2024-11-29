-----------------------------------------------------------------------------
--
--   
--  NAME
--    mtcsa.sql
-- 
--  DESCRIPTON
--    Make script test case - query AWR 
--
--  HISTORY
--    12/12/2018 => Valter Aquino
--
-----------------------------------------------------------------------------

set sqlblanklines on
set trimspool on
set trimout on
set feedback off;
set verify off;
set long 999999;
set linesize 255;
set pagesize 50000;
set timing off;
set head off;
set tab off;
--
accept sql_id char prompt "Enter SQL ID ==> "


var isdigits number;
var bind_count number;
var v_snap_id number;

col sql_fulltext for a300;

begin

   --
   -- Verifica se existe Bind Variables
   --
   
   SELECT count(*) into :bind_count
     FROM DBA_HIST_SQLBIND
    WHERE sql_id = '&sql_id';
   
   
   --
   -- Verifica se nome da variavel e numerico
   --
   
   if :bind_count > 0 then
      SELECT case regexp_substr(replace(name,':',''),'[[:digit:]]') when replace(name,':','') then 1 end into :isdigits
        FROM DBA_HIST_SQLBIND
       WHERE sql_id='&sql_id'
         AND rownum < 2;
   end if;

   --
   -- Obtem o snap_id que contem as binds
   --
   
   if :bind_count > 0 then
      SELECT snap_id into :v_snap_id
        FROM dba_hist_sqlbind
       WHERE sql_id='&sql_id'
         AND rownum < 2;
   end if;
   
end;
/

 
  
SELECT 'PROMPT .        '      FROM DUAL UNION ALL
SELECT 'PROMPT . .      '      FROM DUAL UNION ALL
SELECT 'PROMPT . . .    '      FROM DUAL UNION ALL
SELECT 'PROMPT Realizando teste detalhado do SQID ##BóBó ' FROM DUAL UNION ALL
SELECT 'PROMPT . . .    '      FROM DUAL UNION ALL
SELECT 'PROMPT . .      '      FROM DUAL UNION ALL
SELECT 'PROMPT .        '      FROM DUAL UNION ALL
SELECT 'PROMPT          '      FROM DUAL UNION ALL
SELECT 'SET TERMOUT     OFF  ' FROM DUAL UNION ALL
SELECT 'SET LINES       900  ' FROM DUAL UNION ALL
SELECT 'SET PAGES       900  ' FROM DUAL UNION ALL
SELECT 'SET TRIMOUT     ON   ' FROM DUAL UNION ALL
SELECT 'SET TRIMSPOOL   ON   ' FROM DUAL UNION ALL
SELECT 'SET VERIFY      OFF  ' FROM DUAL UNION ALL
SELECT 'SET timing      ON   ' FROM DUAL UNION ALL
SELECT 'SET date        ON   ' FROM DUAL UNION ALL
SELECT 'SET feed        ON   ' FROM DUAL UNION ALL
SELECT 'COL sql_id               FOR A16;               ' FROM DUAL UNION ALL
SELECT 'COL predicate            FOR A70;               ' FROM DUAL UNION ALL
SELECT 'COL object_owner         FOR A21;               ' FROM DUAL UNION ALL
SELECT 'COL object_name          FOR A35;               ' FROM DUAL UNION ALL
SELECT 'COL policy_group         FOR A21;               ' FROM DUAL UNION ALL
SELECT 'COL PLAN_TABLE_OUTPUT    FOR A500 word_wrapped  ' FROM DUAL UNION ALL
SELECT 'ALTER SESSION SET statistics_level=ALL;         ' FROM DUAL UNION ALL
SELECT 'EXEC dbms_application_info.set_module( module_name => ''TUN'', action_name =>  ''TUN''); ' FROM DUAL UNION ALL
SELECT 'alter session set optimizer_use_invisible_indexes=true; ' FROM DUAL
/
SELECT distinct 'ALTER SESSION SET current_schema='||PARSING_SCHEMA_NAME||';' 
  FROM dba_hist_sqlstat 
 WHERE sql_id = '&sql_id'
   AND snap_id = :v_snap_id
/
 
SELECT DISTINCT(var_text) FROM ( 
       SELECT 'variable '||substr(case :isdigits when 1 then replace(name,':',':N') else name end,2,30)||' '||DATATYPE_STRING||';' as var_text 
         FROM dba_hist_sqlbind 
        WHERE sql_id='&sql_id'
          AND snap_id = :v_snap_id)
 ORDER BY 1
/

SELECT 'exec  '||case :isdigits when 1 then replace(name,':',':N') else name end||' := '||decode(DATATYPE,2,null,1,'''')||VALUE_STRING||decode(DATATYPE,2,null,1,'''')||';' as var_text 
  FROM dba_hist_sqlbind   
 WHERE sql_id='&sql_id'
   AND snap_id = :v_snap_id
/
SELECT 'SET TERMOUT on;'      FROM DUAL
/
--
-- Generate statement
--
--SELECT regexp_replace(sqltext,'(select |SELECT )','select /* test_&sql_id */ ',1,1) sqltext from (
--select case :isdigits when 1 then replace(DBMS_LOB.substr(sql_text,4000,1),':',':N') else DBMS_LOB.substr(sql_text,4000,1) end ||';'  sqltext
--from dba_hist_sqltext
--where sql_id = '&sql_id')
--/

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_sql_text CLOB;
    v_result CLOB;
    v_line VARCHAR2(4000);
    v_position PLS_INTEGER := 1;
    v_end_position PLS_INTEGER;
BEGIN
    SELECT 
        CASE :isdigits 
            WHEN 1 THEN REPLACE(sql_text, ':', ':N') 
            ELSE sql_text 
        END
    INTO v_sql_text
    FROM dba_hist_sqltext
    WHERE sql_id = '&sql_id';

    -- Modificar o texto SQL e adicionar o comentário de teste
    v_result := regexp_replace(v_sql_text, '(select |SELECT )', 'select /* test_&sql_id */ ', 1, 1);

    -- Processar cada linha do CLOB e remover linhas em branco
    LOOP
        -- Encontrar a posição do próximo caractere de nova linha
        v_end_position := INSTR(v_result, CHR(10), v_position);
        
        -- Se não houver mais quebras de linha, processar o resto do texto e sair do loop
        IF v_end_position = 0 THEN
            v_line := SUBSTR(v_result, v_position);
            EXIT;
        ELSE
            v_line := SUBSTR(v_result, v_position, v_end_position - v_position);
            v_position := v_end_position + 1;
        END IF;

        -- Remover espaços no início e no final e verificar se a linha não está em branco
        IF TRIM(v_line) IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE(v_line);
        END IF;
    END LOOP;
END;
/


-- 8vv60vqr463s1


select 'column sql_id new_value m_sql_id' from dual;
select 'column child_number new_value m_child_no' from dual;
select 'SELECT sql_id, child_number FROM v$sql WHERE sql_text LIKE ''%test_&sql_id%'' AND sql_text NOT LIKE ''%v$sql%'' AND sql_text NOT LIKE ''%regexp_replace%'';' from dual;


select 'SELECT * FROM TABLE (dbms_xplan.display_cursor ('''||'&'||'m_sql_id'','||'&'||'m_child_no,''ADVANCED ALLSTATS LAST''));' from dual;

UNDEFINE sql_id


set feedback on verify on timing on head on;
set lines 200 pages 100



