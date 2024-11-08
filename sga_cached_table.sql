-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sga_cached_table                                                |
-- | CREATOR  : ROBERTO FERNANDES SOBRINHO                                      |
-- | DATE     : 30/03/2020 [QUARENTENA DO CORONA VIRUS]                         |
-- +----------------------------------------------------------------------------+
-- | REF      : https://mikesmithers.wordpress.com/2016/06/23/oracle-pinning-table-data-in-the-buffer-cache/               
-- |          : https://docs.oracle.com/database/121/REFRN/GUID-A8230335-47C4-4707-A866-678DD8D322A8.htm#REFRN30029
-- +----------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Sga Cache Table Information                                 |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+
PROMPT...
ACCEPT v_ORDERRBYS     char   PROMPT 'ORDER BY 4 =[Cached Blocks] / 5 =[Total Blocks] / 6 =[% Cached] >> [DEFAULT=4] >> = ' DEFAULT 4 
PROMPT...
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET LONG        9000
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN owner               FORMAT a13                   HEADING "Owner"
COLUMN object_name         FORMAT a35                   HEADING "Object Name"
COLUMN object_type         FORMAT a14                   HEADING "Object Type"
COLUMN Cache               FORMAT a10                   HEADING "Cache"
COLUMN cached_blocks       FORMAT 9,999,999,999,999     HEADING "Cached Blocks"
COLUMN total_blocks        FORMAT 9,999,999,999,999     HEADING "Total Blocks"
COLUMN percent             FORMAT a08                   HEADING "% Cached"

select  y.owner, y.object_name, y.object_type, y.cached_blocks, y.total_blocks, ' '||lpad(y.percent,3,'0')|| '%' percent,y.cache
from(
select z.owner, z.object_name, z.object_type, z.cached_blocks, z.total_blocks, round(z.cached_blocks*100/z.total_blocks) percent, z.Cache
from
(
select obj.owner, obj.object_name, obj.object_type,
    count(buf.block#) as cached_blocks,
    tab.blocks as total_blocks,
    tab.buffer_pool as Cache
from v$bh buf
inner join dba_objects obj
    on buf.objd = obj.data_object_id
inner join dba_tables tab
    on tab.owner = obj.owner
    and tab.table_name = obj.object_name
    and obj.object_type = 'TABLE'
where buf.class# = 1
and buf.status != 'free'
and obj.owner <> 'SYS'
and obj.object_type = 'TABLE'
group by obj.owner, obj.object_name, obj.object_type, tab.blocks, tab.buffer_pool) z
order by &v_ORDERRBYS desc) y
/ 
PROMPT.                                                                                                                     ______ _ ___
PROMPT.                                                                                                                    |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                                                         _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                                                        (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT
