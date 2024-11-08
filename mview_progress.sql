column "MATERIALIZED VIEW" format a40  JUSTIFY center
column "REFRESH TYPE" format a20 JUSTIFY center
column "STATUS" format a27 JUSTIFY center
column inserts format 9999999 JUSTIFY center
column updates format 9999999 JUSTIFY center
column deletes format 9999999 JUSTIFY center

SELECT currmvowner_knstmvr
       || '.'
       || currmvname_knstmvr    "MATERIALIZED VIEW",
       Decode(reftype_knstmvr, 1, 'FAST - RAPIDO',
                               2, 'COMPLETE - COMPLETO',
                                  'UNKNOWN')     as "REFRESH TYPE",
       Decode(groupstate_knstmvr, 1, 'SETUP - Iniciando Processo',
                                  2, 'INSTANTIATE - Carregando',
                                  3, 'WRAPUP - Finalizando',
                                  'UNKNOWN') STATUS,
       total_inserts_knstmvr                 INSERTS,
       total_updates_knstmvr                 UPDATES,
       total_deletes_knstmvr                 DELETES
FROM   x$knstmvr X
WHERE  type_knst = 6
       AND EXISTS (SELECT 1
                   FROM   v$session s
                   WHERE  s.sid = x.sid_knst
                          AND s.serial# = x.serial_knst);
