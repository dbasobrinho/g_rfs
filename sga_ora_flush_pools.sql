-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sga_ora_flush_pools.sql                                         |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Oracle Flush Pools Memory                                   |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT +------------------------------------------------------------------------+
PROMPT | alter system flush buffer_cache;                                       |
PROMPT | alter system flush shared_pool;                                        |
PROMPT | alter system checkpoint;                                               |
PROMPT | alter system switch logfile;                                           |
PROMPT +------------------------------------------------------------------------+
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

COLUMN owner        FORMAT a19  HEAD 'owner'
COLUMN object_type  FORMAT a20      
COLUMN objname      FORMAT a20      
COLUMN objd         FORMAT 999999     
COLUMN status       FORMAT a15      
COLUMN cnt          FORMAT 999999  HEAD 'count'      

SELECT o.owner,
       o.object_type,
       substr(o.object_name,1,18) objname,
       b.objd,
       b.status,
       count(b.objd) cnt
  FROM v$bh b, dba_objects o
 WHERE b.objd = o.data_object_id
   AND o.owner not in ('SYS','SYSTEM','SYSMAN')
GROUP BY o.owner,
         o.object_type,
         o.object_name,
         b.objd,
         b.status
/

