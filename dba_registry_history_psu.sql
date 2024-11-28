


SET LINESIZE 200

COLUMN db_name    FORMAT A10
COLUMN action_tim FORMAT A20
COLUMN action FORMAT A15
COLUMN namespace FORMAT A15
COLUMN version FORMAT  A24
COLUMN versionx FORMAT A15
COLUMN comments FORMAT A27
COLUMN bundle_series FORMAT A10
COLUMN INSTANCE  FORMAT A10

SELECT (select  UPPER(A.INSTANCE_NAME) INSTANCE_NAME from V$INSTANCE a) INSTANCE,
       TO_CHAR(action_time, 'DD-MON-YYYY HH24:MI:SS') AS action_tim,
       action,
       namespace,
       version,
       id,
       comments,
       bundle_series
FROM   sys.registry$history
where UPPER(version) like '%19.24%'
ORDER by action_time
/
