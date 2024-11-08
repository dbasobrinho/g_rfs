-- -----------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 200

COLUMN table_owner FORMAT A20
COLUMN index_owner FORMAT A20
COLUMN index_type FORMAT A12
COLUMN tablespace_name FORMAT A20

SELECT table_owner,
       table_name,
       owner AS index_owner,
       index_name,
       tablespace_name,
       num_rows,
       status,
       index_type,
	   VISIBILITY
FROM   dba_indexes
--where index_name = 'XIF1TX_AUTHORIZATION_INFO_02'
ORDER BY table_owner, table_name, index_owner, index_name
/


