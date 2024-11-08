col service_name        format a15
col machine             format a25
col username            format a25

select count(*) qtde, inst_id, service_name, machine, username from gv$session 
where service_name not in ('SYS$BACKGROUND', 'SYS$USERS')
group by inst_id, service_name,machine, username
 order by service_name
/