set lines 190
 
select operation as "OPERACAO",
 object_type as "TIPO",
 status,
 output_device_type as "MEDIA",
 to_char(end_time,'DD-MM-RRRR HH24:MI:SS') as "DATA",
 round(MBYTES_PROCESSED/1024,2) as "TAMANHO(MB)"
from
 v$rman_status
where
 operation <> 'CATALOG'
 and trunc(end_time)>=trunc(sysdate-1)
order by end_time
/
