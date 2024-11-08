#!/bin/bash
#
# check_database.sh - Script UOL que verifica se o banco esta operando normalmente.
# Criacao: Arthur E.F.Heinrich  13/07/2011
#
# Este script verifica se o banco de dados estáperando normalmente
# Parametros:
#
#   check_database.sh --oracle-sid <SID>
#
#    Parameter           Short Description                                                                 Default
#    ------------------- ----- --------------------------------------------------------------------------- -----------
#    --oracle-sid           -s OPTIONAL - In a multi-instance database, specify which one be used          $ORACLE_SID
#    --check-tns            -t OPTIONAL - Check TNSNAMES connections
#    --check-tns-only       -T OPTIONAL - Check only TNSNAMES and skip database verification
#    --protection           -p OPTIONAL - Check alternative PROTECTION_MODE/PROTECTION_LEVEL
#                                         Use "NOT CHECKED" to disable verification
#    --delay                -d OPTIONAL - Set the delay time between master and standby database.          300 seconds
#    --controlfile-delay    -c OPTIONAL - Set the delay time of controlfile and master database             15 minutes
#    --skip-mrp-check       -m OPTIONAL - Skip the mrp check process
#    --skip-achive-log      -a OPTIONAL - Skip archive log check
#    --scan-listener        -l OPTIONAL - Check connection through a scan listener <SCAN>:<Port>/<Service>
#
#   Ex.: check_database.sh
#        check_database.sh --oracle-sid emrep
#        check_database.sh -s uol7
#
# Alteracoes:
#
# Data       Autor               Descricao
# ---------- ------------------- ----------------------------------------------------
#
#====================================================================================

# Se houverem varias versoes de Oracle para as instancias, especificar na execucao
#if [ "${PROFILE}" = "" ]; then
#  PROFILE=".profile"
#fi

# Roda o .profile para setar variaveis do banco (necessario p/ rodar pelo cron)
#. ~/${PROFILE}

# Carrega a lib de monitoracao
#. ${LOAD_CLIENT_LIB} $0

# A versao do script precisa ser setada apos a carga da LIB para sobrepor a versao da LIB
SCRIPT_VERSION=20160118185750

MostraHelp()
{
  head -27 $0 | tail -26
  exit
}

# Tratamento dos Parametros
for arg
do
    delim=""
    case "$arg" in
    #translate --gnu-long-options to -g (short options)
      --oracle-sid)        args="${args}-s ";;
      --check-tns)         args="${args}-t ";;
      --check-tns-only)    args="${args}-T ";;
      --delay)             args="${args}-d ";;
      --controlfile-delay) args="${args}-c ";;
      --skip-mrp-check)    args="${args}-m ";;
      --skip-achive-log)   args="${args}-a ";;
      --help)              args="${args}-h ";;
      --protection)        args="${args}-p ";;
      --scan-listener)     args="${args}-l ";;
      #pass through anything else
      *) [[ "${arg:0:1}" == "-" ]] || delim="\""
         args="${args}${delim}${arg}${delim} ";;
    esac
done

eval set -- $args

CHECK_DB="Y"
PROTECTION="MAXIMUM PERFORMANCE"
DEFAULT_STANDBY_DELAY="300"
DEFAULT_CONTROLFILE_DELAY="15"
SKIP_MRP_CHECK="N"
SKIP_ARCHIVE_LOG="N"
MAX_STANDBY_RESTART_TIME="720"
MAX_STANDBY_APPLIED_TIME="1800"
SCAN_LISTENER=""

while getopts ":hb:s:tbTbp:d:mc:ac:l:" PARAMETRO
do
    case $PARAMETRO in
        h) MostraHelp;;
        s) ORACLE_SID=${OPTARG[@]};;
        t) CHECK_TNS="Y";;
        T) CHECK_DB="N"; CHECK_TNS="Y";;
        p) PROTECTION=${OPTARG[@]};;
        m) SKIP_MRP_CHECK="Y";;
        a) SKIP_ARCHIVE_LOG="Y";;
        l) SCAN_LISTENER="${OPTARG[@]}";;
        c) DEFAULT_CONTROLFILE_DELAY=${OPTARG[@]}; MAX_STANDBY_RESTART_TIME=${DEFAULT_CONTROLFILE_DELAY};;
        d) DEFAULT_STANDBY_DELAY=${OPTARG[@]}; MAX_STANDBY_APPLIED_TIME=${DEFAULT_STANDBY_DELAY};;
        :) echo "Option -$OPTARG requires an argument."; exit 1;;
        *) echo $OPTARG is an unrecognized option ; echo $USAGE; exit 1;;
    esac
done

PROTECTION_MODE_EXPECTED="`echo ${PROTECTION} | cut -d "/" -f1`"
PROTECTION_LEVEL_EXPECTED="`echo ${PROTECTION} | cut -d "/" -f2`"
if [ "${PROTECTION_LEVEL_EXPECTED}." == "." ] ; then
  PROTECTION_LEVEL_EXPECTED="${PROTECTION_MODE_EXPECTED}"
fi

sql()
{
  if [ "$1." != "." ] ; then
    SQLSTMT=$1
  fi
  sqlplus -s "/as sysdba" <<EOF
set pages 0
set define off;
set feedback off;
set lines 1000;
set trimout on;
${SQLSTMT}
EOF
}

sql_listner()
{
  if [ -f ${SCRIPTS_PATH}/conn_str.txt ] ; then
    CONN_STR=`cat ${SCRIPTS_PATH}/conn_str.txt`
  else
    CONN_STR=""
  fi
  if [ "${CONN_STR}." == "." ] ; then
    #CONN_STR="(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = lnxorasp-scan)(PORT = 1521))(CONNECT_DATA = (SID = ${ORACLE_SID})))"
    CONN_STR="(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.51.104)(PORT = 1521))(CONNECT_DATA = (SERVICE_NAME = pback)))"
  fi
  if [ "$1." != "." ] ; then
    SQLSTMT=$1
  fi
  sqlplus -s monitor/monitor@"${CONN_STR}" <<EOF
set pages 0
set define off;
set feedback off;
set lines 1000;
set trimout on;
${SQLSTMT}
EOF
}

sql_tns()
{
  if [ "$1." != "." ] ; then
    TNS=$1
    if [ "$2." != "." ] ; then
      SQLSTMT=$2
      sqlplus -s monitor/monitor@"${TNS}" <<EOF
set pages 0
set define off;
set feedback off;
set lines 1000;
set trimout on;
${SQLSTMT}
EOF
    fi
  fi
}

database_role()
{
  sql "select database_role from v\$database;"
}

check_glogin()
{
  RESULT=`sql "select 'OK' from dual;"`
  IDLE_INSTANCE=`echo ${RESULT} | grep -i "Connected to an idle instance."`
  if [ "${IDLE_INSTANCE}." == "." ] ; then
    IDLE_INSTANCE=`echo ${RESULT} | grep -i "ORA-01034: ORACLE not available"`
  fi
  if [ "${IDLE_INSTANCE}." == "." ] ; then
    IDLE_INSTANCE=`echo ${RESULT} | grep -i "ORA-01507: database not mounted"`
  fi
  if [ "${IDLE_INSTANCE}." != "." ] ; then
    echo "IDLE"
  else
    if [ "${RESULT}." == "OK." ] ; then
      echo "OK"
    else
      echo "NOK"
    fi
  fi
}

controlfile_delay()
{
 sql "select ltrim(trunc((sysdate - controlfile_time)*24*60)) from v\$database;"
}

mrp_process()
{
 sql "select ltrim(count(1)) from  gv\$managed_standby where process = 'MRP0';"
}

standby_delay()
{
 sql "select nvl((select ltrim(delay) from (select trunc((sysdate-last_time)*24*60*60) delay from v\$standby_log order by sequence# desc) where rownum <= 1),'NOK') from dual;"
}

open_mode()
{
  sql "select open_mode from v\$database;"
}

instance_status()
{
  sql "select status from v\$instance;"
}

instance_archiver()
{
  sql "select archiver from v\$instance;"
}

instance_logins()
{
  sql "select logins from v\$instance;"
}

instance_role()
{
  sql "select instance_role from v\$instance;"
}

instance_active_state()
{
  sql "select active_state from v\$instance;"
}

protection_mode()
{
  sql "select protection_mode from v\$database;"
}

protection_level()
{
  sql "select protection_level from v\$database;"
}

listner_up()
{
  sql_listner "select 'OK' from dual;"
}

scan_listner_up()
{
  if [ "${SCAN_LISTENER}." != "." ] ; then
    sql_tns "//${SCAN_LISTENER}" "select 'OK' from dual;"
  else
    echo "OK"
  fi
}

standby_redo_logs()
{
  sql "select to_char(count(1)) from v\$standby_log;"
}

standby_restart_time()
{
  sql "select to_char(trunc((sysdate-restart_time)*24*60,0)) from v\$logstdby_progress;"
}

standby_applied_time()
{
  sql "select to_char(trunc((sysdate-applied_time)*24*60*60,0)) from v\$logstdby_progress;"
}

redo_logs()
{
  PRIMARY_TNS=`sql "select value from v\\\$parameter where name = 'fal_server';"`
  PRIMARY_TNS=`echo ${PRIMARY_TNS} | cut -d "," -f1`
  sql_tns "${PRIMARY_TNS}" "select to_char(count(1)) from v\$log;"
}

split_mirror()
{
  SPLIT_CHECK_FILE="${SCRIPT_LOGDIR}/check_database_${ORACLE_SID}_split_mirror.log"
  SPLIT_ON_FILE="/export/logs/${ORACLE_SID}_split_on.tmp"

  if [ -e ${SPLIT_CHECK_FILE} ] ; then
    SPLIT_COUNT=`cat ${SPLIT_CHECK_FILE}`
    rm ${SPLIT_CHECK_FILE}
  else
    SPLIT_COUNT=0
  fi
  if [ -e ${SPLIT_ON_FILE} ] ; then
    SPLIT_COUNT=`expr "${SPLIT_COUNT} + 1"`
    echo ${SPLIT_COUNT} > ${SPLIT_CHECK_FILE}
    if [ ${SPLIT_COUNT} -ge 15 ] ; then
      echo "SPLIT ON AFTER ${SPLIT_COUNT} CHECKS!"
    else
      echo "ON"
    fi
  else
    echo "OFF"
  fi
}

open_call_body()
{
  echo "Caros, favor abrir incidente para a equipe adm portal bd com a seguinte categorizacao:

Category: infra-estrutura
Subcategory: banco de dados
Product Type: portal producao
Configuration Item: ${HOSTNAME}
Symptom: process check
Contact: Monitoramento de Banco de Dados Portal (l-tec-bancodedados@uolinc.com)
Primary Assign Group: adm portal bd
Assignee Name: Equipe de Banco de Dados (l-tec-bancodedados@uolinc.com)
Impact: 2 - Medium
Urgency: 2 - Medium


Description: O Banco de Dados nao esta operando corretamente!

"
  cat ${LOG_FILE}
}

echol()
{
  echo "$1"
  echo "$1" >> ${LOG_FILE}
}

echon()
{
  echo -n "$1"
  echo -n "$1" >> ${LOG_FILE}
}

cd ${SCRIPT_LOGDIR}
LOG_FILE=${SCRIPT_LOGDIR}/check_database_${ORACLE_SID}.log
> ${LOG_FILE}
EMAILS=`cat ${SCRIPTS_PATH}/../emails.txt`
SCRIPT_RESULT=""

echol "HOSTNAME: ${HOSTNAME}"
echol "INSTANCE: ${ORACLE_SID}"
echol ""

TIME_FILE=${SCRIPT_LOGDIR}/check_database_${ORACLE_SID}.time
CURR_DATE=`date "+%s"`

# Verificar se existe uma execução em andamento
QTDE=`ps -ef | grep -i "check_database.sh" | grep "/bin/bash" | grep ${ORACLE_SID} | grep -v "$$" | wc -l`
if [ ${QTDE} -gt 0 ] ; then

  # Verificar se o script em andamento esta travado
  if [ -a ${TIME_FILE} ] ; then
    LAST_DATE=`cat ${TIME_FILE}`
    if [ "${LAST_DATE}." == "." ] ; then
      echo ${CURR_DATE} > ${TIME_FILE}
    else
      ELAPSED_TIME=`expr ${CURR_DATE} - ${LAST_DATE}`
      if [ ${ELAPSED_TIME} -gt 600 ] ; then
        STATUS="E"
        MSG="ERROR: Script check_database.sh em execucao a mais de ${ELAPSED_TIME} segundos"
        echol "STATUS: ${STATUS} - MSG: ${MSG}"
        log oracle.check.database "${STATUS}" "${MSG}"
        exit
      fi
    fi
  else
    echo ${CURR_DATE} > ${TIME_FILE}
  fi
else
  echo ${CURR_DATE} > ${TIME_FILE}
fi

if [ "${CHECK_DB}." == "Y." ] ; then
  GLOGIN=`check_glogin`
  echol "GLOGIN: ${GLOGIN}"
  if [ "${GLOGIN}." == "NOK." ]; then
    STATUS="W"
    MSG="WARNING: Verifique GLOGIN para que 'SQLPLUS -S' retorne sem mensagens"
    echol "STATUS: ${STATUS} - MSG: ${MSG}"
    log oracle.check.database "${STATUS}" "${MSG}"
    exit
  fi

  CHECK_COUNT=3
  STATUS="E"

  while [ "${STATUS}" != "O" ] && [ ${CHECK_COUNT} -gt 0 ] ; do
    ((CHECK_COUNT--))

    SPLIT_MIRROR=`split_mirror`
    echol "SPLIT_MIRROR: ${SPLIT_MIRROR}"
    if [ "${SPLIT_MIRROR}." != "ON." ] ; then

      if [ "${GLOGIN}." == "IDLE." ]; then
        STATUS="E"
        MSG="ERROR: Instance Idle!"
        echol "STATUS: ${STATUS} - MSG: ${MSG}"
        open_call_body | mailx -s "Abertura de incidente: ${HOSTNAME}: ${MSG}" "${EMAILS}"
        log oracle.check.database "${STATUS}" "${MSG}"
        exit
      fi

      DATABASE_ROLE=`database_role`
      echol "DATABASE_ROLE: ${DATABASE_ROLE}"
      if [ "${DATABASE_ROLE}." == "PRIMARY." ] ; then
        OPEN_MODE=`open_mode`
        echol "OPEN_MODE: ${OPEN_MODE}"
        if [ "${OPEN_MODE}." == "READ WRITE." ] ; then
          INSTANCE_STATUS=`instance_status`
          echol "INSTANCE_STATUS: ${INSTANCE_STATUS}"
          if [ "${INSTANCE_STATUS}." == "OPEN." ] ; then
            INSTANCE_ARCHIVER=`instance_archiver`
            echol "INSTANCE_ARCHIVER: ${INSTANCE_ARCHIVER}"
            if [ "${SKIP_ARCHIVE_LOG}." == "N." ] ; then
              ARCHIVER_STATUS_EXPECTED="STARTED"
            else
              ARCHIVER_STATUS_EXPECTED="STOPPED"
            fi
            if [ "${INSTANCE_ARCHIVER}." == "${ARCHIVER_STATUS_EXPECTED}." ] ; then
              INSTANCE_LOGINS=`instance_logins`
              echol "INSTANCE_LOGINS: ${INSTANCE_LOGINS}"
              if [ "${INSTANCE_LOGINS}." == "ALLOWED." ] ; then
                INSTANCE_ROLE=`instance_role`
                echol "INSTANCE_ROLE: ${INSTANCE_ROLE}"
                if [ "${INSTANCE_ROLE}." == "PRIMARY_INSTANCE." ] ; then
                  INSTANCE_ACTIVE_STATE=`instance_active_state`
                  echol "INSTANCE_ACTIVE_STATE: ${INSTANCE_ACTIVE_STATE}"
                  if [ "${INSTANCE_ACTIVE_STATE}." == "NORMAL." ] ; then
                    LISTNER_UP=`listner_up`
                    echol "LISTNER_UP: ${LISTNER_UP}"
                    if [ "${LISTNER_UP}." == "OK." ] ; then
                      SCAN_LISTNER_UP=`scan_listner_up`
                      echol "SCAN_LISTNER_UP: ${SCAN_LISTNER_UP}"
                      if [ "${SCAN_LISTNER_UP}." == "OK." ] ; then
                        if [ "${PROTECTION}." == "NOT CHECKED." ] ; then
                          PROTECTION_MODE="${PROTECTION}"
                          PROTECTION_LEVEL="${PROTECTION}"
                        else
                          PROTECTION_MODE=`protection_mode`
                          PROTECTION_LEVEL=`protection_level`
                        fi
                        echol "PROTECTION_MODE=${PROTECTION_MODE}"
                        echol "PROTECTION_LEVEL=${PROTECTION_LEVEL}"
                        if [ "${PROTECTION_MODE}." == "${PROTECTION_MODE_EXPECTED}." ] &&
                           [ "${PROTECTION_LEVEL}." == "${PROTECTION_LEVEL_EXPECTED}." ] ; then
                          STATUS="O"
                          MSG="Primary Database OK - PROTECTION_MODE=${PROTECTION}"
                        else
                          STATUS="W"
                          MSG="Primary Database OK - PROTECTION_MODE=${PROTECTION_MODE} / PROTECTION_LEVEL=${PROTECTION_LEVEL} - Expected ${PROTECTION}"
                        fi
                      else
                        STATUS="E"
                        MSG="Scan listner connection not OK!"
                      fi
                    else
                      STATUS="E"
                      MSG="Listner connection not OK!"
                    fi
                  else
                    STATUS="E"
                    MSG="Instance Active State (${INSTANCE_ACTIVE_STATE}) diferente de NORMAL!"
                  fi
                else
                  STATUS="E"
                  MSG="Instance Role (${INSTANCE_ROLE}) diferente de PRIMARY_INSTANCE!"
                fi
              else
                STATUS="E"
                MSG="Instance Logins (${INSTANCE_LOGINS}) diferente de ALLOWED!"
              fi
            else
              STATUS="E"
              MSG="Instance Archiver (${INSTANCE_ARCHIVER}) diferente de STARTED!"
            fi
          else
            STATUS="E"
            MSG="Instance Status (${INSTANCE_STATUS}) diferente de OPEN!"
          fi
        else
          STATUS="E"
          MSG="Primary Database Open Mode (${OPEN_MODE}) nao esta aberto em modo READ WRITE!"
        fi
      elif [ "${DATABASE_ROLE}." == "LOGICAL STANDBY." ] ; then
        OPEN_MODE=`open_mode`
        echol "OPEN_MODE: ${OPEN_MODE}"
        if [ "${OPEN_MODE}." == "READ WRITE." ] ; then
          INSTANCE_STATUS=`instance_status`
          echol "INSTANCE_STATUS: ${INSTANCE_STATUS}"
          if [ "${INSTANCE_STATUS}." == "OPEN." ] ; then
            INSTANCE_ARCHIVER=`instance_archiver`
            echol "INSTANCE_ARCHIVER: ${INSTANCE_ARCHIVER}"
            if [ "${SKIP_ARCHIVE_LOG}." == "N." ] ; then
              ARCHIVER_STATUS_EXPECTED="STARTED"
            else
              ARCHIVER_STATUS_EXPECTED="STOPPED"
            fi
            if [ "${INSTANCE_ARCHIVER}." == "${ARCHIVER_STATUS_EXPECTED}." ] ; then
              INSTANCE_LOGINS=`instance_logins`
              echol "INSTANCE_LOGINS: ${INSTANCE_LOGINS}"
              if [ "${INSTANCE_LOGINS}." == "ALLOWED." ] ; then
                INSTANCE_ROLE=`instance_role`
                echol "INSTANCE_ROLE: ${INSTANCE_ROLE}"
                if [ "${INSTANCE_ROLE}." == "PRIMARY_INSTANCE." ] ; then
                  INSTANCE_ACTIVE_STATE=`instance_active_state`
                  echol "INSTANCE_ACTIVE_STATE: ${INSTANCE_ACTIVE_STATE}"
                  if [ "${INSTANCE_ACTIVE_STATE}." == "NORMAL." ] ; then
                    LISTNER_UP=`listner_up`
                    echol "LISTNER_UP: ${LISTNER_UP}"
                    if [ "${LISTNER_UP}." == "OK." ] ; then
                      STANDBY_RESTART_TIME=`standby_restart_time`
                      STANDBY_APPLIED_TIME=`standby_applied_time`
                      echol "STANDBY_RESTART_TIME=${STANDBY_RESTART_TIME} min"
                      echol "STANDBY_APPLIED_TIME=${STANDBY_APPLIED_TIME} sec"
                      if [ ${STANDBY_APPLIED_TIME} -le ${MAX_STANDBY_APPLIED_TIME} ] &&
                         [ ${STANDBY_RESTART_TIME} -le ${MAX_STANDBY_RESTART_TIME} ] ; then
                        if [ "${PROTECTION}." == "NOT CHECKED." ] ; then
                          PROTECTION_MODE="${PROTECTION}"
                          PROTECTION_LEVEL="${PROTECTION}"
                        else
                          PROTECTION_MODE=`protection_mode`
                          PROTECTION_LEVEL=`protection_level`
                        fi
                        echol "PROTECTION_MODE=${PROTECTION_MODE}"
                        echol "PROTECTION_LEVEL=${PROTECTION_LEVEL}"
                        if [ "${PROTECTION_MODE}." == "${PROTECTION_MODE_EXPECTED}." ] &&
                           [ "${PROTECTION_LEVEL}." == "${PROTECTION_LEVEL_EXPECTED}." ] ; then
                          STATUS="O"
                          MSG="Primary Database OK - PROTECTION_MODE=${PROTECTION}"
                        else
                          STATUS="W"
                          MSG="Primary Database OK - PROTECTION_MODE=${PROTECTION_MODE} / PROTECTION_LEVEL=${PROTECTION_LEVEL} - Expected ${PROTECTION}"
                        fi
                      else
                        STATUS="E"
                        MSG="Logical Standby Database synchronization is ${STANDBY_APPLIED_TIME} seconds late! Restart time ${STANDBY_RESTART_TIME} minutes!"
                      fi
                    else
                      STATUS="E"
                      MSG="Listner connection not OK!"
                    fi
                  else
                    STATUS="E"
                    MSG="Instance Active State (${INSTANCE_ACTIVE_STATE}) diferente de NORMAL!"
                  fi
                else
                  STATUS="E"
                  MSG="Instance Role (${INSTANCE_ROLE}) diferente de PRIMARY_INSTANCE!"
                fi
              else
                STATUS="E"
                MSG="Instance Logins (${INSTANCE_LOGINS}) diferente de ALLOWED!"
              fi
            else
              STATUS="E"
              MSG="Instance Archiver (${INSTANCE_ARCHIVER}) diferente de STARTED!"
            fi
          else
            STATUS="E"
            MSG="Instance Status (${INSTANCE_STATUS}) diferente de OPEN!"
          fi
        else
          STATUS="E"
          MSG="Primary Database Open Mode (${OPEN_MODE}) nao esta aberto em modo READ WRITE!"
        fi
      elif [ "${DATABASE_ROLE}." == "PHYSICAL STANDBY." ] ; then
        OPEN_MODE=`open_mode`
        echol "OPEN_MODE: ${OPEN_MODE}"
        if [ "${OPEN_MODE}." == "MOUNTED." ] ; then
          INSTANCE_STATUS=`instance_status`
          echol "INSTANCE_STATUS: ${INSTANCE_STATUS}"
          if [ "${INSTANCE_STATUS}." == "MOUNTED." ] ; then
            INSTANCE_ARCHIVER=`instance_archiver`
            echol "INSTANCE_ARCHIVER: ${INSTANCE_ARCHIVER}"
            if [ "${SKIP_ARCHIVE_LOG}." == "N." ] ; then
              ARCHIVER_STATUS_EXPECTED="STARTED"
            else
              ARCHIVER_STATUS_EXPECTED="STOPPED"
            fi
            if [ "${INSTANCE_ARCHIVER}." == "${ARCHIVER_STATUS_EXPECTED}." ] ; then
              INSTANCE_LOGINS=`instance_logins`
              echol "INSTANCE_LOGINS: ${INSTANCE_LOGINS}"
              if [ "${INSTANCE_LOGINS}." == "ALLOWED." ] ; then
                INSTANCE_ROLE=`instance_role`
                echol "INSTANCE_ROLE: ${INSTANCE_ROLE}"
                if [ "${INSTANCE_ROLE}." == "PRIMARY_INSTANCE." ] ; then
                  INSTANCE_ACTIVE_STATE=`instance_active_state`
                  echol "INSTANCE_ACTIVE_STATE: ${INSTANCE_ACTIVE_STATE}"
                  if [ "${INSTANCE_ACTIVE_STATE}." == "NORMAL." ] ; then
                    MRP=`mrp_process`
                    echol "MRP PROCESS: ${MRP}"
                    if [ "${MRP}." != "0." ] || [ "${SKIP_MRP_CHECK}." == "Y." ] ; then
                      if [ "${DEFAULT_STANDBY_DELAY}." == "DISABLE." ] ; then
                        STANDBY_DELAY="0"
                        DEFAULT_STANDBY_DELAY="1"
                        echol "STANDBY_DELAY: DISABLED"
                      else
                        STANDBY_DELAY=`standby_delay`
                        echol "STANDBY_DELAY: ${STANDBY_DELAY} seconds"
                      fi
                      MSG="Standby Database synchronization is ${STANDBY_DELAY} seconds late!"
                      if [ "${STANDBY_DELAY}." == "NOK." ] ; then
                        CONTROLFILE_DELAY=`controlfile_delay`
                        echol "CONTROLFILE_DELAY: ${CONTROLFILE_DELAY} min"
                        STANDBY_DELAY="${CONTROLFILE_DELAY}"
                        DEFAULT_STANDBY_DELAY="${DEFAULT_CONTROLFILE_DELAY}"
                        MSG="Standby Database synchronization is ${STANDBY_DELAY} minutes late!"
                      fi
                      if [ ${STANDBY_DELAY} -le ${DEFAULT_STANDBY_DELAY} ] ; then
                        PROTECTION_MODE=`protection_mode`
                        PROTECTION_LEVEL=`protection_level`
                        echol "PROTECTION_MODE: ${PROTECTION_MODE}"
                        echol "PROTECTION_LEVEL: ${PROTECTION_LEVEL}"
                        if [ "${PROTECTION_MODE}." == "${PROTECTION_MODE_EXPECTED}." ] &&
                           [ "${PROTECTION_LEVEL}." == "${PROTECTION_LEVEL_EXPECTED}." ] ; then
                          if [ "${SKIP_MRP_CHECK}." != "Y." ] ; then
                            STANDBY_REDO_LOGS=`standby_redo_logs`
                            REDO_LOGS=`redo_logs`
                            echol "REDO LOGS: ${REDO_LOGS} / STANDBY REDO LOGS: ${STANDBY_REDO_LOGS}"
                            STANDARD_RECOVER=""
                          else
                            STANDBY_REDO_LOGS=1;
                            REDO_LOGS=0;
                            echol "REDO Log check skipped due to Standard Recovery"
                            STANDARD_RECOVER=" Standard Recovery"
                          fi
                          if [ ${REDO_LOGS} -lt ${STANDBY_REDO_LOGS} ] ; then
                            STATUS="O"
                            MSG="Standby Database OK - PROTECTION_MODE=${PROTECTION}${STANDARD_RECOVER}"
                          else
                            STATUS="W"
                            MSG="Standby Database need more standby redo logs: REDO LOGS: ${REDO_LOGS} / STANDBY REDO LOGS: ${STANDBY_REDO_LOGS}"
                          fi
                        else
                          CONTROLFILE_DELAY=`controlfile_delay`
                          echol "CONTROLFILE_DELAY: ${CONTROLFILE_DELAY} min"
                          if [ ${CONTROLFILE_DELAY} -le ${DEFAULT_CONTROLFILE_DELAY} ] ; then
                            STATUS="W"
                            MSG="Standby Database OK - PROTECTION_MODE=${PROTECTION_MODE} / PROTECTION_LEVEL=${PROTECTION_LEVEL} - Expected ${PROTECTION}"
                          else
                            STATUS="E"
                            MSG="Standby Database NOK - PROTECTION_MODE=${PROTECTION_MODE} / PROTECTION_LEVEL=${PROTECTION_LEVEL} - ${CONTROLFILE_DELAY} minutes late!"
                          fi
                        fi
                      else
                        STATUS="E"
                      fi
                    else
                      STATUS="E"
                      MSG="MRP0 process is down!"
                    fi
                  else
                    STATUS="E"
                    MSG="Instance Active State (${INSTANCE_ACTIVE_STATE}) diferente de NORMAL!"
                  fi
                else
                  STATUS="E"
                  MSG="Instance Role (${INSTANCE_ROLE}) diferente de PRIMARY_INSTANCE!"
                fi
              else
                STATUS="E"
                MSG="Instance Logins (${INSTANCE_LOGINS}) diferente de ALLOWED!"
              fi
            else
              STATUS="E"
              MSG="Instance Archiver (${INSTANCE_ARCHIVER}) diferente de STARTED!"
            fi
          else
            STATUS="E"
            MSG="Instance Status (${INSTANCE_STATUS}) diferente de OPEN!"
          fi
        else
          STATUS="E"
          MSG="Standby Database Open Mode (${OPEN_MODE}) nao esta em modo MOUNTED!"
        fi
      else
        STATUS="E"
        MSG="Database Role (${DATABASE_ROLE}) diferente de PRIMARY ou PHYSICAL STANDBY!"
      fi
    else
      STATUS="O"
      MSG="Standby Database OK - Split Mirror ON"
    fi
    if [ "${STATUS}." == "E." ] && [ ${CHECK_COUNT} -gt 0 ] ; then
      echol "Aguardando 3 segundos para uma nova verificacao. Numero de tentativas restantes: ${CHECK_COUNT}"
      sleep 3
    fi
  done

  SCRIPT_RESULT=""

  #SCRIPT_RESULT=`sql "select display_value from v\\\$parameter where name = 'control_file_record_keep_time';"`
  #if [ "${SCRIPT_RESULT}." != "7." ] ; then
  #  SCRIPT_RESULT=". control_file_record_keep_time = ${SCRIPT_RESULT}. altered to 7 days!"
  #  sql "alter system set control_file_record_keep_time=7 scope=both;"
  #else
  #  SCRIPT_RESULT=". control_file_record_keep_time = ${SCRIPT_RESULT}."
  #fi

  MSG="${MSG}${SCRIPT_RESULT}"

  echol "STATUS: ${STATUS} - MSG: ${MSG}"

  if [ "${STATUS}." == "E." ] ; then
    open_call_body | mailx -s "Abertura de incidente: ${HOSTNAME} (${ORACLE_SID}): ${MSG}" "${EMAILS}"
  fi
  log oracle.check.database "${STATUS}" "${MSG}"
fi

# Checa TNSNAMES a cada 12 horas
if [ "`date \"+%I%M\"`" == "0800" ] ; then
  CHECK_TNS="Y"
fi

if [ "${CHECK_TNS}." == "Y." ] ; then
  TNSNAMES=${ORACLE_HOME}/network/admin/tnsnames.ora
  ERRORS=""
  echol "Checking TNS entries:"
  for TNS in `egrep '^\w.*' ${TNSNAMES} | sed 's/=//g'`
  do
    if [ "${TNS}." == "${HOSTNAME}." ] ; then
      DATABASE_ROLE=`database_role`
      if [ "${DATABASE_ROLE}." != "PRIMARY." ] ; then
        TNS=""
      fi
    fi
    if [ "${TNS}." != "." ] ; then
      echon "  ${TNS} "
      RESULT=`sql_tns ${TNS} "select 'OK' from dual;"`
      if [ "${RESULT}." != "OK." ] ; then
        echol "NOK"
        ERRORS="${ERRORS} ${TNS}"
      else
        echol "OK"
      fi
    fi
  done
  if [ "${ERRORS}." == "." ] ; then
    echol "TNSNAMES: OK"
    STATUS="O"
    MSG="Primary Database OK"
  else
    STATUS="W"
    MSG="TNSNAMES NOT OK: ${ERRORS}"
  fi
  echol "STATUS: ${STATUS} - MSG: ${MSG}"
  log oracle.check.tnsnames "${STATUS}" "${MSG}"
fi
