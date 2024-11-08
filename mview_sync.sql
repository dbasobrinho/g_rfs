-- 8 Minutos de Tolerancia
alter session set nls_date_format = 'dd/mm/yyyy hh24:mi';
select
owner, 'Mviews com refresh OK (até 5min)' "Agrupado por Owner", count(*) Contagem, to_char(min(last_refresh_date),'YYYY-MM-DD HH24:MI:SS') "Refresh mais atrasado"
from dba_mviews
where owner not in ('SYS','SYSMAN','SYSTEM','DBSNMP')
and last_refresh_date > (sysdate - (2/400))
group by owner, 'Mviews com refresh time de até 30min'
union all
select
owner, mview_name "Mview mais de 5 min atraso", 1 Contagem, to_char(last_refresh_date,'YYYY-MM-DD HH24:MI:SS')
from dba_mviews
where owner not in ('SYS','SYSMAN','SYSTEM','DBSNMP')
and last_refresh_date <= (sysdate - (2/400))
order by 4 desc;

