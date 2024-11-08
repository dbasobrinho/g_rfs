set define off
SET LINES 500
SET PAGES 200 
SET LONG 10000
set echo off
SET FEEDBACK off
alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | ORACLE COLORED SQL                      [ref_marcar_sql_color_awr.txt] |
PROMPT | SQL> EXEC DBMS_WORKLOAD_REPOSITORY.ADD_COLORED_SQL('&xx_SQLID');       |
PROMPT | SQL> EXEC DBMS_WORKLOAD_REPOSITORY.REMOVE_COLORED_SQL('&xx_SQLID');    |
PROMPT | SQL>  @$ORACLE_HOME/rdbms/admin/awrsqrpt.sql                           |
PROMPT +------------------------------------------------------------------------+
PROMPT
COL INST_ID              FOR 99999;
COL sql_id               FOR A16;
COL SQL_TEXT             FOR A145;
COL BIND_NAME            FOR A10;
COL BIND_STRING          FOR A80;
COL LAST_CAPTURED        FOR A20;
SET FEEDBACK on 
select DBID, SQL_ID, OWNER, to_char(CREATE_TIME,'dd/mm/yyyy hh24:mi:ss') CREATE_TIME from sys.wrm$_colored_sql order by CREATE_TIME;
--select DBID, SQL_ID, to_char(CREATE_TIME,'dd/mm/yyyy hh24:mi:ss')  from DBA_HIST_COLORED_SQL;
SET FEEDBACK on                                                                                         
PROMPT.                                                                                                                     ______ _ ___ 
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT                                                                                                                                   
set define on