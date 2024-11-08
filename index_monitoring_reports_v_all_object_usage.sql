alter session set nls_date_format='dd/mm/yyyy HH24:MI:SS';
alter session set nls_timestamp_format='dd/mm/yyyy HH24:MI:SS';
PROMPT
PROMPT +-----------------------------------------------------------------------------+
PROMPT | REPORTS INDEX USED [V$ALL_OBJECT_USAGE]                                     |
PROMPT +-----------------------------------------------------------------------------+
PROMPT
ACCEPT 2 char   PROMPT 'REPORT INDEX USED = [YES or NO or ALL]  = '


SET ECHO        OFF
SET FEEDBACK    on
SET HEADING     ON
SET LINES       10000
SET PAGES       10000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS 
CLEAR COMPUTES
SET COLSEP '|'

col table_owner        for a15            heading 'Table Owner'
col TABLE_NAME         for a35            heading 'Table Name'
col index_owner        for a15            heading 'index Owner'
col INDEX_NAME         for a35            heading 'Index Name'
col used               for a4             heading 'Used'
col blocks             for 9999999999     Heading 'Blocks'
col clustering_factor  for 9999999999     heading 'C. Factor'
col Index_Quality      for a13            heading 'Idx Quality'
col avg_data_blocks_per_key  for 9999999999     heading 'Avg Data|Blocks Key'
col avg_leaf_blocks_per_key  for 9999999999     heading 'Avg Data|Leaf Key'
col start_monitoring         for a10           heading 'Start Monitoring'
col tablespace_name          for a15           heading 'Table Space'
col VISIBILITY               for a15           heading 'VISIBILITY'



col size_GB               for 999G999G990D90  Heading 'Index Size (GB)' justify  right


BREAK ON report ON USED SKIP 1
COMPUTE SUM LABEL 'GB TOTAL' OF SIZE_GB ON USED;
COMPUTE sum LABEL "GB GRAND TOTAL: " OF SIZE_GB MB ON report

select z.tablespace_name,
       z.table_owner, 
       z.table_name,
       z.owner index_owner,
       z.index_name,
       z.used,
	   z.VISIBILITY,
	   TO_CHAR(z.start_monitoring,'DD/MM/YYYY') as start_monitoring,
       (sum(z.bytes) / 1024 / 1024 / 1024 ) size_GB
  from (with w_object_usage as (select *
                                  from v$all_object_usage
                                 where monitoring = 'YES'
                                   and owner      <> 'SYS'
								   AND used = DECODE(UPPER('&2'), 'ALL', used, UPPER('&2'))
                              --  and trunc(start_monitoring) = to_date('13/07/2019','dd/mm/yyyy')
                                )
         select i.owner, i.index_name, s.bytes, x.used, x.start_monitoring, i.table_owner, i.table_name, i.tablespace_name, i.VISIBILITY
           from dba_indexes i, dba_segments s, w_object_usage x
          where i.owner = x.owner
            and i.index_name   = x.index_name
            and s.segment_name = i.index_name
            and s.owner        = i.owner
			---and i.tablespace_name = 'TB_FLASH'
            and s.segment_type in ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')) z
          group by z.index_name, z.owner, z.used, TO_CHAR(z.start_monitoring,'DD/MM/YYYY'), z.table_owner,  z.table_name, z.tablespace_name, z.VISIBILITY
          order by z.used,z.VISIBILITY, sum(z.bytes) desc, z.owner
/		