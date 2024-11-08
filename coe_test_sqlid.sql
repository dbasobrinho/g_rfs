-- |----------------------------------------------------------------------------|
-- | Objetivo   : Testar um SQLID com suas variaveis                            |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 26/05/2019 >> Aproveitando e fazendo no pelo                  |
-- | Exemplo    : coe_test_sqlid                                                |
-- | Arquivo    : coe_test_sqlid.sql                                            |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
col fn new_value banco;
SELECT 'Nome do Arquivo_'||TO_CHAR(SYSDATE, 'YYMMDD')||'.log' as fn from dual;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Test SQL ID                                                 |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
 
PROMPT
ACCEPT sql_id     CHAR PROMPT 'Enter SQL ID                : ' default 765prv52cuxsr
ACCEPT child_no   CHAR PROMPT "Enter C.Number <>default=0> :"  default 0
PROMPT

SET TERMOUT OFF;
col fn new_value banco;
SELECT '&&sql_id'||'_test_'||TO_CHAR(SYSDATE, 'YYYYMMDD_hh24miss')||'.sql' as fn from dual;
SET TERMOUT ON;


set sqlblanklines   on
set trimspool   	on
set trimout 		on
set feedback 		off;
set verify 			off;
set long 			999999;
set linesize 		255;
set pagesize 		50000;
set timing 			off;
set head 			off;
set tab 			off;
var isdigits 		number;
var bind_count 		number;
col sql_fulltext 	for a300;
begin
   SELECT count(*) into :bind_count 
     FROM v$sql_bind_capture
    WHERE sql_id = '&&&sql_id';
   if :bind_count > 0 then
      SELECT case regexp_substr(replace(name,':',''),'[[:digit:]]') when replace(name,':','') then 1 end into :isdigits
        FROM v$sql_bind_capture
       WHERE sql_id='&&sql_id'
         AND child_number = &child_no
         AND rownum < 2;
   end if;
end;
/
spool &BANCO; 
SELECT 'ALTER SESSION SET statistics_level=ALL;' FROM DUAL
 /
SELECT 'ALTER SESSION SET current_schema='||PARSING_SCHEMA_NAME||';' 
  FROM v$sqlarea 
 WHERE sql_id = '&&sql_id'
/
SELECT 'exec dbms_application_info.set_module( module_name => ''TSTS! WORKING [ZICA]. . . [ZICA]'', action_name =>  ''TSTS! ZICA [ZICA]. . . [rfs]'');' FROM DUAL
/
 SELECT DISTINCT(var_text) FROM ( 
       SELECT 'variable '||substr(name,2,30)||' '||DATATYPE_STRING||';' as var_text 
         FROM v$sql_bind_capture 
        WHERE sql_id='&&sql_id')
 ORDER BY 1
/
SELECT 'exec  '||b.name||' := '||decode(b.DATATYPE,2,null,1,'''')||VALUE_STRING||decode(b.DATATYPE,2,null,1,'''')||';' as var_text 
  FROM v$sql t  join v$sql_bind_capture b  using (sql_id) 
 WHERE b.value_string is not null
   AND b.HASH_VALUE = t.HASH_VALUE
   AND b.CHILD_NUMBER = t.CHILD_NUMBER
   AND sql_id='&&sql_id'
   AND b.child_number = &child_no
/ 
select regexp_replace(sql_fulltext,'(select |SELECT )','select /*##test_RFS_&sql_id##*/ ',1,1) sql_fulltext from (
select case :isdigits when 1 then replace(sql_fulltext,':',':N') else sql_fulltext end ||';' sql_fulltext
from v$sqlarea
where sql_id = '&&sql_id')
/
select 'column sql_id new_value m_sql_id' from dual
/
select 'column child_number new_value m_child_no' from dual
/
select 'SELECT sql_id, child_number FROM v$sql WHERE sql_text LIKE ''%##test_RFS_&sql_id##%'' AND INSTR(upper(sql_text), upper(''gv$sql''))= 0 AND    INSTR(upper(sql_text), upper(''EXPLAIN PLAN'')) = 0 ;' from dual
/
select 'SELECT * FROM TABLE (dbms_xplan.display_cursor ('''||'&&'||'m_sql_id'','||'&&'||'m_child_no,''ADVANCED ALLSTATS LAST''));' from dual
/
spool off;
UNDEFINE sql_id 
UNDEFINE child_no
set feedback on verify on timing on head on;
set lines 200 pages 100
select '@'||'&BANCO' as EXECUTE_TESTE_TIRULIPA from dual
/
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT



