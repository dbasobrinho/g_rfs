set lines 180
col  Event format a30
col "Inst Num" format 9
col "Snap Id" format 999999


SELECT CASE wait_rank
         WHEN 1 THEN inst_id
       END                                         "Inst Num",
       CASE wait_rank
         WHEN 1 THEN snap_id
       END                                         "Snap Id",
       CASE wait_rank
         WHEN 1 THEN begin_snap
       END                                         "Begin Snap",
       CASE wait_rank
         WHEN 1 THEN end_snap
       END                                         "End Snap",
       event_name                                  "Event",
       total_waits                                 "Waits",
       time_waited                                 "Time(s)",
       Round(( time_waited / total_waits ) * 1000) "Avg wait(ms)",
       Round(( time_waited / db_time ) * 100, 2)   "% DB time",
       Substr(wait_class, 1, 15)                   "Wait Class"
FROM   (SELECT inst_id,
               snap_id,
               To_char(begin_snap, 'DD-MM-YY hh24:mi:ss') begin_snap,
               To_char(end_snap, 'hh24:mi:ss')            end_snap,
               event_name,
               wait_class,
               total_waits,
               time_waited,
               Dense_rank()
                 over (
                   PARTITION BY inst_id, snap_id
                   ORDER BY time_waited DESC) - 1         wait_rank,
               Max(time_waited)
                 over (
                   PARTITION BY inst_id, snap_id)         db_time
        FROM   (SELECT s.instance_number                     inst_id,
                       s.snap_id,
                       s.begin_interval_time                 begin_snap,
                       s.end_interval_time                   end_snap,
                       event_name,
                       wait_class,
                       total_waits - Lag(total_waits, 1, total_waits)
                                       over (
                                         PARTITION BY s.startup_time,
                                       s.instance_number,
                                       stats.event_name
                                         ORDER BY s.snap_id) total_waits,
                       time_waited - Lag(time_waited, 1, time_waited)
                                       over (
                                         PARTITION BY s.startup_time,
                                       s.instance_number,
                                       stats.event_name
                                         ORDER BY s.snap_id) time_waited,
                       Min(s.snap_id)
                         over (
                           PARTITION BY s.startup_time, s.instance_number,
                         stats.event_name)
                                                             min_snap_id
                FROM   (SELECT dbid,
                               instance_number,
                               snap_id,
                               event_name,
                               wait_class,
                               total_waits_fg
                               total_waits,
                               Round(time_waited_micro_fg / 1000000, 2)
                               time_waited
                        FROM   dba_hist_system_event
                        WHERE  wait_class NOT IN ( 'Idle', 'System I/O' )
                        UNION ALL
                        SELECT dbid,
                               instance_number,
                               snap_id,
                               stat_name                 event_name,
                               NULL                      wait_class,
                               NULL                      total_waits,
                               Round(value / 1000000, 2) time_waited
                        FROM   dba_hist_sys_time_model
                        WHERE  stat_name IN ( 'DB CPU', 'DB time' )) stats,
                       dba_hist_snapshot s
                WHERE  stats.instance_number = s.instance_number
                       AND stats.snap_id = s.snap_id
                       AND stats.dbid = s.dbid
                       --  and s.dbid=3870213301
                       AND s.instance_number = 2
               --  and stats.snap_id between 190 and 195
               )
        WHERE  snap_id > min_snap_id
               AND Nvl(total_waits, 1) > 0)
WHERE  event_name != 'DB time'
       AND wait_rank <= 5
ORDER  BY inst_id,
          snap_id;