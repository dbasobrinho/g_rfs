--
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

COLUMN comm FORMAT A150
select 'create user <USERNAME> identified by <PSSW> default tablespace <TBS_NAME> QUOTA <SIZE> ON <TBS_NAME> PROFILE <PROFILE_NAME>;' comm from dual
union all select 'grant connect, create session to <USERNAME>;' comm from dual
union all select 'alter <USERNAME> password expire;' comm from dual
/

SET VERIFY ON
