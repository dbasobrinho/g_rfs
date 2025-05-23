set lin 188 PAGES 300 verify off head on timing off feed 5
col IDX_OWNER       for a10
col IDX_NAME        for a30 
col TABLESPACE_NAME for a20
col index_type      for a10
col size_mb         for 9999999
col column_name     for a28
col col_pos         for 9999999
undef tab_owner
undef tab_name
undef 1
undef 2
break on owner on segment_name on uniqueness on partitioned on index_type on status on tablespace_name on size_mb 
select a.OWNER       IDX_OWNER,
       SEGMENT_NAME  IDX_NAME,
	   c.column_name,
	   c.column_position col_pos,
	   sum(BYTES / 1024 / 1024) tot_size_mb,
       b.uniqueness,
       b.partitioned,
       b.index_type,
       b.status,
       TABLESPACE_NAME,
       b.last_analyzed,
       decode(VISIBILITY, 'VISIBLE', 'V', 'INVISIBLE', 'I') v
  from dba_segments a,
       (select owner,
               index_name,
               index_type,
               status,
               last_analyzed,
               uniqueness,
               partitioned,
               VISIBILITY
          from dba_indexes
         where table_name = upper('&&1')
           and table_owner = nvl(upper('&&2'),table_owner)
		   ) b,
       dba_ind_columns c
 where segment_name = b.index_name
   and a.owner = b.owner
   and b.index_name = c.index_name
   and b.owner = c.index_owner
 group by a.OWNER,
          SEGMENT_NAME,
          b.uniqueness,
          b.partitioned,
          b.index_type,
          b.status,
          TABLESPACE_NAME,
          c.column_name,
          c.column_position,
          b.last_analyzed,
          VISIBILITY
 order by b.partitioned, a.segment_name, col_pos asc;

undef tab_owner
undef tab_name
undef 1
undef 2