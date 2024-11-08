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

COLUMN alter_ FORMAT A100

select 'ALTER USER '|| USERNAME || ' identified by values ''' || spare4 || ''';' alter_ 
from dba_users,user$ 
where ACCOUNT_STATUS like '%EXPIRED%' 
and USERNAME=NAME 
and username like '%&username_or_p%';

