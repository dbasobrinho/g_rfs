#============================================================================================================
#Referencia : snapper_instance_loop.sh
#Assunto    : Execuxao snapper em todas as intancias do servidor
#Criado por : Roberto Fernandes Sobrinho
#Data       : 06/11/2020
#Ref        : https://tanelpoder.com/snapper/
#Alteracoes :
#           :
#============================================================================================================
#####while [ $DATA -eq `date '+%d'` ]
#####do
export dt=`date +%y%m%d%H%M%S`
##DESCOBRINHO 0 SSISTEMA OPERACIONAL
HOSTN=$(hostname)
HOSTN=`echo ${HOSTN} | tr '[a-z]' '[A-Z]'`
OS="`uname`"
OS=`echo ${OS} | tr '[a-z]' '[A-Z]'`
if [  "${OS}" == LINUX ]; then
#!/bin/bash
. ~/.bash_profile > /dev/null
else
#!/usr/bin/ksh
. ~/.profile > /dev/null
fi
#########################
for instance in `ps -ef | grep pmon | grep -v grep | grep -iv asm |grep $1 | awk '{print$'NF'}' | cut -d '_' -f3`
###for instance in `ps -ef | grep pmon | grep -v grep | grep -iv asm | awk '{print$'NF'}' | cut -d '_' -f3`
do
IDP=`ps -ef | grep pmon | grep -v grep | grep pmon_${instance} | awk '{print$'2'}'`
if [  "${OS}" == LINUX ]; then
HO=`sudo pwdx ${IDP} |awk -F ":" '{print $NF}' `
HO=`echo "$HO" | rev | cut -c5- | rev`
elif [  "${OS}" == SUNOS ]; then
HO=`pwdx ${IDP}`
HO=`echo "$HO" | awk '{print$'NF'}'`
HO=`echo $HO | sed 's/[/]dbs//g'`
else
HO=`ls -l /proc/${IDP}/cwd |awk -F " " '{print $NF}'`
HO=`echo "$HO" | rev | cut -c6- | rev`
fi
HO=`echo $HO |sed 's/ /\(&\)/'`
##
cd $ORACLE_BASE/TVTDBA/MONI
####export DATA=`date +%y%m%d%H%M%S`
export DATA=`date +%Y%m%d%H`
##mkdir -p ./logs_snapper/
###export LOG=./logs/${HOSTN}/${DATA}_snapper_${instance}.log
export LOG=./logs_snapper/${DATA}_snapper_${instance}.log
##export LOG=/backup2/snapper_instance/${DATA}_snapper_${instance}.log
####touch $LOG
export DTC=`date +%d/%b/%Y_%k:%M:%S`
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " INICIO SNAPPER INSTANCE . . . . : "$instance                               2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " DATA HRS: . . . . . . . . . . . : "$DTC                                    2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
ORACLE_HOME=$HO; export ORACLE_HOME
ORACLE_SID=$instance; export ORACLE_SID
$ORACLE_HOME/bin/sqlplus -S /  as sysdba <<EOF
SET heading     ON
SET newpage     NONE
SET define      ON;
SET ECHO        OFF;
SET VERIFY      OFF;
SET FEEDBACK    OFF;
SET TIMING      OFF;
set LINES       1000;
set PAGES       500;
set colsep     '|'
set trimspool  ON
set headsep    OFF
ALTER SESSION ENABLE PARALLEL DDL;
ALTER SESSION SET NLS_DATE_FORMAT                 = 'DD/MM/YYYY HH24:MI:SS';
begin execute immediate 'ALTER SESSION SET DDL_LOCK_TIMEOUT=300'; exception when others then null; end;
/
begin execute immediate 'ALTER SESSION SET DB_FILE_MULTIBLOCK_READ_COUNT=128'; exception when others then null; end;
/
begin execute immediate 'ALTER SESSION SET COMMIT_LOGGING=BATCH'; exception when others then null; end;
/
begin execute immediate 'ALTER SESSION SET COMMIT_WAIT=NOWAIT'; exception when others then null; end;
/
begin execute immediate 'ALTER SESSION SET "_OPTIMIZER_JOIN_FACTORIZATION"=FALSE'; exception when others then null; end;
/
spool ${LOG} APPEND
--variable v_start number
--exec :v_start := dbms_utility.get_time;
@snapper_instance.sql ash=inst_id+sql_id+event+wait_class+blocking_session 10 06 "select inst_id,sid from gv\$session where status = 'ACTIVE' and type = 'USER' and sql_id = sql_id"
@snapper_s.sql
----->>> COLUMN PSEG NEW_VALUE PSEG NOPRINT;
----->>> select round((dbms_utility.get_time - :v_start )/100,2) PSEG from  dual;
----->>> PROMPT +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
----->>> PROMPT OI BUM BUM
----->>> PROMPT TEMPO (s) : &PSEG
----->>> PROMPT +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
exit
EOF
export DTC=`date +%d/%b/%Y_%k:%M:%S`
echo "  "                                                                         2>&1 |tee -a $LOG
echo "  "                                                                         2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " FIM SNAPPER INSTANCE  . . . . . : "$instance                               2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " DATA HRS: . . . . . . . . . . . : "$DTC                                    2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " +-+-+-+                    +-+ +-+-+-+ +-+ +-+ +-+ +-+-+-+-+-+-+-+-+-+-+ " 2>&1 |tee -a $LOG
echo " |F|I|M|                    |E| |Z|A|S| |.| |.| |.| |R|F|S|O|B|R|I|N|H|O| " 2>&1 |tee -a $LOG
echo " +-+-+-+                    +-+ +-+-+-+ +-+ +-+ +-+ +-+-+-+-+-+-+-+-+-+-+ " 2>&1 |tee -a $LOG
echo ""                                                                           2>&1 |tee -a $LOG
done
####sleep 5
####done

