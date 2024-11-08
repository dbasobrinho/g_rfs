#===========================================================================================================
#Referencia : kill_auto_by_sqlid.sh
#Assunto    : KILL AUTOMATICO
#Criado por : Roberto Fernandes Sobrinho
#Data       : 06/04/2020 >> De Quarentena
#Ref        :
#Alteracoes : 05/05/2020  Roberto Fernandes Sobrinho V2.0[CENTRALIZAR TABELA:tvtspi.tbl_auto_kill_cron]
#           :
#============================================================================================================
export dt=`date +%Y%m%d%H%M%S`
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
for instance in `ps -ef | grep pmon | grep -v grep | grep -iv asm |egrep 'pback|PRDPPGBK' | awk '{print$'NF'}' | cut -d '_' -f3`
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
cd $ORACLE_BASE/TVTDBA/AUTO
export DATA=`date +%Y%m%d%H%M%S`
mkdir -p ./logs/${HOSTN}
export LOG=./logs/${HOSTN}/${DATA}_CRON_kill_auto_${instance}.log
touch $LOG
export DTC=`date +%d/%b/%Y_%k:%M:%S`
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " INICIO DA EXECUCAO            . : "$instance                              2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " DATA HRS: . . . . . . . . . . . : "$DTC                                    2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
ORACLE_HOME=$HO; export ORACLE_HOME
ORACLE_SID=$instance; export ORACLE_SID
while true;do
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
variable v_start number
exec :v_start := dbms_utility.get_time;
------>>>>>@growth_install.sql
@kill_auto_by_sqlid.sql $1
COLUMN PSEG NEW_VALUE PSEG NOPRINT;
select round((dbms_utility.get_time - :v_start )/100,2) PSEG from  dual;
PROMPT +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROMPT EXECUCAO REALIZADA COM SUCESSO
PROMPT TEMPO (s) : &PSEG
PROMPT +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
exit
EOF
sleep 5
done
export DTC=`date +%d/%b/%Y_%k:%M:%S`
echo "  "                                                                         2>&1 |tee -a $LOG
echo "  "                                                                         2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " FIM DA EXECUCAO               . : "$instance                               2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " DATA HRS: . . . . . . . . . . . : "$DTC                                    2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " +-+-+-+                    +-+ +-+-+-+ +-+ +-+ +-+ +-+-+-+-+-+-+-+-+-+-+ " 2>&1 |tee -a $LOG
echo " |F|I|M|                    |E| |Z|A|S| |.| |.| |.| |R|F|S|O|B|R|I|N|H|O| " 2>&1 |tee -a $LOG
echo " +-+-+-+                    +-+ +-+-+-+ +-+ +-+ +-+ +-+-+-+-+-+-+-+-+-+-+ " 2>&1 |tee -a $LOG
echo ""                                                                           2>&1 |tee -a $LOG
done
