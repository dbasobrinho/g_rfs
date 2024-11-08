#!/bin/bash
#============================================================================================================
#Referencia : snapper_instance_loop.sh
#Assunto    : Iniciar snapper em Loop
#Criado por : Roberto Fernandes Sobrinho
#Data       : 06/11/2020
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
while [ $DATA -eq `date '+%d'` ]
do
  sh $ORACLE_BASE/TVTDBA/MONI/snapper_instance.sh $1
  sleep 10
#echo 'O GUINA NAO TINHA DO'
done

##  20 11 * * * sh /u/app/oracle/TVTDBA/MONI/snapper_instance_loop.sh pback     > /dev/null 2>&1
##  20 11 * * * sh /u/app/oracle/TVTDBA/MONI/snapper_instance_loop.sh PRDPPGBK  > /dev/null 2>&1
