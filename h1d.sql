/*
--- Header: $Id: h1d.sql 28 2015-12-01 23:28:43Z mve $
--- Copyright 2015 HASHJOIN (http://www.hashjoin.com/). All Rights Reserved.

- compares results of TWO AWR reports based on ID produced by running h1.sql

1: start ID (from h1 result)
2: end ID   (from h1 result)

@h1d 81 101
http://www.dbatoolz.com/t/oracle_ash_monitoring.html
*/

ttit "Stat Diff Between: &&1 and &&2"
set lines 157

col event format a30


select
   t.program
,  t.module
,  t.event
,  t.wait_Class
,  t.ASH_SECS t_ash_sec
,  l.ASH_SECS l_ash_sec
,  t.ASH_SECS - nvl(l.ASH_SECS,0) diff_ash_secs
,  t.run_id
,  l.run_id
from h1_out t
,    h1_out l
where t.run_id = &&1
  and l.run_id(+) = &&2
  and t.event is not null
--  and l.event is not null
  and t.event = l.event(+)
  and t.program = l.program(+)
  and t.module = l.module(+)
--  and t.ASH_SECS - nvl(l.ASH_SECS,0) > 0
order by diff_ash_secs desc;

