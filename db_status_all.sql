set pages 1000
set lines 1000
COLUMN INSTANCE_NAME FORMAT A13
COLUMN DB_STATUS     FORMAT A10
COLUMN VERSION       FORMAT A10
COLUMN HOST_NAME     FORMAT A17
COLUMN STARTUP_TIME  FORMAT A22
COLUMN ACTIVE_STATE  FORMAT A12
COLUMN date_scn      FORMAT A22
COLUMN cur_scn       FORMAT A8
COLUMN f_logging     FORMAT A5

SELECT UPPER(A.INSTANCE_NAME) INSTANCE_NAME, 
       UPPER(A.HOST_NAME) HOST_NAME,
       A.VERSION, 
       TO_CHAR(A.STARTUP_TIME, 'DD-MON-YYYY HH24:MI:SS') STARTUP_TIME, 
       A.STATUS, 
       A.ARCHIVER, 
       A.LOGINS, 
       A.ACTIVE_STATE,
       A.DATABASE_STATUS DB_STATUS,
	   to_char(scn_to_timestamp(b.current_scn),'dd/mm/yyyy hh24:mi:ss') as date_scn,
	   to_char(b.current_scn) cur_scn,
       b.force_logging as f_logging	   
FROM V$INSTANCE A, v$database B
/