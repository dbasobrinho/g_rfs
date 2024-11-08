-- -----------------------------------------------------------------------------------
set pages 1000
set lines 1000

SELECT d.undo_size / ( 1024 * 1024 ) "ACTUAL UNDO SIZE [MByte]", 
       Substr(e.value, 1, 25)        "UNDO RETENTION [Sec]", 
       ( To_number(e.value) * To_number(f.value) * g.undo_block_per_sec ) / ( 
       1024 * 
       1024 )                        "NEEDED UNDO SIZE [MByte]" 
FROM   (SELECT SUM(a.bytes) undo_size 
        FROM   v$datafile a 
               inner join v$tablespace b 
                       ON a.ts# = b.ts# 
               inner join dba_tablespaces c 
                       ON b.name = c.tablespace_name 
        WHERE  c.CONTENTS = 'UNDO' 
               AND c.status = 'ONLINE') d, 
       v$parameter e, 
       v$parameter f, 
       (SELECT Max(undoblks / ( ( end_time - begin_time ) * 3600 * 24 )) 
               undo_block_per_sec 
        FROM   v$undostat) g 
WHERE  e.name = 'undo_retention' 
       AND f.name = 'db_block_size'
/	   