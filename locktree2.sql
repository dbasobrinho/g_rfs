column sid format a8
column object_name format a20
column sql_text format a50
set echo on 

WITH sessions AS
   (SELECT /*+materialize*/
           sid, blocking_session, row_wait_obj#, sql_id
      FROM v$session)
SELECT LPAD(' ', LEVEL ) || sid sid, object_name, 
       substr(sql_text,1,40) sql_text
  FROM sessions s 
  LEFT OUTER JOIN dba_objects 
       ON (object_id = row_wait_obj#)
  LEFT OUTER JOIN v$sql
       USING (sql_id)
 WHERE sid IN (SELECT blocking_session FROM sessions)
    OR blocking_session IS NOT NULL
 CONNECT BY PRIOR sid = blocking_session
 START WITH blocking_session IS NULL; 
