--Script: RAC_TEMPO_FLUSH_REDO_LOG 
--Data:   12/04/2014
--Autor: Marcio Guimaraes
--Observações: 
--Finalidade: Lista informaçoes do tempo de flush para Redo Log 

set echo on 
WITH sysstat AS (
    SELECT SUM(CASE WHEN name LIKE '%time' 
                    THEN VALUE END) total_time,
           SUM(CASE WHEN name LIKE '%flush time' 
                    THEN VALUE END) flush_time,
           SUM(CASE WHEN name LIKE '%served' 
                    THEN VALUE END) blocks_served 
    FROM gv$sysstat
    WHERE name IN
                  ('gc cr block build time',
                   'gc cr block flush time',
                   'gc cr block send time',
                   'gc current block pin time',
                   'gc current block flush time',
                   'gc current block send time',
                   'gc cr blocks served',
                   'gc current blocks served')),
     cr_block_server as (
    SELECT SUM(flushes) flushes, SUM(data_requests) data_requests
    FROM gv$cr_block_server     )
SELECT ROUND(flushes*100/blocks_served,2) pct_blocks_flushed,
       ROUND(flush_time*100/total_time,2) pct_lms_flush_time
  FROM sysstat CROSS JOIN cr_block_server; 