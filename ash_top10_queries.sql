--ash_top10_queries.sql
set pages 1000
set lines 1000
col username  format a25 
select * from (
    select
         SQL_ID ,
         sum(decode(session_state,'ON CPU',1,0)) as CPU,
         sum(decode(session_state,'WAITING',1,0)) - sum(decode(session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0)) as WAIT,
         sum(decode(session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0)) as IO,
         sum(decode(session_state,'ON CPU',1,1)) as TOTAL
    from v$active_session_history
    where SQL_ID is not NULL
    group by sql_id
    order by sum(decode(session_state,'ON CPU',1,1))   desc
    )
where rownum <11
/
SELECT * FROM TABLE(dbms_xplan.display_cursor('&SQL_ID'))
/