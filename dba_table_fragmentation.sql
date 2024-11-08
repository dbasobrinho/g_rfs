-- -----------------------------------------------------------------------------------
-- File Name    : dba_table_fragmentation.sql
-- Author       : 
-- Description  : 
-- Call Syntax  : 
-- Last Modified:  
-- -----------------------------------------------------------------------------------

COLUMN owner                   FORMAT a14      
COLUMN table_name              FORMAT a30 
COLUMN blocks                  FORMAT 99999999  
COLUMN num_rows                FORMAT 9999999999999 
COLUMN avg_row_len             FORMAT 99999999
COLUMN TAMANHO_TOTAL_MB        FORMAT 99999999   HEADING 'TAMANHO|TOTAL_MB'
COLUMN TAMANHO_ATUAL_MB        FORMAT 99999999   HEADING 'TAMANHO|ATUAL_MB'
COLUMN TAMANHO_FRAGMENTADO_MB  FORMAT 99999999   HEADING 'TAMANHO|FRAGMENTADO_MB'
COLUMN tablespace_name         FORMAT a33   
COLUMN PERC                    FORMAT a6         HEADING '% FRAG'
PROMPT 
ACCEPT p_schema     CHAR   PROMPT 'Enter schema or ALL        : '
ACCEPT p_table_name CHAR   PROMPT 'Enter table name or ALL    : '
ACCEPT p_frag       NUMBER PROMPT 'Enter FRAG MB > or (0) ALL : '
--TO_CHAR((Z.TAMANHO_ATUAL_MB *100)/Z.TAMANHO_TOTAL_MB) AS PERC
SELECT Z.* ,TO_CHAR(trunc((Z.TAMANHO_FRAGMENTADO_MB *100)/Z.TAMANHO_TOTAL_MB)) AS PERC
FROM (
select owner,
       table_name,
       blocks,
       num_rows,
       avg_row_len,
       round(((blocks * 8 / 1024)), 2) TAMANHO_TOTAL_MB,
       round((num_rows * avg_row_len / 1024 / 1024), 2) TAMANHO_ATUAL_MB,
       round(((blocks * 8 / 1024) - (num_rows * avg_row_len / 1024 / 1024)), 2) TAMANHO_FRAGMENTADO_MB,
       tablespace_name
  from DBA_tables
 WHERE Owner NOT IN (
       'SYS', 'OUTLN' , 'SYSTEM', 'CTXSYS', 'DBSNMP' ,
       'LOGSTDBY_ADMINISTRATOR', 'ORDSYS' ,
       'ORDPLUGINS', 'OEM_MONITOR' , 'WKSYS', 'WKPROXY',
       'WK_TEST', 'WKUSER' , 'MDSYS', 'LBACSYS', 'DMSYS' ,
       'WMSYS', 'OLAPDBA' , 'OLAPSVR', 'OLAP_USER',
       'OLAPSYS', 'EXFSYS' , 'SYSMAN', 'MDDATA',
       'SI_INFORMTN_SCHEMA', 'XDB' , 'ODM')
   and blocks is not null
   and round(((blocks * 8 / 1024)), 2) !=
       round((num_rows * avg_row_len / 1024 / 1024), 2)
    and table_name      = DECODE(Upper('&p_table_name'),'ALL',table_name,Upper('&p_table_name'))
    and owner           = DECODE(Upper('&p_schema'),'ALL',owner,Upper('&p_schema'))	
 order by TAMANHO_FRAGMENTADO_MB asc,
          TAMANHO_ATUAL_MB       desc,
          TAMANHO_TOTAL_MB       desc ) Z
WHERE Z.TAMANHO_FRAGMENTADO_MB >= DECODE((&p_frag),0,0,(&p_frag))	 		  
/		  
