--Script    : s_service_count_balance.sql
--Data      : 18/03/2018
--Autor     : Roberto Fernaandes Sobrinho
--Finalidade: exibe balance por servico e instancia

select count(*) qtde, inst_id, service_name from gv$session group by inst_id, service_name
/

