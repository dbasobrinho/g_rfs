SELECT tot.total
     , apr.aprovada
     , CASE WHEN tot.total <> 0 THEN ROUND((NVL(apr.aprovada, 0) / tot.total) * 100, 2) ELSE 0 END pc_aprovada
     , desf.desfeita
     , CASE WHEN tot.total <> 0 THEN ROUND((NVL(desf.desfeita, 0) / tot.total) * 100, 2) ELSE 0 END pc_desfeita
     , neg.negada
     , CASE WHEN tot.total <> 0 THEN ROUND((NVL(neg.negada, 0) / tot.total) * 100, 2) ELSE 0 END pc_negada
FROM (
    SELECT COUNT(1) AS total
    FROM sysep.AU_OPEN_TRANSACTION
    WHERE NVL(transaction_begin_time, transaction_end_time) BETWEEN SYSDATE - INTERVAL '1' MINUTE AND SYSDATE
          AND mti_code IN ('100', '200', '202', '400', '420')
) tot
LEFT JOIN (
    SELECT COUNT(1) AS aprovada
    FROM sysep.AU_OPEN_TRANSACTION
    WHERE NVL(transaction_begin_time, transaction_end_time) BETWEEN SYSDATE - INTERVAL '1' MINUTE AND SYSDATE
          AND mti_code IN ('100', '200', '202', '400', '420')
          AND transaction_status IN (2, 9)
          AND id_response_code = '00'
) apr ON (1=1)
LEFT JOIN (
    SELECT COUNT(1) AS desfeita
    FROM sysep.AU_OPEN_TRANSACTION
    WHERE 
        NVL(transaction_begin_time, transaction_end_time) BETWEEN SYSDATE - INTERVAL '1' MINUTE AND SYSDATE
        AND mti_code = '420'
) desf ON (1=1)
LEFT JOIN (
    SELECT COUNT(1) AS negada
    FROM sysep.AU_OPEN_TRANSACTION
    WHERE 
        NVL(transaction_begin_time, transaction_end_time) BETWEEN SYSDATE - INTERVAL '1' MINUTE AND SYSDATE
        AND mti_code IN ('100', '200', '202', '400', '420')
        AND id_response_code != '00'
) neg ON (1=1);