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

COLUMN alter_password FORMAT A100

select 'alter user ' || username || ' identified by "&new_password" account unlock password expire; ' alter_password
  from dba_users
 where username  like upper('%&username_or_p%')
 
