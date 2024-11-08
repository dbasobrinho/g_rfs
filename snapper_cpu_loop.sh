#!/bin/bash
#============================================================================================================
#Referencia : snapper_cpu_loop.sh
#Assunto    : Iniciar snapper CPU em Loop
#Criado por : Roberto Fernandes Sobrinho
#Data       : 25/11/2020
#Ref        :
#Alteracoes :
#           :
#============================================================================================================
export TEMP=/tmp
export TMPDIR=/tmp
export ORACLE_SID=pback1
export ORACLE_BASE=/u/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export PATH=$ORACLE_HOME/bin:$PATH:/usr/bin:/usr/ccs/bin:/usr/local/
export ORACLE_OWNER=oracle
export DATA=`date '+%d'`
find $ORACLE_BASE/TVTDBA/MONI/logs_snapper -name '*snapper*.log' -mtime +10 -exec rm -r {} \;
if [ "$(date +%d)" == 31 ]; then :> /tmp/.CPU_STATISTICS.log; fi; 
while [ $DATA -eq `date '+%d'` ]
do
  sh $ORACLE_BASE/TVTDBA/MONI/snapper_cpu.sh
  sleep 10
done
