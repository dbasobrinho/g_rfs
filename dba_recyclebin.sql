SET LINESIZE 500 VERIFY OFF

column owner             format  a6
column original_name     format  a25
column operation         format  a6
column type              format  a15
column space_blks        format  999999
column space_mb          format  999999999999999
column CREATETIME        format a20
column DROPTIME          format a20

SELECT owner,
       original_name,
       --object_name,
       operation,
       type,
       space AS space_blks,
       ROUND((space*8)/1024,2) space_mb,
	   CREATETIME,
	   DROPTIME
FROM   dba_recyclebin
WHERE  owner = DECODE(UPPER('ALL'), 'ALL', owner, UPPER('ALL'))
ORDER BY space_mb DESC, 1, 2;

SET VERIFY ON