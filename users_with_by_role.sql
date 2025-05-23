-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/users_with_role.sql
-- Author       : Tim Hall
-- Description  : Displays a list of users granted the specified role.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_with_by_role DBA
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------

SET VERIFY OFF

SELECT username,
       lock_date,
       expiry_date
FROM   dba_users
WHERE  username IN (SELECT grantee
                    FROM   dba_role_privs
                    WHERE  granted_role = UPPER('&granted_role'))
ORDER BY username;

SET VERIFY ON
