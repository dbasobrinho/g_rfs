--toolkit/         top10query.sql   top5event.sql    topquery_io.sql  top_redo.sql     totalwork
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


-- http://www.dba-scripts.com/scripts/diagnostic-and-tuning/oracle-active-session-history-ash/top-10-queries-active_session_history/
