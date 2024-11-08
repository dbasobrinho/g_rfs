prompt =========================================================
prompt             ULTIMA ATUALIZACAO DAS MVIEW
prompt =========================================================
set pages 1000
set lines 1000
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
SELECT * FROM DBA_MVIEW_REFRESH_TIMES;

prompt =========================================================
prompt                          MVIEW COM 8 MINUTOS DE TOLERANCIA
prompt =========================================================
select owner,
       'Mviews com refresh OK (até 5min)' "Agrupado por Owner",
       count(*) Contagem,
       to_char(min(last_refresh_date), 'YYYY-MM-DD HH24:MI:SS') "Refresh mais atrasado"
  from dba_mviews
 where owner not in ('SYS', 'SYSMAN', 'SYSTEM', 'DBSNMP')
   and last_refresh_date > (sysdate - (2 / 400))
 group by owner, 'Mviews com refresh time de até 30min'
union all
select owner,
       mview_name "Mview mais de 5 min atraso",
       1 Contagem,
       to_char(last_refresh_date, 'YYYY-MM-DD HH24:MI:SS')
  from dba_mviews
 where owner not in ('SYS', 'SYSMAN', 'SYSTEM', 'DBSNMP')
   and last_refresh_date <= (sysdate - (2 / 400))
 order by 4 desc;

prompt =========================================================
prompt    MVIEW COM DML PENDENTE (PODE LEVAR ALGUNS SEGUNDOS)
prompt =========================================================

prompt                          MVIEW: AU_OPEN_TRANSACTION
select distinct DMLTYPE$$, count(*) from SYSAU.MLOG$_AU_OPEN_TRANSACTION@AUTORIZADOR group by DMLTYPE$$;

prompt                          MVIEW: AU_OPEN_TRANSACTION_RC
select distinct DMLTYPE$$, count(*) from SYSAU.MLOG$_AU_OPEN_TRANSACTION@AUTORIZADOR group by DMLTYPE$$;

prompt                          MVIEW: AU_PAYMENT_MEDIA
select distinct DMLTYPE$$, count(*) from SYSAU.MLOG$_AU_PAYMENT_MEDIA@AUTORIZADOR group by DMLTYPE$$;

prompt                          MVIEW: AU_CUSTOMER_ACCOUNT
select distinct DMLTYPE$$, count(*) from SYSAU.MLOG$_AU_CUSTOMER_ACCOUNT@AUTORIZADOR group by DMLTYPE$$;

prompt                          MVIEW: AU_RESPONSE_CODE
select distinct DMLTYPE$$, count(*) from SYSAU.MLOG$_AU_RESPONSE_CODE@AUTORIZADOR group by DMLTYPE$$;
