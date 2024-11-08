set pages 1000
set lines 1000
set timing off
SET UNDERLINE =
SET FEEDBACK  2
COLUMN name       FORMAT A40
COLUMN SIZE_GB    FORMAT 9999999999
COLUMN USED_GB    FORMAT 9999999999
COLUMN PCT_USED   FORMAT 9999999999
COLUMN VALUE      FORMAT A40



SELECT name, ceil( space_limit / 1024 / 1024 / 1024) SIZE_GB,
           ceil( space_used  / 1024 / 1024 / 1024) USED_GB,
           decode( nvl( space_used, 2),0,0,
           ceil ( ( space_used / space_limit) * 100) ) PCT_USED
FROM v$recovery_file_dest
ORDER BY name
/
ARCHIVE LOG LIST
select NAME,VALUE,ISDEFAULT,ISSES_MODIFIABLE,ISSYS_MODIFIABLE,ISINSTANCE_MODIFIABLE from v$parameter where UPPER(name) = UPPER('db_recovery_file_dest')
UNION ALL
select NAME,TO_CHAR(VALUE/1024/1024/1024) VALUE_GB,ISDEFAULT,ISSES_MODIFIABLE,ISSYS_MODIFIABLE,ISINSTANCE_MODIFIABLE from v$parameter where UPPER(name) = UPPER('db_recovery_file_dest_size')
/
