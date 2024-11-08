SET LINES 500
SET PAGES 100
SET LONG 10000
set echo off
SET FEEDBACK off
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | BIND VARIABLE SQL_ID                                    [coe_bind.sql] |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT XX_sql_id char   PROMPT 'SQL ID = '
PROMPT
COL INST_ID              FOR 99999;
COL sql_id               FOR A16;
COL SQL_TEXT             FOR A145;
COL BIND_NAME            FOR A10;
COL BIND_STRING          FOR A80;
COL LAST_CAPTURED        FOR A20;

SELECT	distinct t.SQL_ID, T.SQL_TEXT SQL_TEXT
FROM  	GV$SQL T  ,
        GV$SQL_BIND_CAPTURE B  
WHERE  	t.SQL_ID = b.SQL_ID
and     t.INST_ID = b.INST_ID
and     B.VALUE_STRING IS NOT NULL  
AND 	t.SQL_ID='&XX_sql_id'
/
SELECT	to_char(b.LAST_CAPTURED,'dd/mm/yyyy hh24:mi:ss') as LAST_CAPTURED,
        t.INST_ID, B.NAME BIND_NAME,
	    B.VALUE_STRING BIND_STRING
FROM  	GV$SQL T  ,
        GV$SQL_BIND_CAPTURE B  
WHERE  	t.SQL_ID = b.SQL_ID
and     t.INST_ID = b.INST_ID
and     B.VALUE_STRING IS NOT NULL  
AND 	t.SQL_ID='&&XX_sql_id'
order by t.INST_ID, B.NAME
/
SET FEEDBACK on                                                                                         
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT                                                                                                                                   

