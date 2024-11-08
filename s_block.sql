-- verifica_blockers.sql
col SPID for 999999
col user_bloqueado for a30
col USER_BLOQUEADOR  for a12
col sessao_bloqueadora for a55
col user_bloqueador for a15
col osuser_bloqueador for a8
col origem_bloqueador for a65

select s.SECONDS_IN_WAIT tempo,
        s.username ||   ' ''' || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''''  user_bloqueado,
                s.sql_id sql_bloqueado,
                nvl (n.username, '******') user_bloqueador,
                'alter system kill session ''' || n.sid || ',' || n.serial# || ',@' ||n.inst_id || ''' immediate;' sessao_bloqueadora,
                n.sql_id                                atual_sql_blocker,
                n.prev_sql_id                   previous_sql_blocker,
                n.osuser ||'@'|| n.machine || ':' || n.port origem_bloqueador
from
        gv$session s,   -- dados do bloqueado
                gv$session n   -- dados do bloqueador.
where  s.blocking_session is not null   -- coluna indica que a sessão em S está sendo bloqueada
      and s.blocking_session=n.sid              -- a sessão bloqueadora em S é o SID do bloqueador
          and s.BLOCKING_INSTANCE=n.inst_id  -- a instância bloqueadora em S é a inst_id do bloqueador.
order by s.SECONDS_IN_WAIT desc
/


-- query simples
--      select waiter.username ,  waiter.sid, waiter.serial#, waiter.inst_id, waiter.blocking_session, waiter.BLOCKING_INSTANCE from gv$session waiter where waiter.blocking_session is not null;
