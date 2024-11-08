-- | Modificacao: V2.1 - 03/08/2019 - rfsobrinho - Vizulizar MODULE no USERNAME |
-- |            : V2.2 - 24/02/2021 - rfsobrinho - Ver POOL conexao e CHILD     |
-- +----------------------------------------------------------------------------+
-- |kill -9 $(ps -ef | grep -v grep | grep 'LOCAL=NO' | grep pbackS | awk '{print $2}')
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : concurrent run                                              |
PROMPT | Instance : &current_instance                                           |
PROMPT | Version  : 1.0                                                         |
PROMPT +------------------------------------------------------------------------+
SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINES       600
SET PAGES       600 
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col "SID/SERIAL" format a15  HEADING 'SID/SERIAL@I'
col slave        format a16  HEADING 'SLAVE/W_CLASS'
col opid         format a04
col sopid        format a08
col username     format a10
col osuser       format a10
col call_et      format a07
col program      format a10
col client_info  format a23
col machine      format a19
col logon_time   format a13 
col hold         format a06
col sessionwait  format a24
col status       format a08
col hash_value   format a10 
col sc_wait      format a06 HEADING 'WAIT'
col SQL_ID       format a15 HEADING 'SQL_ID/CHILD'
col module       format a08 HEADING 'MODULE'


col REQ_ID             format  a11
col PAR_REQ_ID         format  a11
col STATUS             format  a14
col TEMPO              format  a11
col CONC_PROG_ID       format  a12
col ACTUAL_START_DATE  format  a18
col user_name          format  a12
col uc_program_name    format  a40
col c_program_name     format  a30



SET COLSEP '|'




	Select to_char(fcwr.request_id) REQ_ID
		 , DECODE(fcwr.parent_request_id, -1, '', fcwr.parent_request_id) PAR_REQ_ID
		 , DECODE( fcwr.status_code
				 , 'A', '(A)Waiting'
				 , 'B', '(B)Resuming'
				 , 'C', '(C)Normal'
				 , 'D', '(D)Cancelled'
				 , 'E', '(E)Error'
				 , 'G', '(G)Warning'
				 , 'H', '(H)On Hold'
				 , 'I', '(I)Normal'
				 , 'M', '(M)No Manager'
				 , 'P', '(P)Scheduled'
				 , 'Q', '(Q)Standby'
				 , 'R', '(R)Normal'
				 , 'S', '(S)Suspended'
				 , 'T', '(T)Terminating'
				 , 'U', '(U)Disabled'
				 , 'W', '(W)Paused'
				 , 'X', '(X)Terminated'
				 , 'Z', '(Z)Waiting'
				 , fcwr.status_code) STATUS
	   , fcwr.oracle_process_id sopid
	   , to_char(fcwr.concurrent_program_id) CONC_PROG_ID
		 , FLOOR ((sysdate - fcwr.actual_start_date) * 24 ) || ':'
		   || LPAD(TO_CHAR(FLOOR(MOD((sysdate - fcwr.actual_start_date)*24, 1)*60)), 2, '0') || ':'
		   || LPAD(TO_CHAR(FLOOR(MOD((sysdate - fcwr.actual_start_date)*24*60, 1)*60)), 2, '0')  TEMPO
		 , to_char(fcwr.actual_start_date, 'dd/mon/yy hh24:mi:ss') ACTUAL_START_DATE
		 , substr(fu.user_name,1,12) user_name 
		 , substr(fcwr.user_concurrent_program_name,1,40)   uc_program_name
		-- , fcqt.USER_CONCURRENT_QUEUE_NAME	USER_CONCURRENT_QUEUE_NAME
		 ,  substr(fcwr.concurrent_program_name,1,40)   c_program_name
	-- , fcwr.argument_text
	  from apps.fnd_concurrent_worker_requests fcwr
		 , apps.fnd_concurrent_queues_Vl fcqt
		 , apps.fnd_user fu
	 Where phase_code = 'R'
	   And 
		  fcqt.concurrent_queue_id = fcwr.concurrent_queue_id
	   And fu.user_id = fcwr.requested_by
	-- And fcwr.concurrent_program_id   = 44363
	-- And fcwr.concurrent_program_name = 'GL'
	Order by actual_start_date
	/





/*

SQL> desc apps.fnd_concurrent_worker_requests
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 REQUEST_ID                                NOT NULL NUMBER(15)
 LAST_UPDATE_DATE                          NOT NULL DATE
 LAST_UPDATED_BY                           NOT NULL NUMBER(15)
 REQUEST_DATE                              NOT NULL DATE
 REQUESTED_BY                              NOT NULL NUMBER(15)
 PHASE_CODE                                NOT NULL VARCHAR2(1)
 STATUS_CODE                               NOT NULL VARCHAR2(1)
 PRIORITY_REQUEST_ID                       NOT NULL NUMBER(15)
 PRIORITY                                  NOT NULL NUMBER(15)
 REQUESTED_START_DATE                      NOT NULL DATE
 HOLD_FLAG                                 NOT NULL VARCHAR2(1)
 ENFORCE_SERIALITY_FLAG                    NOT NULL VARCHAR2(1)
 SINGLE_THREAD_FLAG                        NOT NULL VARCHAR2(1)
 HAS_SUB_REQUEST                           NOT NULL VARCHAR2(1)
 IS_SUB_REQUEST                            NOT NULL VARCHAR2(1)
 IMPLICIT_CODE                             NOT NULL VARCHAR2(1)
 UPDATE_PROTECTED                          NOT NULL VARCHAR2(1)
 QUEUE_METHOD_CODE                         NOT NULL VARCHAR2(1)
 ARGUMENT_INPUT_METHOD_CODE                NOT NULL VARCHAR2(1)
 ORACLE_ID                                 NOT NULL NUMBER(15)
 PROGRAM_APPLICATION_ID                    NOT NULL NUMBER(15)
 CONCURRENT_PROGRAM_ID                     NOT NULL NUMBER(15)
 RESPONSIBILITY_APPLICATION_ID             NOT NULL NUMBER(15)
 RESPONSIBILITY_ID                         NOT NULL NUMBER(15)
 NUMBER_OF_ARGUMENTS                       NOT NULL NUMBER(3)
 NUMBER_OF_COPIES                          NOT NULL NUMBER(15)
 SAVE_OUTPUT_FLAG                          NOT NULL VARCHAR2(1)
 NLS_COMPLIANT                             NOT NULL VARCHAR2(1)
 LAST_UPDATE_LOGIN                                  NUMBER(15)
 NLS_LANGUAGE                                       VARCHAR2(30)
 NLS_TERRITORY                                      VARCHAR2(30)
 PRINTER                                            VARCHAR2(30)
 PRINT_STYLE                                        VARCHAR2(30)
 PRINT_GROUP                                        VARCHAR2(1)
 REQUEST_CLASS_APPLICATION_ID                       NUMBER(15)
 CONCURRENT_REQUEST_CLASS_ID                        NUMBER(15)
 PARENT_REQUEST_ID                                  NUMBER(15)
 CONC_LOGIN_ID                                      NUMBER(15)
 LANGUAGE_ID                                        NUMBER(15)
 DESCRIPTION                                        VARCHAR2(240)
 REQ_INFORMATION                                    VARCHAR2(240)
 RESUBMIT_INTERVAL                                  NUMBER(15,10)
 RESUBMIT_INTERVAL_UNIT_CODE                        VARCHAR2(30)
 RESUBMIT_INTERVAL_TYPE_CODE                        VARCHAR2(30)
 RESUBMIT_TIME                                      VARCHAR2(8)
 RESUBMIT_END_DATE                                  DATE
 RESUBMITTED                                        VARCHAR2(1)
 CONTROLLING_MANAGER                                NUMBER(15)
 ACTUAL_START_DATE                                  DATE
 ACTUAL_COMPLETION_DATE                             DATE
 COMPLETION_TEXT                                    VARCHAR2(240)
 OUTCOME_PRODUCT                                    VARCHAR2(20)
 OUTCOME_CODE                                       NUMBER(15)
 CPU_SECONDS                                        NUMBER(15,3)
 LOGICAL_IOS                                        NUMBER(15)
 PHYSICAL_IOS                                       NUMBER(15)
 LOGFILE_NAME                                       VARCHAR2(255)
 LOGFILE_NODE_NAME                                  VARCHAR2(30)
 OUTFILE_NAME                                       VARCHAR2(255)
 OUTFILE_NODE_NAME                                  VARCHAR2(30)
 ARGUMENT_TEXT                                      VARCHAR2(240)
 ARGUMENT1                                          VARCHAR2(240)
 ARGUMENT2                                          VARCHAR2(240)
 ARGUMENT3                                          VARCHAR2(240)
 ARGUMENT4                                          VARCHAR2(240)
 ARGUMENT5                                          VARCHAR2(240)
 ARGUMENT6                                          VARCHAR2(240)
 ARGUMENT7                                          VARCHAR2(240)
 ARGUMENT8                                          VARCHAR2(240)
 ARGUMENT9                                          VARCHAR2(240)
 ARGUMENT10                                         VARCHAR2(240)
 ARGUMENT11                                         VARCHAR2(240)
 ARGUMENT12                                         VARCHAR2(240)
 ARGUMENT13                                         VARCHAR2(240)
 ARGUMENT14                                         VARCHAR2(240)
 ARGUMENT15                                         VARCHAR2(240)
 ARGUMENT16                                         VARCHAR2(240)
 ARGUMENT17                                         VARCHAR2(240)
 ARGUMENT18                                         VARCHAR2(240)
 ARGUMENT19                                         VARCHAR2(240)
 ARGUMENT20                                         VARCHAR2(240)
 ARGUMENT21                                         VARCHAR2(240)
 ARGUMENT22                                         VARCHAR2(240)
 ARGUMENT23                                         VARCHAR2(240)
 ARGUMENT24                                         VARCHAR2(240)
 ARGUMENT25                                         VARCHAR2(240)
 CRM_THRSHLD                                        NUMBER(15)
 CRM_TSTMP                                          DATE
 CRITICAL                                           VARCHAR2(1)
 REQUEST_TYPE                                       VARCHAR2(1)
 ORACLE_PROCESS_ID                                  VARCHAR2(30)
 ORACLE_SESSION_ID                                  NUMBER(15)
 OS_PROCESS_ID                                      VARCHAR2(240)
 PRINT_JOB_ID                                       VARCHAR2(240)
 OUTPUT_FILE_TYPE                                   VARCHAR2(4)
 RELEASE_CLASS_APP_ID                               NUMBER
 RELEASE_CLASS_ID                                   NUMBER
 STALE_DATE                                         DATE
 CANCEL_OR_HOLD                                     VARCHAR2(1)
 NOTIFY_ON_PP_ERROR                                 VARCHAR2(255)
 CD_ID                                              NUMBER
 REQUEST_LIMIT                                      VARCHAR2(1)
 CRM_RELEASE_DATE                                   DATE
 POST_REQUEST_STATUS                                VARCHAR2(1)
 COMPLETION_CODE                                    VARCHAR2(30)
 INCREMENT_DATES                                    VARCHAR2(1)
 RESTART                                            VARCHAR2(1)
 ENABLE_TRACE                                       VARCHAR2(1)
 RESUB_COUNT                                        NUMBER
 NLS_CODESET                                        VARCHAR2(30)
 OFILE_SIZE                                         NUMBER(15)
 LFILE_SIZE                                         NUMBER(15)
 STALE                                              VARCHAR2(1)
 SECURITY_GROUP_ID                                  NUMBER
 RESOURCE_CONSUMER_GROUP                            VARCHAR2(30)
 EXP_DATE                                           DATE
 QUEUE_APP_ID                                       NUMBER(15)
 QUEUE_ID                                           NUMBER(15)
 OPS_INSTANCE                              NOT NULL NUMBER(15)
 INTERIM_STATUS_CODE                                VARCHAR2(1)
 ROOT_REQUEST_ID                                    NUMBER(15)
 ORIGIN                                             VARCHAR2(1)
 NLS_NUMERIC_CHARACTERS                             VARCHAR2(2)
 PP_START_DATE                                      DATE
 PP_END_DATE                                        DATE
 ORG_ID                                             NUMBER(15)
 RUN_NUMBER                                         NUMBER(5)
 NODE_NAME1                                         VARCHAR2(30)
 NODE_NAME2                                         VARCHAR2(30)
 CONNSTR1                                           VARCHAR2(255)
 CONNSTR2                                           VARCHAR2(255)
 RECALC_PARAMETERS                                  VARCHAR2(1)
 QUEUE_APPLICATION_ID                      NOT NULL NUMBER(15)
 CONCURRENT_QUEUE_ID                       NOT NULL NUMBER(15)
 CONCURRENT_QUEUE_NAME                     NOT NULL VARCHAR2(30)
 CONTROL_CODE                                       VARCHAR2(1)
 PROCESSOR_APPLICATION_ID                  NOT NULL NUMBER(15)
 CONCURRENT_PROCESSOR_ID                   NOT NULL NUMBER(15)
 RUNNING_PROCESSES                         NOT NULL NUMBER(4)
 MAX_PROCESSES                             NOT NULL NUMBER(4)
 CACHE_SIZE                                         NUMBER(3)
 TARGET_NODE                                        VARCHAR2(30)
 QUEUE_DESCRIPTION                                  VARCHAR2(240)
 CONCURRENT_PROGRAM_NAME                   NOT NULL VARCHAR2(30)
 EXECUTION_METHOD_CODE                     NOT NULL VARCHAR2(1)
 ARGUMENT_METHOD_CODE                      NOT NULL VARCHAR2(1)
 QUEUE_CONTROL_FLAG                        NOT NULL VARCHAR2(1)
 RUN_ALONE_FLAG                            NOT NULL VARCHAR2(1)
 ENABLED_FLAG                              NOT NULL VARCHAR2(1)
 PROGRAM_DESCRIPTION                                VARCHAR2(240)
 USER_CONCURRENT_PROGRAM_NAME              NOT NULL VARCHAR2(240)
 REQUEST_DESCRIPTION                                VARCHAR2(483)
*/