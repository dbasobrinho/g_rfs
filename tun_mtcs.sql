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
--
accept sql_id char prompt "Enter SQL ID ==> "
accept child_no char prompt "Enter Child Number ==> " default 0

var isdigits number;
var bind_count number;

col sql_fulltext for a300;

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

select regexp_replace(sql_fulltext,'(select |SELECT )','select /* simula_&sql_id */ ',1,1) sql_fulltext from (
select case :isdigits when 1 then replace(sql_fulltext,':',':N') else sql_fulltext end ||';' sql_fulltext
from v$sqlarea
where sql_id = '&sql_id');

select 'column sql_id new_value m_sql_id' from dual;
select 'column child_number new_value m_child_no' from dual;
select 'SELECT sql_id, child_number FROM v$sql WHERE sql_text LIKE ''%simula_&sql_id%'' AND sql_text NOT LIKE ''%v$sql%'';' from dual;


select 'SELECT * FROM TABLE (dbms_xplan.display_cursor ('''||'&'||'m_sql_id'','||'&'||'m_child_no,''ADVANCED ALLSTATS LAST''));' from dual;

UNDEFINE sql_id 
UNDEFINE child_no

set feedback on verify on timing on head on;
set lines 200 pages 100



