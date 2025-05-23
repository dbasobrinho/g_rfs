-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/db_links.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database links.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_links
-- Last Modified: 11/05/2007
-- -----------------------------------------------------------------------------------
SET LINESIZE 250
SET pages  1000
COLUMN db_link FORMAT A30
COLUMN host FORMAT A60

SELECT owner,
       db_link,
       username,
       host
FROM   dba_db_links
ORDER BY owner, db_link;
