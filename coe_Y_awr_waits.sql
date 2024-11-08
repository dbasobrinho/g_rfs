/* Configurações */
ALTER SESSION SET nls_numeric_characters=',.';
SET SERVEROUTPUT ON SIZE 1000000 PAGES 50000 LINES 10000 VERIFY OFF FEEDBACK OFF TRIMSPOOL ON TERMOUT OFF COLSEP ';'

set echo on
SET TIMING ON
EXEC dbms_application_info.set_module( module_name => 'coe_Y_awr_waits! WORKING -> ', action_name =>  'coe_Y_awr_waits');
ALTER SESSION FORCE PARALLEL DML PARALLEL   10;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 10;
alter session set db_file_multiblock_read_count=128 ;
alter session set commit_logging='BATCH' ;
alter session set commit_wait='NOWAIT' ;
col fn new_value banco;
SELECT 'coe_Y_awr_waits_'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS')||'.csv' as fn from dual;
spool &BANCO;



declare

    btime date := to_date('&2','yyyymmddhh24mi');
    etime date := to_date('&3','yyyymmddhh24mi');

    i integer := 0;
    last_startup date;
    last_id integer;
    last_datahora varchar2(20);

    cursor c_inst is select distinct instance_number from dba_hist_snapshot;

    cursor c_snap (v_inst in integer) is
        select snap_id, startup_time, to_char(end_interval_time,'yyyymmdd-hh24:mi') datahora
          from dba_hist_snapshot
         where end_interval_time between btime and etime
           and instance_number = v_inst
         order by end_interval_time;

    cursor c_data (v_bid in integer, v_eid in integer, v_inst integer) is
        select event , time time_s
                  from (  select e.event_name event, (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000 time
                         from dba_hist_system_event b
                            , dba_hist_system_event e
                        where b.snap_id(+)          = v_bid
                          and e.snap_id             = v_eid
						  and b.instance_number     = v_inst
                          and e.instance_number     = v_inst
                          and b.event_id(+)         = e.event_id
                          and e.total_waits         > nvl(b.total_waits,0)
                          and e.wait_class not in ('Idle')
                        UNION ALL 
                       select 'CPU' event, (e.value-b.value)/1000000 time
                         from dba_hist_sys_time_model b, dba_hist_sys_time_model e
                        where e.snap_id             = v_eid
                          and b.snap_id             = v_bid
						  and b.instance_number     = v_inst
                          and e.instance_number     = v_inst
                          and e.stat_name           = 'DB CPU'
                          and b.stat_name           = 'DB CPU'
                        order by time desc  
                      ) 
         where rownum <= 10
           and time > 0;

begin
   dbms_output.put_line('InstID;SnapID;DataHora;Evento;Tempo(s)');
   for r_inst in c_inst loop
     i := 0;
     for r_snap in c_snap(r_inst.instance_number) loop  
       i := i+1;
       if (i > 1) and (r_snap.startup_time = last_startup) then
         for r_data in c_data (last_id, r_snap.snap_id,r_inst.instance_number) loop
          dbms_output.put_line(r_inst.instance_number||';'||last_id||';'||last_datahora||';'||r_data.event||';'||round(r_data.time_s));
         end loop;   -- for r_data in c_data loop
       end if;
       last_startup := r_snap.startup_time;
       last_id      := r_snap.snap_id;
       last_datahora:= r_snap.datahora;
     end loop;      -- for r_snap in c_snaps loop
   end loop;    -- r_inst
end;
/

spool off
undef p_btime p_etime p_inst_id p_qtdd_events

