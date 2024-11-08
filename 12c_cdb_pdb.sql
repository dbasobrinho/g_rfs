-- |----------------------------------------------------------------------------|
-- conectado no cdb$root, execute o sql abaixo para certificar-se de q ele eh um CDB:
-- conectado no cdb$root, execute o sql abaixo para certificar-se de q ele eh um CDB:
-- |----------------------------------------------------------------------------|
SET LINESIZE 200
COLUMN name FORMAT A20
COLUMN CDB FORMAT A5
COLUMN type FORMAT A5
SELECT 'CDB' as type,name, cdb, con_id from v$database union all
select 'PDB' as type,name, 'NO' AS cdb, con_id from v$containers
ORDER BY 4
/

