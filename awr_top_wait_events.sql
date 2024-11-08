SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Top Eventos eventos de Espera AWR                           |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN snap_id                 FORMAT a10           HEAD 'Snap Id'
COLUMN begin_interval_time     FORMAT a20           HEAD 'Begin Time'
COLUMN end_interval_time       FORMAT a20           HEAD 'End Time'

prompt .
prompt Digitar a quantidade de dias para consultar "snap_id"
prompt Capturar o "snap_id" desejado
prompt .
select trim(a.snap_id)  snap_id
      ,to_char(a.begin_interval_time, 'dd/mm/yyyy hh24:mi:ss') begin_interval_time
      ,to_char(a.end_interval_time, 'dd/mm/yyyy hh24:mi:ss') end_interval_time
  from dba_hist_snapshot a
  where begin_interval_time > trunc(sysdate)-&day
order by 1 desc;
         
prompt .       
         	 
set lines 200
col event_name                 for a40
col wait_class                 for a20
col waits                      for 999,999,999
col "TIME(s)"                  for 999,999,999
col "AVG_WAIT(ms)"             for 999,999,999
COLUMN snap_id                 FORMAT a9          
COLUMN begin_time              FORMAT a17          
COLUMN end_time                FORMAT a17  
COLUMN snap_id                 FORMAT a7           HEAD 'SNAP_ID'        
COLUMN INSTANCE                FORMAT a10 
COLUMN wait_class              FORMAT a15 
COLUMN pct                     FORMAT a5           HEAD '%PCT' 

select trim(snap_id) snap_id,
       begin_time,
       end_time,
       (select i.instance_name
          from gv$instance i
         where i.INSTANCE_NUMBER = a.instance_number) as "INSTANCE",
       event_name,
       total_waits as "WAITS",
       event_time_waited as "TIME(s)",
       avg_wait as "AVG_WAIT(ms)",
       to_char(pct) as pct,
       wait_class
  from (select to_char(s.begin_interval_time, 'DD-MM-YYYY HH24:MI') as BEGIN_TIME,
               to_char(s.end_interval_time, 'DD-MM-YYYY HH24:MI') as END_TIME,
               m.*
          from (select ee.instance_number,
                       ee.snap_id,
                       ee.event_name,
                       round(ee.event_time_waited / 1000000) event_time_waited,
                       ee.total_waits,
                       round((ee.event_time_waited * 100) /
                             et.total_time_waited,
                             1) pct,
                       round((ee.event_time_waited / ee.total_waits) / 1000) avg_wait,
                       ee.wait_class
                  from (select ee1.instance_number,
                               ee1.snap_id,
                               ee1.event_name,
                               ee1.time_waited_micro - ee2.time_waited_micro event_time_waited,
                               ee1.total_waits - ee2.total_waits total_waits,
                               ee1.wait_class
                          from dba_hist_system_event ee1
                          join dba_hist_system_event ee2 on ee1.snap_id =
                                                            ee2.snap_id + 1
                                                        and ee1.instance_number =
                                                            ee2.instance_number
                                                        and ee1.event_id =
                                                            ee2.event_id
                                                        and ee1.wait_class_id <>
                                                            2723168908
                                                        and ee1.time_waited_micro -
                                                            ee2.time_waited_micro > 0
                        union
                        select st1.instance_number,
                               st1.snap_id,
                               st1.stat_name event_name,
                               st1.value - st2.value event_time_waited,
                               null total_waits,
                               null wait_class
                          from dba_hist_sys_time_model st1
                          join dba_hist_sys_time_model st2 on st1.instance_number =
                                                              st2.instance_number
                                                          and st1.snap_id =
                                                              st2.snap_id + 1
                                                          and st1.stat_id =
                                                              st2.stat_id
                                                          and st1.stat_name =
                                                              'DB CPU'
                                                          and st1.value -
                                                              st2.value > 0) ee
                  join (select et1.instance_number,
                              et1.snap_id,
                              et1.value - et2.value total_time_waited,
                              null wait_class
                         from dba_hist_sys_time_model et1
                         join dba_hist_sys_time_model et2 on et1.snap_id =
                                                             et2.snap_id + 1
                                                         and et1.instance_number =
                                                             et2.instance_number
                                                         and et1.stat_id =
                                                             et2.stat_id
                                                         and et1.stat_name =
                                                             'DB time'
                                                         and et1.value -
                                                             et2.value > 0) et on ee.instance_number =
                                                                                  et.instance_number
                                                                              and ee.snap_id =
                                                                                  et.snap_id) m
          join dba_hist_snapshot s on m.snap_id = s.snap_id
         where m.instance_number = 1
           and m.snap_id = &snap_id
         order by PCT desc) a
 where rownum <= &top;

COLUMN WAIT_CLASS                 FORMAT a15          HEAD 'WAIT_CLASS'   
COLUMN explain                    FORMAT a130            

select z.* from(
select 'Administrative' WAIT_CLASS, 'Espera resultante de comandos administrativos (DBA). Por exemplo, um rebuild de indice.' explain from dual union all
select 'Application' WAIT_CLASS, 'Espera resultante do codigo da aplicacao do usuario. Por exemplo, lock a nivel de linha ou comando explicito de lock.' explain from dual union all
select 'Cluster' WAIT_CLASS, 'Espera relacionada aos recursos do Real Application Clusters (RAC). Por exemplo, "gc cr block busy".' explain from dual union all
select 'Commit' WAIT_CLASS, 'Esta classe cotem apenas um evento de espera. "log file sync", espera para o redolog confirmar um commit.' explain from dual union all
select 'Concurrency' WAIT_CLASS, 'Espera por recursos internos do banco de dados. Por exemplo, latches.' explain from dual union all
select 'Configuration' WAIT_CLASS, 'Espera causada por uma configuracao inadequada. Exemplo, mal dimensionamento do tamanho dos log file, shared pool size.' explain from dual union all
select 'Idle' WAIT_CLASS, 'Indica que a sessao esta inativa, esperando para trabalhar. Por exemplo, "SQL*Net message from client".' explain from dual union all
select 'Network' WAIT_CLASS, 'Espera relacionada a eventos de rede. Por exemplo, "SQL*Net more data to dblink".' explain from dual union all
select 'Other' WAIT_CLASS, 'Esperas que normalmente nao devem ocorrem em um sistema. Por exemplo, "wait for EMON to spawn")' explain from dual union all
select 'Scheduler' WAIT_CLASS, 'Espera relacionada ao gerenciamento de recursos. Por exemplo, "resmgr: become active".' explain from dual union all
select 'System I/O' WAIT_CLASS, 'Espera por background process I/O. Por exemplo, DBWR wait for "db file parallel write")' explain from dual union all
select 'User I/O' WAIT_CLASS, 'Espera por user I/O. Por exemplo "db file sequential read".' explain from dual ) z order by 1;