# #####################################################################################################################################################
# Monitor audit records [Failed login attempts & MAJOR AUDIT RECRODS] on audit trail table
VER="[1.0]"
SCRIPT_NAME="monitor_audit_records"
# #####################################################################################################################################################
#                                       #   #     #
# Author:       Mahmmoud ADEL         # # # #   ###
# Created:      28-09-20            #   #   # #   #  
# Modified:	04-10-20 Added the awarness of machine TIMEZONE to avoid wrong data fetch when timezone is UTC.
#
#
#
#
# ######################################################################################################################################################
EMAIL="roberto.fernandes@tivit.com"

# #########################
# THRESHOLDS:
# #########################
# Modify the THRESHOLDS to the value you prefer:

HTMLENABLE=Y            # Enable HTML Email Format [Default Enabled].
MINUTES=10              # Check audit records in the last N number of minutes [Default 5 minutes].
RECORDSNUM=1            # Send an Email if the number of audit records exceed the threshold [Default 1 record].
REPORT_FAILED_LOGINS=Y  # Enable the reporting of failled logins [Default Enabled].
REPORT_AUDIT_RECORDS=Y  # Enable the reporting of audit records [Default Enabled].
EXCLUDE_DBUSERS="'dba_bundleexp7'"	# Exclude DB user from reporting their activities [In lowercase]. e.g. EXCLUDE_DBUSERS="'sys','scott'"
EXCLUDE_OSUSERS="'user1'"		# Exclude OS user from reporting their activities [In lowercase]. e.g. EXCLUDE_OSUSERS="'oracle','grid'"
EXCLUDE_ACTIONS="'SELECT','SET ROLE','LOGON','LOGOFF','LOGOFF BY CLEANUP','EXPLAIN','PL/SQL EXECUTE','SYSTEM AUDIT'" # Exclude AUDIT EVENTS from reporting
# e.g. To exclude all previous Audit Events along with DMLs (inserts, updates, deletes):
# EXCLUDE_ACTIONS="'SELECT','SET ROLE','LOGON','LOGOFF','LOGOFF BY CLEANUP','EXPLAIN','PL/SQL EXECUTE','SYSTEM AUDIT','SESSION REC'"
# To explore all the current available events in your DB run:
# SQL> select distinct action_name from dba_audit_trail;
SQLLINESIZE=200         # The LINE SIZE for SQLPLUS outputs.
OSLINESIZE=300          # The LINE SIZE for OS Commands outputs. [Default is 167]
SENDER="AUDITRECORDS"	# Change the Email sender name. e.g. EXCLUDE_DBUSERS="AUDITRECORDS"

# #######################################
# Excluded INSTANCES:
# #######################################
# Here you can mention the instances the script will not run against:
# Use pipe "|" as a separator between each instance name.
# e.g. Excluding: -MGMTDB, ASM and APX instances:
EXL_DB="\-MGMTDB|ASM|APX"


# #######################################
# Verify Variables:
# #######################################

export HTMLENABLE
export MINUTES
export RECORDSNUM
export REPORT_FAILED_LOGINS
export REPORT_AUDIT_RECORDS
export EXCLUDE_DBUSERS
export EXCLUDE_OSUSERS
export EXCLUDE_ACTIONS
export SQLLINESIZE
export OSLINESIZE
export EXL_DB

case ${EXCLUDE_DBUSERS} in
"") export HASHDBUSERNAME="--";;
 *) export HASHDBUSERNAME="";;
esac

case ${EXCLUDE_OSUSERS} in
"") export HASHOSUSERNAME="--";;
 *) export HASHOSUSERNAME="";;
esac

case ${EXCLUDE_ACTIONS} in
"") export HASHACTIONNAME="--";;
 *) export HASHACTIONNAME="";;
esac


export SRV_NAME="`uname -n`"

	# Check if MAIL_LIST parameter is not set notify the user and exit:
        case ${EMAIL} in "youremail@yourcompany.com")
         echo
         echo "******************************************************************"
         echo "Buddy! You forgot to edit line# 50 in ${SCRIPT_NAME}.sh script."
         echo "Please replace youremail@yourcompany.com with your E-mail address."
         echo "******************************************************************"
         echo
         echo "Script Terminated !"
         echo 
         exit;;
        esac

	# Check if there is another session of the script is running: [Avoid performance impact]
	RUNCOUNTT=`ps -ef|grep -v grep|grep -v vi|grep ${SCRIPT_NAME}|wc -l`
	if [ ${RUNCOUNTT} -gt 2 ]
   	 then
	 echo -e "\033[32;5m${SCRIPT_NAME}.sh script is currently running by another session.\033[0m"
	 echo ""
	 echo "Please make sure the following sessions are completed before running dbalarm script: [ps -ef|grep -v grep|grep -v vi|grep ${SCRIPT_NAME}]"
	 ps -ef|grep -v grep|grep -v vi|grep ${SCRIPT_NAME}.sh
	 echo "Script Terminated !"
	 echo
	 exit
	fi
	
export MAIL_LIST="${EMAIL}"
#export MAIL_LIST="-r ${SRV_NAME} ${EMAIL}"

echo
echo "[${SCRIPT_NAME} Script Started ...]"
echo

# Verify log location:
LOGDIR=/tmp
if [ ! -w "${LOGDIR}" ]; then
LOGDIR=~
fi

# ###########################
# Check the Linux OS version:
# ###########################
export PATH=${PATH}:/usr/local/bin
FILE_NAME=/etc/redhat-release
export FILE_NAME
	if [ -f ${FILE_NAME} ]
	then
LNXVER=`cat /etc/redhat-release | grep -o '[0-9]'|head -1`
export LNXVER
	fi

# ##########################
# MACHINE TIMEZONE:
# ##########################

# When machine is not in UTC:
export SYSDATE_PATTERN="new_time(sysdate - ${MINUTES}/1440,'gmt','edt')"

# When machine is in UTC:
FILE_NAME=/etc/localtime
export FILE_NAME
        if [ -f ${FILE_NAME} ]
        then
UTC_EXIST=`ls -l /etc/localtime|grep 'UTC\|GMT'|wc -l`
		if [ ${UTC_EXIST} -gt 0 ]
		then
		export SYSDATE_PATTERN="sysdate - ${MINUTES}/1440"
		fi
	fi
		
# Run the script on each DB:
for ORACLE_SID in $( ps -ef|grep pmon|grep -v grep|egrep -v ${EXL_DB}|awk '{print $NF}'|sed -e 's/ora_pmon_//g'|grep -v sed|grep -v "s///g" )
   do
    export ORACLE_SID

# ###################
# Getting ORACLE_HOME:
# ###################
  ORA_USER=`ps -ef|grep ${ORACLE_SID}|grep pmon|grep -v grep|egrep -v ${EXL_DB}|grep -v "\-MGMTDB"|awk '{print $1}'|tail -1`
  USR_ORA_HOME=`grep -i "^${ORA_USER}:" /etc/passwd| cut -f6 -d ':'|tail -1`

# SETTING ORATAB:
if [ -f /etc/oratab ]
  then
ORATAB=/etc/oratab
export ORATAB
## If OS is Solaris:
elif [ -f /var/opt/oracle/oratab ]
  then
ORATAB=/var/opt/oracle/oratab
export ORATAB
fi

# ATTEMPT1: Get ORACLE_HOME using pwdx command:
PMON_PID=`pgrep  -lf _pmon_${ORACLE_SID}|awk '{print $1}'`
export PMON_PID
ORACLE_HOME=`pwdx ${PMON_PID} 2>/dev/null|awk '{print $NF}'|sed -e 's/\/dbs//g'`
export ORACLE_HOME

# ATTEMPT2: If ORACLE_HOME not found get it from oratab file:
if [ ! -f ${ORACLE_HOME}/bin/sqlplus ]
 then
## If OS is Linux:
if [ -f /etc/oratab ]
  then
ORATAB=/etc/oratab
ORACLE_HOME=`grep -v '^\#' ${ORATAB} | grep -v '^$'| grep -i "^${ORACLE_SID}:" | perl -lpe'$_ = reverse' | cut -f3 | perl -lpe'$_ = reverse' |cut -f2 -d':'`
export ORACLE_HOME

## If OS is Solaris:
elif [ -f /var/opt/oracle/oratab ]
  then
ORATAB=/var/opt/oracle/oratab
ORACLE_HOME=`grep -v '^\#' ${ORATAB} | grep -v '^$'| grep -i "^${ORACLE_SID}:" | perl -lpe'$_ = reverse' | cut -f3 | perl -lpe'$_ = reverse' |cut -f2 -d':'`
export ORACLE_HOME
fi
fi

# ATTEMPT3: If ORACLE_HOME is in /etc/oratab, use dbhome command:
if [ ! -f ${ORACLE_HOME}/bin/sqlplus ]
 then
ORACLE_HOME=`dbhome "${ORACLE_SID}"`
export ORACLE_HOME
fi

# ATTEMPT4: If ORACLE_HOME is still not found, search for the environment variable: [Less accurate]
if [ ! -f ${ORACLE_HOME}/bin/sqlplus ]
 then
ORACLE_HOME=`env|grep -i ORACLE_HOME|sed -e 's/ORACLE_HOME=//g'`
export ORACLE_HOME
fi

# ATTEMPT5: If ORACLE_HOME is not found in the environment search user's profile: [Less accurate]
if [ ! -f ${ORACLE_HOME}/bin/sqlplus ]
 then
ORACLE_HOME=`grep -h 'ORACLE_HOME=\/' ${USR_ORA_HOME}/.bash_profile ${USR_ORA_HOME}/.*profile | perl -lpe'$_ = reverse' |cut -f1 -d'=' | perl -lpe'$_ = reverse'|tail -1`
export ORACLE_HOME
fi

# ATTEMPT6: If ORACLE_HOME is still not found, search for orapipe: [Least accurate]
if [ ! -f ${ORACLE_HOME}/bin/sqlplus ]
 then
	if [ -x /usr/bin/locate ]
 	 then
ORACLE_HOME=`locate -i orapipe|head -1|sed -e 's/\/bin\/orapipe//g'`
export ORACLE_HOME
	fi
fi

# TERMINATE: If all above attempts failed to get ORACLE_HOME location, EXIT the script:
if [ ! -f ${ORACLE_HOME}/bin/sqlplus ]
 then
  echo "Please export ORACLE_HOME variable in your .bash_profile file under oracle user home directory in order to get this script to run properly"
  echo "e.g."
  echo "export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1"
exit
fi

printf "`echo "Reporting AUDIT records on Database ["` `echo -e "\033[33;5m${ORACLE_SID}\033[0m"` `echo "]"`\n"
echo ""

# ###################
# WARNINGS SECTION:
# ###################

# Display a WARNING message if AUDITING is not enabled:

AUDCOUNTRAW=$(${ORACLE_HOME}/bin/sqlplus -s '/ as sysdba' << EOF
set pages 0 feedback off;
prompt
SELECT COUNT(*) FROM V\$PARAMETER WHERE NAME='audit_trail' AND VALUE='NONE';
exit;
EOF
)
AUDCOUNT=`echo ${AUDCOUNTRAW}|perl -lpe'$_ = reverse' |awk '{print $1}'|perl -lpe'$_ = reverse'|cut -f1 -d '.'`

  if [ ${AUDCOUNT} -ge 1 ]
   then
echo ""
printf "`echo -e "\033[33;5mINFO!\033[0m"` `echo " AUDITING IS NOT ENABLED ON DATABASE [${ORACLE_SID}] ..."`\n"
echo ""
  fi

# Display a WARNING message if NTIMESTAMP# column in sys.aud$ is not indexed:

INDEXCOUNTRAW=$(${ORACLE_HOME}/bin/sqlplus -s '/ as sysdba' << EOF
set pages 0 feedback off;
prompt
select count(*) from dba_ind_columns where table_owner='SYS' and table_name='AUD\$' and column_name='NTIMESTAMP#';
exit;
EOF
)
INDEXCOUNT=`echo ${INDEXCOUNTRAW}|perl -lpe'$_ = reverse' |awk '{print $1}'|perl -lpe'$_ = reverse'|cut -f1 -d '.'`

  if [ ${INDEXCOUNT} -le 0 ]
   then
echo ""
printf "`echo -e "\033[33;5mWARNING:\033[0m"` `echo " NTIMESTAMP# Column in sys.aud$ table is"` `echo -e "\033[33;5mNOT INDEXED\033[0m"`\n"
echo ""
echo "This script may cause a performance degradation when it run!"
echo "In order to avoid execution slowness, create an index on aud$ (NTIMESTAMP#) column by executing this CREATE INDEX statement:"
echo ""
echo "CREATE INDEX sys.idx_ntimestamp# ON sys.aud\$(ntimestamp#) ONLINE;"
echo "EXEC DBMS_STATS.GATHER_TABLE_STATS (ownname => 'SYS', tabname => 'AUD\$', cascade => TRUE, estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE);"
echo ""
echo ""
export NOINDEXWARNING="PROMPT"
export NOINDEXWARNING1="PROMPT RECOMMENDATION: sys.aud$ table should be INDEXED to speed up this script using these statements:"
export NOINDEXWARNING2="PROMPT CREATE INDEX sys.idx_ntimestamp# ON sys.aud\$(ntimestamp#) ONLINE;;"
export NOINDEXWARNING3="PROMPT EXEC DBMS_STATS.GATHER_TABLE_STATS (ownname => 'SYS', tabname => 'AUD$', cascade => TRUE, estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE);;"
sleep 2
  fi



# ###################
# Check failed logins:
# ###################
                 case ${REPORT_FAILED_LOGINS} in
                 y|Y|yes|YES|Yes|ON|On|on)
FAILEDLOGINCOUNTRAW=$(${ORACLE_HOME}/bin/sqlplus -s '/ as sysdba' << EOF
set pages 0 feedback off;
prompt
select count(*) from aud\$
where   ntimestamp# >= ${SYSDATE_PATTERN}
and 	action# between 100 and 102
and     returncode = 1017
${HASHDBUSERNAME} and   lower (USERID) not in (${EXCLUDE_DBUSERS})
${HASHOSUSERNAME} and   lower (SPARE1) not in (${EXCLUDE_OSUSERS})
/

/*
select count(*) from DBA_AUDIT_SESSION
where 	returncode = 1017
and 	timestamp >= ${SYSDATE_PATTERN}
${HASHDBUSERNAME} and   lower (USERNAME)    not in (${EXCLUDE_DBUSERS})
${HASHOSUSERNAME} and   lower (OS_USERNAME) not in (${EXCLUDE_OSUSERS})
/
*/
exit;
EOF
)
FAILEDLOGINCOUNT=`echo ${FAILEDLOGINCOUNTRAW}|perl -lpe'$_ = reverse' |awk '{print $1}'|perl -lpe'$_ = reverse'|cut -f1 -d '.'`

  if [ ${FAILEDLOGINCOUNT} -gt 0 ]
   then
echo "FAILED LOGIN ATTEMPTS DETECTED. SENDING AN EMAIL ALERT ..."
FAILEDLOGINLOG=/tmp/failed_login_report_${ORACLE_SID}.log
touch ${FAILEDLOGINLOG}

# HTML Preparation:
# #################
   case ${HTMLENABLE} in
   y|Y|yes|YES|Yes|ON|On|on)
        if [ -x /usr/sbin/sendmail ]
        then
export SENDMAIL="/usr/sbin/sendmail -t"
export MAILEXEC="echo #"
export HASHHTML=""
export HASHHTMLOS=""
export ENDHASHHTMLOS=""
export HASHNONHTML="--"
SENDMAILARGS=$(
echo "To:           ${EMAIL};"
echo "Subject:      ${MSGSUBJECT} ;"
echo "Content-Type: text/html;"
echo "MIME-Version: 1.0;"
cat ${FAILEDLOGINLOG}
)
export SENDMAILARGS
        else
export SENDMAIL="echo #"
export MAILEXEC="mail -s"
export HASHHTML="--"
export HASHHTMLOS="echo #"
export ENDHASHHTMLOS=""
export HASHNONHTML=""
        fi
   ;;
   *)
export SENDMAIL="echo #"
export HASHHTML="--"
export HASHHTMLOS="echo #"
export ENDHASHHTMLOS=""
export HASHNONHTML=""
export MAILEXEC="mail -s"
   ;;
   esac

FAILEDLOGINOUTPUT=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" << EOF
set pages 0 termout off echo off feedback off linesize ${SQLLINESIZE}
EXEC DBMS_SESSION.set_identifier('${SCRIPT_NAME}');

-- Enable HTML color format:
${HASHHTML} SET WRAP OFF ECHO OFF FEEDBACK OFF MARKUP HTML ON SPOOL ON HEAD '<title></title> <style type="text/css"> table { background: #E67E22; font-size: 80%; } th { background: #AF601A; } td { background: #E67E22; padding: 0px; } </style>' TABLE "border='1' bordercolor='#E67E22'" ENTMAP OFF

SPOOL ${FAILEDLOGINLOG}

prompt
${HASHHTML} SET PAGES 0
${HASHHTML} SET MARKUP HTML OFF SPOOL OFF
${HASHHTML} PROMPT <br> <p> <table border='3' bordercolor='#E67E22' width='30%' align='left' summary='Script output'> <tr> <th scope="col">
${HASHHTML} PROMPT FAILED LOGIN ATTEMPTS: [Last ${MINUTES} Minutes]
${HASHHTML} PROMPT </td> </tr> </table> <p> <br>
${HASHHTML} SET WRAP OFF ECHO OFF FEEDBACK OFF MARKUP HTML ON SPOOL ON HEAD '<title></title> <style type="text/css"> table { background: #E67E22; font-size: 80%; } th { background: #AF601A; } td { background: #E67E22; padding: 0px; } </style>' TABLE "border='2' bordercolor='#E67E22'" ENTMAP OFF
${HASHHTML} set pages 1000

${HASHNONHTML} prompt **************************************** 

${HASHNONHTML} Prompt FAILED LOGIN ATTEMPTS [Last ${MINUTES} Minutes]
${HASHNONHTML} prompt **************************************** 

set feedback off linesize ${SQLLINESIZE} pages 1000 timing on
col TERMINAL 	FOR A30
col ACTION_NAME FOR A20
col TIMESTAMP 	FOR A21
col OS_USERNAME FOR A20
col DB_USERNAME FOR A20
col DATE        FOR A22
col USERHOST    FOR A30

select to_char (ntimestamp#,'DD-MON-YYYY HH24:MI:SS') TIMESTAMP,USERID DB_USERNAME, spare1 OS_USERNAME, USERHOST, TERMINAL from aud\$
Where 	ntimestamp# >= ${SYSDATE_PATTERN}
and     action# between 100 and 102
and     returncode = 1017
${HASHDBUSERNAME} and   lower (USERID)  not in (${EXCLUDE_DBUSERS})
${HASHOSUSERNAME} and   lower (spare1)  not in (${EXCLUDE_OSUSERS})
order by ntimestamp#
/

PROMPT
${NOINDEXWARNING}
${NOINDEXWARNING1}
${NOINDEXWARNING2}
${NOINDEXWARNING3}

/*
select to_char (EXTENDED_TIMESTAMP,'DD-MON-YYYY HH24:MI:SS') TIMESTAMP,OS_USERNAME,DB_USERNAME,TERMINAL,USERHOST,ACTION_NAME
from DBA_AUDIT_SESSION
where 	returncode = 1017
and 	timestamp >= ${SYSDATE_PATTERN}
${HASHDBUSERNAME} and   lower (USERNAME)    not in (${EXCLUDE_DBUSERS})
${HASHOSUSERNAME} and   lower (OS_USERNAME) not in (${EXCLUDE_OSUSERS})
order by EXTENDED_TIMESTAMP
/
*/

SPOOL OFF
exit;
EOF
)

export MSGSUBJECT="ALERT: FAILED LOGIN ATTEMPT DETECTED ON [${ORACLE_SID}] ON [${SRV_NAME}]"
echo ${MSGSUBJECT}

SENDMAILARGS=$(
echo "From:         ${SENDER};"
echo "To:           ${EMAIL};"
echo "Subject:      ${MSGSUBJECT} ;"
echo "Content-Type: text/html;"
echo "MIME-Version: 1.0;"
cat ${FAILEDLOGINLOG}
)

${MAILEXEC} "${MSGSUBJECT}" ${MAIL_LIST} < ${FAILEDLOGINLOG}
echo ${SENDMAILARGS} | tr \; '\n' |awk 'length == 1 || NR == 1 {print $0} length && NR > 1 { print substr($0,2) }'| ${SENDMAIL}
        fi

echo "FAILED LOGIN CHECK COMPLETED."
echo
		;;
		esac


# ####################
# Check AUDIT RECORDS:
# ####################

                 case ${REPORT_AUDIT_RECORDS} in
                 y|Y|yes|YES|Yes|ON|On|on)
AUDITRECORDSCOUNTRAW=$(${ORACLE_HOME}/bin/sqlplus -s '/ as sysdba' << EOF
set pages 0 feedback off;
prompt
-- Avoided using DBA_AUDIT_TRAIL view to not get the index on AUD\$(NTIMESTAMP#) ignored in the execution plan!
select count(*) from aud\$ a, audit_actions act
where a.action# = act.action (+)
and   a.ntimestamp# >= ${SYSDATE_PATTERN}
${HASHDBUSERNAME} and   lower (a.USERID)    not in (${EXCLUDE_DBUSERS})
${HASHOSUSERNAME} and   lower (a.spare1)    not in (${EXCLUDE_OSUSERS})
${HASHACTIONNAME} and   upper (act.NAME)    not in (${EXCLUDE_ACTIONS})
/

/*
select count(*) from DBA_AUDIT_TRAIL
where 	timestamp >= ${SYSDATE_PATTERN}
${HASHDBUSERNAME} and   lower (USERNAME)    not in (${EXCLUDE_DBUSERS})
${HASHOSUSERNAME} and   lower (OS_USERNAME) not in (${EXCLUDE_OSUSERS})
${HASHACTIONNAME} and   upper (ACTION_NAME) not in (${EXCLUDE_ACTIONS})
/
*/
exit;
EOF
)
AUDITRECORDSCOUNT=`echo ${AUDITRECORDSCOUNTRAW}|perl -lpe'$_ = reverse' |awk '{print $1}'|perl -lpe'$_ = reverse'|cut -f1 -d '.'`

  if [ ${AUDITRECORDSCOUNT} -gt 0 ]
   then
echo "AUDIT RECORDS DETECTED. SENDING AN EMAIL ALERT ..."
AUDITRECORDSLOG=/tmp/audit_records_report_${ORACLE_SID}.log
touch ${AUDITRECORDSLOG}

# HTML Preparation:
# #################
   case ${HTMLENABLE} in
   y|Y|yes|YES|Yes|ON|On|on)
        if [ -x /usr/sbin/sendmail ]
        then
export SENDMAIL="/usr/sbin/sendmail -t"
export MAILEXEC="echo #"
export HASHHTML=""
export HASHHTMLOS=""
export ENDHASHHTMLOS=""
export HASHNONHTML="--"
SENDMAILARGS=$(
echo "To:           ${EMAIL};"
echo "Subject:      ${MSGSUBJECT} ;"
echo "Content-Type: text/html;"
echo "MIME-Version: 1.0;"
cat ${AUDITRECORDSLOG}
)
export SENDMAILARGS
        else
export SENDMAIL="echo #"
export MAILEXEC="mail -s"
export HASHHTML="--"
export HASHHTMLOS="echo #"
export ENDHASHHTMLOS=""
export HASHNONHTML=""
        fi
   ;;
   *)
export SENDMAIL="echo #"
export HASHHTML="--"
export HASHHTMLOS="echo #"
export ENDHASHHTMLOS=""
export HASHNONHTML=""
export MAILEXEC="mail -s"
   ;;
   esac

AUDITRECORDSOUTPUT=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" << EOF
set pages 0 termout off echo off feedback off linesize ${SQLLINESIZE}
col name for A40
EXEC DBMS_SESSION.set_identifier('${SCRIPT_NAME}');

-- Enable HTML color format:
${HASHHTML} SET WRAP OFF ECHO OFF FEEDBACK OFF MARKUP HTML ON SPOOL ON HEAD '<title></title> <style type="text/css"> table { background: #E67E22; font-size: 80%; } th { background: #AF601A; } td { background: #E67E22; padding: 0px; } </style>' TABLE "border='1' bordercolor='#E67E22'" ENTMAP OFF

SPOOL ${AUDITRECORDSLOG}
prompt
${HASHHTML} SET PAGES 0
${HASHHTML} SET MARKUP HTML OFF SPOOL OFF
${HASHHTML} PROMPT <br> <p> <table border='3' bordercolor='#E67E22' width='20%' align='left' summary='Script output'> <tr> <th scope="col">
${HASHHTML} PROMPT Audit Records [Last ${MINUTES} Minutes]
${HASHHTML} PROMPT </td> </tr> </table> <p> <br>
${HASHHTML} SET WRAP OFF ECHO OFF FEEDBACK OFF MARKUP HTML ON SPOOL ON HEAD '<title></title> <style type="text/css"> table { background: #E67E22; font-size: 80%; } th { background: #AF601A; } td { background: #E67E22; padding: 0px; } </style>' TABLE "border='2' bordercolor='#E67E22'" ENTMAP OFF
${HASHHTML} set pages 1000

${HASHNONHTML} prompt ********************************** 

${HASHNONHTML} Prompt Audit Records [Last ${MINUTES} Minutes]
${HASHNONHTML} prompt ********************************** 

set feedback off linesize ${SQLLINESIZE} pages 1000 timing on
col OS_USERNAME FOR A15
col DB_USERNAME FOR A15
col DATE 	FOR A22
col OWNER 	FOR A15
col OBJ_NAME 	FOR A25
col USERHOST 	FOR A21
col ACTION_NAME FOR A20
col "ACTION_OWNER.OBJECT" FOR A80
col SQL_TEXT	FOR A100
-- Avoided using DBA_AUDIT_TRAIL view to not get the index on AUD\$(NTIMESTAMP#) ignored in the execution plan!
select to_char(a.NTIMESTAMP#,'DD-Mon-YYYY HH24:MI:SS')"DATE",a.spare1 OS_USERNAME, a.USERID DB_USERNAME, a.USERHOST, act.NAME||'  '||a.OBJ\$CREATOR||' . '||a.OBJ\$NAME "ACTION_OWNER.OBJECT", a.RETURNCODE, a.SQLTEXT
from aud\$ a, audit_actions act
where a.action#	= act.action (+)
and   a.ntimestamp# >= ${SYSDATE_PATTERN}
${HASHDBUSERNAME} and   lower (a.USERID) not in (${EXCLUDE_DBUSERS})
${HASHOSUSERNAME} and   lower (a.spare1) not in (${EXCLUDE_OSUSERS})
${HASHACTIONNAME} and   upper (act.NAME) not in (${EXCLUDE_ACTIONS})
order by a.ntimestamp#
/

PROMPT
${NOINDEXWARNING}
${NOINDEXWARNING1}
${NOINDEXWARNING2}
${NOINDEXWARNING3}

SPOOL OFF
exit;
EOF
)

export MSGSUBJECT="ALERT: AUDIT RECORDS DETECTED ON [ ${ORACLE_SID} ] ON [ ${SRV_NAME} ]"
echo ${MSGSUBJECT}

SENDMAILARGS=$(
echo "To:           ${EMAIL};"
echo "Subject:      ${MSGSUBJECT} ;"
echo "Content-Type: text/html;"
echo "MIME-Version: 1.0;"
cat ${AUDITRECORDSLOG}
)

${MAILEXEC} "${MSGSUBJECT}" ${MAIL_LIST} < ${AUDITRECORDSLOG}
echo ${SENDMAILARGS} | tr \; '\n' |awk 'length == 1 || NR == 1 {print $0} length && NR > 1 { print substr($0,2) }'| ${SENDMAIL}
        fi

echo "AUDIT RECORDS CHECK COMPLETED."
echo
		;;
		esac




done

# #############
# END OF SCRIPT
# #############
# REPORT BUGS to: mahmmoudadel@hotmail.com
# DOWNLOAD THE LATEST VERSION OF DATABASE ADMINISTRATION BUNDLE FROM:
# http://dba-tips.blogspot.com/2014/02/oracle-database-administration-scripts.html
# DISCLAIMER: THIS SCRIPT IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT WITHOUT ANY WARRANTY. IT IS PROVIDED "AS IS".

