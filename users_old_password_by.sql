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

COLUMN old_password FORMAT A100

select 'alter user "' || username || '" identified by values ''' || extract(xmltype(dbms_metadata.get_xml('USER', username)),'//USER_T/PASSWORD/text()').getStringVal() || ''';' old_password
  from dba_users
 where username  like '%&username_or_p%';
 
