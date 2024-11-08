#!/bin/bash
# Scripts para descobrir quais discos tem Header ASM possiveis problemas do disco ASM
# 


echo '' > /tmp/lista_discos ; rm /tmp/lista_discos ; touch /tmp/lista_discos ; chmod 777 /tmp/lista_discos
echo '' > /tmp/asmdisks.txt ; rm /tmp/asmdisks.txt ; touch /tmp/asmdisks.txt ; chmod 777 /tmp/asmdisks.txt

echo "Plataforma: " $(uname)
echo ''

if [ $(uname) = 'SunOS' ] ; then
        if [ -e /var/opt/oracle/oratab ] ; then
                export ORACLE_HOME=$(cat /var/opt/oracle/oratab | grep -i ":/" | grep -i asm | awk -F":" {'print$2'} | uniq)
        export PATH=$ORACLE_HOME/bin:$PATH
        else
                export KFOD=$(find /u01/app -name kfod | egrep -iv "/ext/"  | head -1)
                export KFED=$(echo $KFOD | awk -F'/' '{for (i=1; i<NF; i++) printf("%s/", $i)}' ; echo 'kfed')
                export ORACLE_HOME=$(echo $(echo $KFOD | awk -F'/' '{for (i=1; i<NF-1; i++) printf("%s/", $i)}') | sed 's/.$//')
                export PATH=$ORACLE_HOME/bin:$PATH
        fi
fi

if [ $(uname) = 'AIX' -o $(uname) = 'Linux' ] ; then
        if [ -e /etc/oratab ] ; then
                export ORACLE_HOME=$(cat /etc/oratab | grep -i ":/" | grep -i asm | awk -F":" {'print$2'} | uniq)
        export PATH=$ORACLE_HOME/bin:$PATH
        else
                export KFOD=$(find /u01/app -name kfod | egrep -iv "/ext/"  | head -1)
                export KFED=$(echo $KFOD | awk -F'/' '{for (i=1; i<NF; i++) printf("%s/", $i)}' ; echo 'kfed')
                export ORACLE_HOME=$(echo $(echo $KFOD | awk -F'/' '{for (i=1; i<NF-1; i++) printf("%s/", $i)}') | sed 's/.$//')
                export PATH=$ORACLE_HOME/bin:$PATH
        fi
fi

$ORACLE_HOME/bin/kfod disks=asm | awk -F" " {'print$4'} |  grep -i dev > /tmp/lista_discos


for a in $(cat /tmp/lista_discos) ; do
DG_NAME=$(kfed read dev=$a | grep -i kfdhdb.grpname | awk '{print $2}')

if [ "${DG_NAME}." != "." ] ; then

VFEND=$($ORACLE_HOME/bin/kfed read dev=$a | egrep  -i "kfdhdb.vfend" | awk '{print $2}')
VFSTART=$($ORACLE_HOME/bin/kfed read dev=$a | egrep  -i "kfdhdb.vfstart" | awk '{print $2}' )
VFFINAL="$(echo "$VFEND-$VFSTART"|bc)"

case $VFFINAL in

              0) VT_DISK='###########';;
                     ''|*[!1-99]*) "Algo errado com header.";;
              *) VT_DISK='Voting-Disk';;
esac

ASMNAME=$($ORACLE_HOME/bin/kfed read dev=$a | egrep  -i "kfdhdb.dskname" | awk '{print $2}' )
export PERMISSAO=$(perl -le '@pv=stat("$ENV{a}"); printf "%04o", $pv[2] & 07777;' ; echo '')
OWNER_DISK=$(ls -la $a | awk -F" " {'print$3":"$4'} )

echo $DG_NAME   $ASMNAME  $VT_DISK $a $OWNER_DISK $PERMISSAO >> /tmp/asmdisks.txt

  fi
done

echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "||      GRUPO ASM         ||            DISCO ASM             ||     VOTING DISK     ||              DISCO S.O               ||       OWNER      ||     PERMISSAO     ||"
echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
cat /tmp/asmdisks.txt  |  sort  | xargs printf "||  %-21s || %-32s || %-19s || %-36s || %-16s || %-17s ||\n"
echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------"


