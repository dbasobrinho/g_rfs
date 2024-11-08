--    Data       |   Versao  |   Analista  |   Alteracoes
---------------------------------------------------------------------------------------------------------------------
--   15/dez/2004 |    1.0    |   LFCerri   | Criacao do script que retorna informacoes das sessoes fazendo rollback

column   sid format   99999
column   segment_name format   a30
column   username format   a20
column   rolling   format   a10

select b.segment_name, a.username, a.sid, a.serial#, decode(bitand(c.flag,128),0,'NO','YES') rolling, c.used_ublk,
c.used_urec,c.START_UBAFIL, c.START_UBABLK, c.START_UBAREC
 from v$session a, dba_rollback_segs b, v$transaction c
where b.segment_id = c.xidusn
  and a.taddr = c.addr
/

