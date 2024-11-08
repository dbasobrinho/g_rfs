set lines 200
compute sum of sgasize   on report
compute sum of bytes     on report
compute sum of Perc_Free on report
BREAK ON REPORT
COLUMN pool    HEADING "Pool"
COLUMN name    HEADING "Name"
COLUMN sgasize HEADING "(GB) Allocated" FORMAT 999,999,999,999
COLUMN bytes   HEADING "(GB) Free"      FORMAT 999,999,999,999
COLUMN Perc_Free   HEADING "% Free"     FORMAT 999,999,999,999
SELECT
    f.pool
  , f.name
  , s.sgasize/1024/1024 sgasize
  , f.bytes/1024/1024 bytes
  , ROUND(f.bytes/s.sgasize*100, 2) Perc_Free
FROM
    (SELECT SUM(bytes) sgasize, pool FROM v$sgastat GROUP BY pool) s
  , v$sgastat f
WHERE
    f.name = 'free memory'
  AND f.pool = s.pool
/
