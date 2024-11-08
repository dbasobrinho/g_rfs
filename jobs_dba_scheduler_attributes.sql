-- -----------------------------------------------------------------------------------
-- File Name    : jobs_dba_scheduler_attributes.sql
-- Author       : Roberto Sobrinho
-- Description  : Mostrar informacoes sobre jobs ATTRIBUTES 
-- Requirements : Acesso de leitura nas visoes de DBA
-- Call Syntax  : @jobs_dba_scheduler_attributes.sql
-- Last Modified: 07/03/2022
-- -----------------------------------------------------------------------------------SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DBA_SCHEDULER_JOBS_ATTRIBUTES                               |
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
PROMPT .
PROMPT . .
PROMPT . . .
col owner for a6
col job_name for a25
col job_action for a40
COL LAST_START_DATE for a22
COL NEXT_RUN_DATE for a22
COL state for a10
COL LAST_RUN_DURATION for a26
col fail for 9999
col max_fail for 9999

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/10g/scheduler_attributes.sql
-- Author       : Tim Hall
-- Description  : Displays the top-level scheduler parameters.
-- Requirements : Access to the DBMS_SCHEDULER package and the MANAGE SCHEDULER privilege.
-- Call Syntax  : @scheduler_attributes
-- Last Modified: 13-DEC-2016
-- -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
DECLARE
  PROCEDURE display(p_param IN VARCHAR2) AS
    l_result VARCHAR2(50);
  BEGIN
    DBMS_SCHEDULER.get_scheduler_attribute(
      attribute => p_param,
      value     => l_result);
    DBMS_OUTPUT.put_line(RPAD(p_param, 30, ' ') || ' : ' || l_result);
  END;
BEGIN
  display('current_open_window');
  display('default_timezone');
  display('email_sender');
  display('email_server');
  display('event_expiry_time');
  display('log_history');
  display('max_job_slave_processes');
END;
/

---------     BEGIN
---------     DBMS_SCHEDULER.set_scheduler_attribute (attribute => 'max_job_slave_processes',value => 7);
---------     END;
---------     /
---------     select * from dba_scheduler_global_attribute where attribute_name='MAX_JOB_SLAVE_PROCESSES';