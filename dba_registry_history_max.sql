-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/registry_history.sql
-- Author       : Tim Hall
-- Description  : Displays contents of the registry history
-- Requirements : Access to the DBA role.
-- Call Syntax  : @registry_history
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN db_name    FORMAT A10
COLUMN action_time FORMAT A20
COLUMN action FORMAT A15
COLUMN namespace FORMAT A15
COLUMN version FORMAT  A24
COLUMN versionx FORMAT A15
COLUMN comments FORMAT A27
COLUMN bundle_series FORMAT A10

SELECT (select global_name from global_name) as db_name,
       TO_CHAR(action_time, 'DD-MON-YYYY HH24:MI:SS') AS action_time,
       action,
       namespace,
       version,
	   substr(version,1,15)  versionx,
       id,
       comments,
       bundle_series
FROM   sys.registry$history
where action = 'APPLY'
and version is not null
and trunc(action_time) = (select trunc(max(action_time)) FROM   sys.registry$history where action = 'APPLY' and version is not null)
ORDER by action_time;