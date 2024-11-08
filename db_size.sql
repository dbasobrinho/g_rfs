SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Size DB                                                     |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+


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

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN "Database Size"   FORMAT a15
COLUMN "Used space"      FORMAT a15
COLUMN "Free space"      FORMAT a15

col "Database Size" format a20
col "Free space" format a20
col "Used space" format a20
select round(sum(used.bytes) / 1024 / 1024 / 1024) || ' GB' "Database Size"
       ,round(sum(used.bytes) / 1024 / 1024 / 1024) -
       round(free.p / 1024 / 1024 / 1024) || ' GB'  "Used space"
       ,round(free.p / 1024 / 1024 / 1024) || ' GB' "Free space"
  from (select bytes
          from v$datafile
        union all
        select bytes
          from v$tempfile
        union all
        select bytes from v$log) used
      ,(select sum(bytes) as p from dba_free_space) free
 group by free.p
/

PROMPT
SET PAGESIZE 14
SET FEEDBACK ON

