-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_object_search.sql                                           |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Prompt the user for a query string and look for any object that |
-- |            contains that string.                                           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Object Search Dependencies                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT Object_name CHAR PROMPT 'Enter search string (Object_name:) : '

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN owner           FORMAT A20    HEADING "Owner"
COLUMN name            FORMAT A45    HEADING "Object Name"
COLUMN type            FORMAT A18    HEADING "Object Type"
COLUMN linhas          FORMAT A40    HEADING "Linhas"

select v.owner
      ,v.name
      ,v.type
      ,to_char(WM_CONCAT(v.line)) linhas
  from all_source v
 where upper(v.text) like '%&Object_name%'
 group by v.owner
         ,v.name
         ,v.type
union
select owner
      ,h.name
      ,h.type
      ,' ' linhas
  from dba_dependencies h
 where h.referenced_name = '&Object_name'
   and h.type not in
       ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER')
 order by 1, 3
/

