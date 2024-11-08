-- |----------------------------------------------------------------------------|
-- | Objetivo   : VIZULIZAR SIZE TABELA E SEUS INDEXES                          |
-- | Criado por : Roberto Fernandes Sobrinho                                    |
-- | Data       : 07/10/2020                                                    |
-- | Exemplo    : @table_size_group_type_by SYS IDL_UB1$                        |
-- | Arquivo    : table_size_group_type_by.sql                                  |
-- | Modificacao:                                                               |
-- +----------------------------------------------------------------------------+

set pagesize 1000
set linesize 500
set feedback off
COLUMN owner       FORMAT A12
COLUMN NAME        FORMAT A32
COLUMN OBJECT_NAME FORMAT A32
COLUMN type       FORMAT A32
COLUMN SIZE_MB    FORMAT  9999999.99
COLUMN SIZE_GB    FORMAT  9999999999
COLUMN Percent    FORMAT  999
set verify off

set pagesize 1000
set linesize 500
set feedback ON
COLUMN tablespace_name FORMAT  A30
COLUMN segment_name FORMAT A49
COLUMN Percent FORMAT     999
COLUMN tab_size_gb     FORMAT     99999999

SELECT 
    tablespace_name,segment_name,SEGMENT_TYPE,TRUNC(tab_size_gb)  tab_size_gb
FROM    
(
    SELECT
    tablespace_name,segment_name,SEGMENT_TYPE,bytes/1024/1024/1024 tab_size_gb,
    RANK() OVER (PARTITION BY tablespace_name ORDER BY bytes DESC) AS rnk
    FROM dba_segments
    WHERE tablespace_name = '&1' --segment_type='TABLE'
)
WHERE tab_size_gb > 0
order by rnk
/
UNDEF 1
UNDEF 2
SET TERMOUT OFF;
$ORACLE_HOME/sqlplus/admin/glogin.sql
SET TERMOUT ON;