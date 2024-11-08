-- |-------------------------------------------------------------------------------|
-- | Objetivo   : Mapear Objetos x Datafiles                                       |
-- | Criado por : Marcelo Baptista de Siqueira                                     |
-- | Data       : 15/04/2021                                                       |
-- | Arquivo    : object_x_datafile.sql                                            |
-- | Referencia : https://pavandba.com/2010/04/23/in-which-datafile-object-resides |
-- | Exemplo    : @object_x_datafile                                               |
-- |              Enter value for object_name:                                     |
-- +-------------------------------------------------------------------------------+
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Objetos x Datafiles                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |m|b|s|i|q|u|e|i|r|a|   |
PROMPT | Version  : 2.1                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+


SET pages 10000 
SET lines 10000
SET COLSEP '|'
SET VERIFY OFF
col segment_name  format a30
col file_name format a70

select a.segment_name, b.file_name, a.file_id   from dba_extents a,dba_data_files b where a.file_id=b.file_id and a.segment_name=upper('&object_name') group by a.segment_name, b.file_name, a.file_id;