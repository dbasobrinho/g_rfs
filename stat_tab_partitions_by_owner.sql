
COLUMN table_name FORMAT a25 HEADING 'Table'
COLUMN partition_name FORMAT a25 HEADING 'Partition'
COLUMN num_rows HEADING 'Num|Rows'
COLUMN blocks HEADING 'Blocks'
COLUMN avg_space HEADING 'Avg|Space'
COLUMN chain_cnt HEADING 'Chain|Count'
COLUMN avg_row_len HEADING 'Avg|Row|Length'
COLUMN last_analyzed HEADING 'Analyzed'

ACCEPT owner1 PROMPT 'OWNER:'
SET LINES 130
ttitle 'Table Partition Statistics For &owner1'
BREAK ON table_owner ON table_name ON partition_name


SELECT 
table_name, 
partition_name,
num_rows,
blocks,
avg_space,
chain_cnt,
avg_row_len,
to_char(last_analyzed,'dd-mon-yyyy hh24:mi') last_analyzed
FROM 
sys.dba_tab_partitions
WHERE TABLE_OWNER = UPPER('&owner1')
ORDER BY 
table_owner,table_name
/
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF owner1