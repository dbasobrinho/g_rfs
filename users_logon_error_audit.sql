-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/users_by.sql
-- Author       : Tim Hall
-- Description  : Displays information about all database users.
-- Requirements : Access to the dba_users view.
-- Call Syntax  : @users_by [ username | % (for all)]
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
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

COLUMN username                    FORMAT A20
COLUMN account_status              FORMAT A16
COLUMN lock_date                   FORMAT A16
COLUMN expiry_date                 FORMAT A16
COLUMN default_tbs                 FORMAT A18
COLUMN temp_tbs                    FORMAT A13
COLUMN created                     FORMAT A16
COLUMN profile                     FORMAT A19
COLUMN consumer_group              FORMAT A20


PROMPT 	--## AUDIT ERRO DE LOGIN ##
PROMPT    ALTER SYSTEM SET AUDIT_TRAIL= DB,OS SCOPE=SPFILE SID='*';
PROMPT    AUDIT SESSION WHENEVER NOT SUCCESSFUL;

select username,
os_username,
userhost,
client_id,
trunc(timestamp),
count(*) failed_logins
from dba_audit_trail
where returncode=1017 and --1017 is invalid username/password
timestamp > sysdate -7
group by username,os_username,userhost, client_id,trunc(timestamp); 

SET VERIFY ON

