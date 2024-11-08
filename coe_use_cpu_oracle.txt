--CPU_TOTAL - CPU usada no host
--CPU_OS - CPU usada nos processos host, mas não por processos Oracle, ou seja, CPU_TOTAL - CPU_ORA
--CPU_ORA - CPU usada por processos Oracle
--CPU_ORA_WAIT - CPU desejada por processos Oracle, mas não obtida, ou seja, CPU_from_ASH - CPU_ORA

--https://dbakevlar.com/2013/08/oracle-cpu-time/

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ORACLE CPU TIME                     +-+-+-+-+-+-+-+-+-+-+   |
PROMPT | Instance : &current_instance                   |r|f|s|o|b|r|i|n|h|o|   |
PROMPT | Version  : 1.0                                 +-+-+-+-+-+-+-+-+-+-+   |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       500
SET PAGES       500
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col BEGIN_TIME   format A10 HEADING 'BEGIN TIME' JUSTIFY CENTER
col END_TIME     format A10 HEADING 'END TIME' JUSTIFY CENTER
col CPU_TOTAL    format 9999900.99 HEADING 'CPU TOTAL' JUSTIFY CENTER
col CPU_OS       format 9999900.99 HEADING 'CPU USED SO' JUSTIFY CENTER
col CPU_ORA      format 9999900.99 HEADING 'CPU USED ORA' JUSTIFY CENTER
col CPU_ORA_WAIT format 9999900.99 HEADING 'CPU WAIT ORA' JUSTIFY CENTER
col COMMIT       format 9999900.99 HEADING 'CPU COMMIT' JUSTIFY CENTER
col READIO       format 9999900.99 HEADING 'READIO' JUSTIFY CENTER
col WAIT         format 9999900.99 HEADING 'WAIT' JUSTIFY CENTER
SET COLSEP '|'

with AASSTAT as (
           select
                 decode(n.wait_class,'User I/O','User I/O',
                                     'Commit','Commit',
                                     'Wait')                               CLASS,
                 sum(round(m.time_waited/m.INTSIZE_CSEC,3))                AAS,
                 BEGIN_TIME ,
                 END_TIME
           from  v$waitclassmetric  m,
                 v$system_wait_class n
           where m.wait_class_id=n.wait_class_id
             and n.wait_class != 'Idle'
           group by  decode(n.wait_class,'User I/O','User I/O', 'Commit','Commit', 'Wait'), BEGIN_TIME, END_TIME
          union
             select 'CPU_ORA_CONSUMED'                                     CLASS,
                    round(value/100,3)                                     AAS,
                 BEGIN_TIME ,
                 END_TIME
             from v$sysmetric
             where metric_name='CPU Usage Per Sec'
               and group_id=2
          union
            select 'CPU_OS'                                                CLASS ,
                    round((prcnt.busy*parameter.cpu_count)/100,3)          AAS,
                 BEGIN_TIME ,
                 END_TIME
            from
              ( select value busy, BEGIN_TIME,END_TIME from v$sysmetric where metric_name='Host CPU Utilization (%)' and group_id=2 ) prcnt,
              ( select value cpu_count from v$parameter where name='cpu_count' )  parameter
          union
             select
               'CPU_ORA_DEMAND'                                            CLASS,
               nvl(round( sum(decode(session_state,'ON CPU',1,0))/60,2),0) AAS,
               cast(min(SAMPLE_TIME) as date) BEGIN_TIME ,
               cast(max(SAMPLE_TIME) as date) END_TIME
             from v$active_session_history ash
              where SAMPLE_TIME >= (select BEGIN_TIME from v$sysmetric where metric_name='CPU Usage Per Sec' and group_id=2 )
               and SAMPLE_TIME < (select END_TIME from v$sysmetric where metric_name='CPU Usage Per Sec' and group_id=2 )
)
select
       to_char(BEGIN_TIME,'HH24:MI:SS') BEGIN_TIME,
       to_char(END_TIME,'HH24:MI:SS') END_TIME,
       CPU_OS CPU_TOTAL,
       decode(sign(CPU_OS-CPU_ORA_CONSUMED), -1, 0, (CPU_OS - CPU_ORA_CONSUMED )) CPU_OS,
       CPU_ORA_CONSUMED CPU_ORA,
       decode(sign(CPU_ORA_DEMAND-CPU_ORA_CONSUMED), -1, 0, (CPU_ORA_DEMAND - CPU_ORA_CONSUMED )) CPU_ORA_WAIT,
       COMMIT,
       READIO,
       WAIT 
       -- ,(  decode(sign(CPU_OS - CPU_ORA_CONSUMED), -1, 0, 
       --                (CPU_OS - CPU_ORA_CONSUMED))
       --    + CPU_ORA_CONSUMED +
       --  decode(sign(CPU_ORA_DEMAND - CPU_ORA_CONSUMED), -1, 0, 
       --             (CPU_ORA_DEMAND - CPU_ORA_CONSUMED ))) STACKED_CPU_TOTAL 
from ( 
        select 
                min(BEGIN_TIME) BEGIN_TIME,
                max(END_TIME) END_TIME, 
                sum(decode(CLASS,'CPU_ORA_CONSUMED',AAS,0)) CPU_ORA_CONSUMED, 
                sum(decode(CLASS,'CPU_ORA_DEMAND' ,AAS,0)) CPU_ORA_DEMAND, 
                sum(decode(CLASS,'CPU_OS' ,AAS,0)) CPU_OS, 
                sum(decode(CLASS,'Commit' ,AAS,0)) COMMIT, 
                sum(decode(CLASS,'User I/O' ,AAS,0)) READIO, 
                sum(decode(CLASS,'Wait' ,AAS,0)) WAIT 
         from AASSTAT) 
/