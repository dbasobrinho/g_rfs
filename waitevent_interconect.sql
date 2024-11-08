-- Identifica Objetos que estão impactando na performance do Interconect
select inst_id, event, p1 file_number, p2 block_number, wait_time
  from gv$session_wait
 where event in ('buffer busy global cr','global cache busy','buffer busy global cache');
 
 
select owner, segment_name, segment_type
  from dba_extents
 where file_id = &file_id
   and &block_identifiedy between block_id and block_id+blocks-1;
   
   
-- para melhorar performance as queries devem ser alteradas para obter melhores planos e
-- em alguns casos os objetos devem ser revistos quanto a particionamento, parallel degree,
-- reduzindo o numero de registros por bloco, initrans e freelists devem ser revistos também, etc.
