SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : SYNONYM INFORMATION                                         |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT SYNONYM_NAME CHAR PROMPT 'Enter SYNONYM_NAME  : '

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET LONG        9000
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | SYNONYM INFORMATION                                                    |
PROMPT +------------------------------------------------------------------------+

COLUMN SYN_OWNER               FORMAT a20               HEADING "SYN_OWNER"
COLUMN SYN_NAME                FORMAT a30               HEADING "SYN_NAME"
COLUMN OBJ_OWNER               FORMAT a20               HEADING "OBJ_OWNER"
COLUMN OBJ_NAME                FORMAT a30               HEADING "OBJ_NAME"
COLUMN DB_LINK                 FORMAT a30               HEADING "DB_LINK"

SELECT S.OWNER as SYN_OWNER,
       S.SYNONYM_NAME as SYN_NAME,
       S.TABLE_OWNER as OBJ_OWNER,
       S.TABLE_NAME as OBJ_NAME,
       s.DB_LINK
  FROM DBA_SYNONYMS S
  LEFT JOIN DBA_OBJECTS O
    ON S.TABLE_OWNER = O.OWNER
   AND S.TABLE_NAME = O.OBJECT_NAME
 WHERE s.SYNONYM_NAME  = upper('&SYNONYM_NAME')
order by S.OWNER
/

PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 




