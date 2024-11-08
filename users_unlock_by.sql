SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      ON

COLUMN unlock_ FORMAT A100

 select 'ALTER USER '|| USERNAME || ' account unlock;' as unlock_ 
from dba_users 
where ACCOUNT_STATUS like '%LOCKED%' 
and username like '%&username_or_p%';
