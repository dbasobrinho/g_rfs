 SELECT username 
  FROM dba_users 
 WHERE TRUNC(created) > (SELECT MIN(TRUNC(created)) FROM dba_users)
 /
 select username from dba_users where oracle_maintained = 'N')
 /
 
