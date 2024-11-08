--Template Oracle ODBC - Single 10g a 11g
 
SELECT a.tablespace_name as TABLESPACE,
       total as ALLOC,
       round(NVL(used, 0)) AS used,
       (total - NVL(used, 0)) free,
     100-(round(100 * ( (total - used)/ total))) as USED_PCT,
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
WHERE a.tablespace_name = b.tablespace_name;



Template Oracle ODBC - RAC Scan 12c a 19c - dbtns1
 
 
1)
 
SELECT a.con_id,
       c.name,
       b.tablespace_name,
       a.con_id||'_'||b.tablespace_name AS CDBPDB_TBS,
       a.bytes_alloc/(1024*1024) AS "MAXSIZE",
       nvl(a.physical_bytes, 0)/(1024*1024) "ALLOC",
       nvl(b.tot_used, 0)/(1024*1024) "USED",
       round(((Nvl(b.tot_used, 0) / a.physical_bytes) * 100),2) AS USED_PCT,
       round(100-(((to_char(a.bytes_alloc)-to_char(nvl(a.physical_bytes, 0)))/to_char(a.bytes_alloc))*100), 2) AS ALLOC_MAX,
       a.status AS STATUS
FROM
  (SELECT df.con_id,
          df.tablespace_name,
          sum(df.bytes) physical_bytes,
          sum(decode(df.autoextensible, 'NO', df.bytes, 'YES', df.maxbytes)) bytes_alloc,
          DECODE(tb.status, 'ONLINE', 1, 'OFFLINE', 2, 'READ ONLY', 3, 0) AS status,
      tb.retention
   FROM cdb_data_files df,
        cdb_tablespaces tb
   WHERE df.tablespace_name=tb.tablespace_name
     AND df.con_id = tb.con_id
     AND tb.contents = 'UNDO'
   GROUP BY df.con_id,
            df.tablespace_name,
            tb.status, tb.retention) a,
  (SELECT b.con_id, b.tablespace_name, SUM(CASE
                  WHEN b.retention = 'NOGUARANTEE' AND c.status = 'ACTIVE' THEN c.bytes
                  WHEN b.retention = 'GUARANTEE' AND c.status <> 'EXPIRED' THEN c.bytes
                  ELSE 0
              END) as tot_used
   FROM cdb_UNDO_EXTENTS c
        JOIN cdb_tablespaces b ON c.tablespace_name = b.tablespace_name and c.con_id = b.con_id
   WHERE b.contents = 'UNDO'
   GROUP BY  b.con_id, b.tablespace_name) b,
  (SELECT name,
          con_id
   FROM v$containers) c
WHERE a.con_id= b.con_id
  AND a.con_id = c.con_id
  AND a.tablespace_name = b.tablespace_name (+);
 
2)
 
 
SELECT a.tablespace_name,
       total,
       round(NVL(used, 0)) AS used,
       (total - NVL(used, 0)) free,
     round(100 * ( (total - used)/ total)) as free_pct
FROM
  (SELECT round(SUM(a.bytes) / 1024 / 1024) AS total,
          b.tablespace_name
   FROM dba_data_files a
        JOIN dba_tablespaces b ON a.tablespace_name = b.tablespace_name
   WHERE b.contents = 'UNDO'
   GROUP BY b.tablespace_name) a,
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
WHERE a.tablespace_name = b.tablespace_name;
