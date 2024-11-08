-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/users.sql
-- Author       : Tim Hall
-- Description  : Displays information about all database users.
-- Requirements : Access to the dba_users view.
-- Call Syntax  : @users [ username | % (for all)]
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
COLUMN username       FORMAT A25
COLUMN name           FORMAT A10
COLUMN account_status FORMAT A16
COLUMN default_tbs    FORMAT A24
COLUMN temp_tbs       FORMAT A20
COLUMN profile        FORMAT A19
COLUMN lock_date      FORMAT A10
COLUMN expiry_date    FORMAT A10
COLUMN created        FORMAT A10
COLUMN initial_rsrc_consumer_group FORMAT A36
SELECT substr(c.name,1,25) name,
       u.username,
       u.account_status,
       TO_CHAR(u.lock_date, 'DD/MM/YYYY') AS lock_date,
       TO_CHAR(u.expiry_date, 'DD/MM/YYYY') AS expiry_date,
       u.default_tablespace   as default_tbs,
       u.temporary_tablespace as temp_tbs,
       TO_CHAR(u.created, 'DD/MM/YYYY') AS created,
       u.profile
       --u.initial_rsrc_consumer_group
FROM        cdb_users u
JOIN        v$containers c
  ON        u.con_id = c.con_id
ORDER BY    c.name, u.username
/

SET VERIFY ON
