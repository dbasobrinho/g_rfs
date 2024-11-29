-----------------------------------------------------------------------------
--
--    
--  NAME
--    mtcs.sql
-- 
--  DESCRIPTON
--    Make test case script
--
--  HISTORY
--    18/05/2015 => Valter Aquino
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
SET LONGCHUNKSIZE 1000
SET WRAP ON
--
accept sql_id char prompt "Enter SQL ID ==> "
accept child_no char prompt "Enter Child Number ==> " default 0

var isdigits number;
var bind_count number;

col sql_fulltext for a300;
col formatted_sql for a300;

begin

   --
   -- Verifica se existe Bind Variables
   --
   
   SELECT count(*) into :bind_count
     FROM v$sql_bind_capture
    WHERE sql_id = '&sql_id';
   
   
   --
   -- Verifica se nome da variavel e numerico
   --
   
   if :bind_count > 0 then
      SELECT case regexp_substr(replace(name,':',''),'[[:digit:]]') when replace(name,':','') then 1 end into :isdigits
        FROM v$sql_bind_capture
       WHERE sql_id='&sql_id'
         AND child_number = &child_no
         AND rownum < 2;
   end if;
   
end;
/

SELECT 'ALTER SESSION SET statistics_level=ALL;' 
  FROM DUAL;

SELECT 'ALTER SESSION SET current_schema='||PARSING_SCHEMA_NAME||';' 
  FROM v$sqlarea 
 WHERE sql_id = '&sql_id';
 
SELECT DISTINCT(var_text) FROM ( 
       SELECT 'variable '||substr(case :isdigits when 1 then replace(name,':',':N') else name end,2,30)||' '||DATATYPE_STRING||';' as var_text 
         FROM v$sql_bind_capture 
        WHERE sql_id='&sql_id')
 ORDER BY 1;
 


SELECT 'exec  '||case :isdigits when 1 then replace(b.name,':',':N') else b.name end||' := '||decode(b.DATATYPE,2,null,1,'''')||VALUE_STRING||decode(b.DATATYPE,2,null,1,'''')||';' as var_text 
  FROM v$sql t  join v$sql_bind_capture b  using (sql_id) 
 WHERE b.value_string is not null
   AND b.HASH_VALUE = t.HASH_VALUE
   AND b.CHILD_NUMBER = t.CHILD_NUMBER
   AND sql_id='&sql_id'
   AND b.child_number = &child_no;


--
-- Generate statement
--

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_sql_text CLOB;
    v_result CLOB;
    v_line VARCHAR2(4000);
    v_position PLS_INTEGER := 1;
    v_end_position PLS_INTEGER;
BEGIN /*++REMOVER_DO_SEL_DO_GUINA_XX++*/
    SELECT 
        CASE :isdigits 
            WHEN 1 THEN REPLACE(sql_text, ':', ':N') 
            ELSE sql_text 
        END
    INTO v_sql_text
    FROM dba_hist_sqltext
    WHERE sql_id = '&sql_id';

    -- Modificar o texto SQL e adicionar o comentário de teste
    v_result := regexp_replace(v_sql_text, '(select |SELECT )', 'select /* CASE_DBA_&sql_id */ ', 1, 1);

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
	DBMS_OUTPUT.PUT_LINE('/');
END;
/


select 'column sql_id new_value m_sql_id' from dual;
select 'column child_number new_value m_child_no' from dual;
select 'SELECT sql_id, child_number FROM v$sql WHERE sql_text LIKE ''%CASE_DBA_&sql_id%'' AND sql_text NOT LIKE ''%v$sql%'' AND sql_text NOT LIKE ''%++REMOVER_DO_SEL_DO_GUINA_XX++%'';' from dual;

select 'SELECT * FROM TABLE (dbms_xplan.display_cursor ('''||'&'||'m_sql_id'','||'&'||'m_child_no,''ADVANCED ALLSTATS LAST''));' from dual;

UNDEFINE sql_id 
UNDEFINE child_no

set feedback on verify on timing on head on;
set lines 188 pages 300



