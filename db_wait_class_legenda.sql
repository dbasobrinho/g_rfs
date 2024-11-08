SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Legendas Eventos de Espera                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    300
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

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
