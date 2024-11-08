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

COLUMN file#               FORMAT A45         HEADING 'FILE'
COLUMN DATAFILE_BLOCKS     FORMAT 9999999     HEADING 'DATAFILE_BLOCKS'
COLUMN BLOCKS_READ         FORMAT 9999999     HEADING 'BLOCKS_READ'
COLUMN READ_FOR_BACKUP     FORMAT 9999999     HEADING '% READ FOR BACKUP'

PROMPT +----------------------------------------------------------------------------------+
PROMPT | Para verificar se o BCT esta funcionando corretamente, deve-se verificar na view |
PROMPT | V$BACKUP_DATAFILE, se existe linhas com o valor da coluna USED_CHANGE_TRACKING   |
PROMPT | igual a ‘YES’. O resultado da consulta a essa view pode determinar a efetividade | 
PROMPT | do uso do tracking file no backup incremental. <zas>                             |    
PROMPT +----------------------------------------------------------------------------------+
PROMPT

SELECT file#
      ,avg(datafile_blocks) datafile_blocks
      ,avg(blocks_read) blocks_read
      ,avg(blocks_read / datafile_blocks) * 100 as Read_for_backup
  FROM v$backup_datafile
 WHERE incremental_level > 0
   AND used_change_tracking = 'YES'
 GROUP BY file#
 ORDER BY file#
/