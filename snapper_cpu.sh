#============================================================================================================
#Referencia : snapper_cpu.sh
#Assunto    : Execuxao snapper CPU do servidor
#Criado por : Roberto Fernandes Sobrinho
#Data       : 06/11/2020
#Ref        : http://bdrouvot.wordpress.com/  >> Bertrand Drouvot
#Alteracoes :
#           :
#============================================================================================================
export dt=`date +%y%m%d%H%M%S`
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
##
cd $ORACLE_BASE/TVTDBA/MONI
####export DATA=`date +%y%m%d%H%M%S`
export DATA=`date +%Y%m%d%H`
export LOG=./logs_snapper/${DATA}_snapper_cpu_${HOSTN}.log
export DTC=`date +%d/%b/%Y_%k:%M:%S`
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " CPU STAT: . . . . . . . . . . . : "$DTC                                    2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
sh snapper_cpu_stats.sh >> $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " INICIO SNAPPER CPU  . . . . . . : "$HOSTN                                  2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " DATA HRS: . . . . . . . . . . . : "$DTC                                    2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
perl snapper_cpu.pl 10 06 displayuser=Y displaycmd=Y top=20 >> $LOG
export DTC=`date +%d/%b/%Y_%k:%M:%S`
echo "  "                                                                         2>&1 |tee -a $LOG
echo "  "                                                                         2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " FIM SNAPPER CPU . . . . . . . . : "$HOSTN                                  2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " DATA HRS: . . . . . . . . . . . : "$DTC                                    2>&1 |tee -a $LOG
echo "==========================================================================" 2>&1 |tee -a $LOG
echo " +-+-+-+                    +-+ +-+-+-+ +-+ +-+ +-+ +-+-+-+-+-+-+-+-+-+-+ " 2>&1 |tee -a $LOG
echo " |F|I|M|                    |E| |Z|A|S| |.| |.| |.| |R|F|S|O|B|R|I|N|H|O| " 2>&1 |tee -a $LOG
echo " +-+-+-+                    +-+ +-+-+-+ +-+ +-+ +-+ +-+-+-+-+-+-+-+-+-+-+ " 2>&1 |tee -a $LOG
echo ""                                                                           2>&1 |tee -a $LOG
