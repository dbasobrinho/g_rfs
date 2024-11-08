-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/session_undo_rac.sql
-- Author       : Tim Hall
-- Description  : Displays undo information on relevant database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_undo_rac
-- Last Modified: 20/12/2005
-- -----------------------------------------------------------------------------------
SET TERMOUT OFF;
COLUMN X1 NEW_VALUE X1 NOPRINT;
COLUMN X2 NEW_VALUE X2 NOPRINT;
SELECT 'ALTER TABLESPACE '''||'<UNDO_NAME>'||''' RETENTION GUARANTEE;' X1 FROM DUAL;
SELECT 'ALTER TABLESPACE '''||'<UNDO_NAME>'||''' RETENTION NOGUARANTEE;' X2 FROM DUAL;


SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | &X1      
PROMPT | &X2                                        
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

COLUMN tablespace_name   FORMAT A25
COLUMN size_allocated_mb FORMAT 99999999999999
COLUMN size_used_mb      FORMAT 99999999999999
COLUMN pct_size_used_mb  FORMAT 99999999999999
COLUMN size_free_mb      FORMAT 99999999999999

 
SELECT a.tablespace_name as tablespace_name,
       total as size_allocated_mb,
       round(NVL(used, 0)) AS size_used_mb,
       (total - NVL(used, 0)) size_free_mb,
     100-(round(100 * ( (total - used)/ total))) as pct_size_used_mb,
     a.status AS "STATUS"
FROM
  (SELECT round(SUM(a.bytes) / 1024 / 1024) AS total,
          b.tablespace_name, Decode(b.status, 'ONLINE', 1,
                                 'OFFLINE', 2,
                                 'READ ONLY', 3,
                                 0)                               AS status
   FROM dba_data_files a
        JOIN dba_tablespaces b ON a.tablespace_name = b.tablespace_name
   WHERE b.contents = 'UNDO'
   GROUP BY b.tablespace_name,b.status) a,
  (SELECT c.tablespace_name,
          SUM(CASE
                  WHEN b.retention = 'NOGUARANTEE' AND c.status = 'ACTIVE' THEN c.bytes
                  WHEN b.retention = 'GUARANTEE' AND c.status <> 'EXPIRED' THEN c.bytes
                  ELSE 0
              END) / 1024 / 1024 AS used
   FROM DBA_UNDO_EXTENTS c
        JOIN dba_tablespaces b ON c.tablespace_name = b.tablespace_name
   WHERE b.contents = 'UNDO'
   GROUP BY c.tablespace_name) b
WHERE a.tablespace_name = b.tablespace_name
order by 1
/


----SELECT size_allocated.tbs_name_x_retention as tbs_name_x_retention
----      ,size_allocated.size_allocated_mb
----      ,size_used.size_used_mb
----      ,ROUND(size_used.size_used_mb / size_allocated.size_allocated_mb * 100,2) pct_size_used_mb
----  FROM (SELECT due.tablespace_name
----              ,SUM(due.bytes) / 1024 / 1024 AS size_used_mb
----          FROM dba_undo_extents due
----         GROUP BY due.tablespace_name) size_used
----      ,(SELECT dt.tablespace_name||' '||dt.retention as tbs_name_x_retention, dt.tablespace_name
----              ,SUM(ddf.bytes) / 1024 / 1024 size_allocated_mb --, ddf.file_name
----          FROM dba_tablespaces dt
----              ,dba_data_files  ddf
----         WHERE dt.tablespace_name = ddf.tablespace_name
----           AND dt.contents = 'UNDO'
----         GROUP BY dt.tablespace_name||' '||dt.retention, dt.tablespace_name ) size_allocated
---- WHERE size_allocated.tablespace_name = size_used.tablespace_name(+)
---- ORDER BY tbs_name_x_retention
---- /