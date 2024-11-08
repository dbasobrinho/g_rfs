#!/bin/bash
#
# Author: Cid Melges Molina
# Date: 2015-08-12
# What it does: Try to best match the memory parameters to Oracle Database
# 
# OBS: To work properly, install this packages:
#	- bc.x86_64 : GNU's bc (a numeric processing language) and dc (a calculator)
#
#
# 27/12/2016 Tunning Parameters  - Matsuo Furushima
# 05/03/2017 Verificar instancias e calcula de acordo quantidade - Matsuo Furushima
# 31/05/2017 Adicionado plataforma AIX - Matsuo Furushima
#########################################################################


# Variaveis de ambiente apenas para Linux #
environment_linux () {
#########################################################################
# Variables
#########################################################################
PROCESSES=`sql "select LIMIT_VALUE from v\\\$resource_limit where RESOURCE_NAME = 'processes';"`
SEMMNI=`cat /proc/sys/kernel/sem | awk '{print $4}'`
SEMMSL=$((${PROCESSES}+10))
SEMMNS=$((${SEMMSL}*SEMMNI))
SEMOPM=${SEMMSL}
SEM=`cat /proc/sys/kernel/sem`
SHMMAX=`cat /proc/sys/kernel/shmmax`
SHMALL=`cat /proc/sys/kernel/shmall`
SHMMNI=`cat /proc/sys/kernel/shmmni`
NR_HUGEPAGES=`cat /proc/sys/vm/nr_hugepages`
ORACLE_SOFT_MEMLOCK=`ulimit -Sl`
ORACLE_HARD_MEMLOCK=`ulimit -Hl`
ORACLE_SOFT_NOFILE=`ulimit -Sn`
ORACLE_HARD_NOFILE=`ulimit -Hn`
ORACLE_SOFT_NPROC=`ulimit -Su`
ORACLE_HARD_NPROC=`ulimit -Hu`
ORACLE_SOFT_STACK=`ulimit -Ss`
ORACLE_HARD_STACK=`ulimit -Hs`
mem=$(free|grep Mem|awk '{print$2}')
totmem=$(echo "$mem*1024"|bc)
huge=$(grep Hugepagesize /proc/meminfo|awk '{print $2}')
max=$(echo "$totmem*75/100"|bc)
all=$(echo "$max/$huge"|bc)
TOTAL_MEMORY=`free -m | grep "Mem:" | awk '{ print $2 }'`
ACTSWAP=`cat /proc/sys/vm/swappiness`

#########################################################################
### Limits + HUGEPAGES
#########################################################################
KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`
HPG_SZ=`grep Hugepagesize /proc/meminfo | awk {'print $2'}`
NUM_PG=1
for SEG_BYTES in `ipcs -m | awk {'print $5'} | grep "[0-9][0-9]*"`
do
   MIN_PG=`echo "$SEG_BYTES/($HPG_SZ*1024)" | bc -q`
   if [ $MIN_PG -gt 0 ]; then
      NUM_PG=`echo "$NUM_PG+$MIN_PG+1" | bc -q`
   fi
done

T_HP=$NUM_PG
S_HP=$(grep Huge /proc/meminfo | grep -i Hugepagesize | awk -F" " {'print$2'})
LIMITS=$(expr $T_HP \* $S_HP)

##################################################################################
### IO DEVICES PARAMETERS
##################################################################################
IO_DEVICES=`ls /sys/block/ | grep -i sd`
}


# Pre Requisitos para o Script Rodar #
pre_check () {
#####################################
## Verificar Plataforma e Hardware ##
#####################################

    platform=`uname -s`
    case "$platform"
    in
    #   "SunOS")  os=solaris;; Ainda nao suportado
       "Linux")  os=Linux; TOTAL_MEMORY=`free -k | grep "Mem:" | awk '{ print $2 }'`; BC=`rpm -qa |grep "bc-" |grep -v glibc`;;
    #   "HP-UX")  os=hpunix;; Ainda nao suportado
         "AIX")  os=AIX; TOTAL_MEMORY=`lsattr -El sys0 -a realmem | awk {'print $2'}`; BC=`which bc`;;
             *)  echo "$platform nao suportardo." 
                 exit 1;;
    esac
 
 
    echo ""
	echo ""
	export $os
	export TOTAL_MEMORY_MB=$(echo "$TOTAL_MEMORY/1024"|bc)
	echo  "Plataforma: $os"		
	echo  "Memoria Total: $TOTAL_MEMORY_MB MB."	



#########################################################
### Verifica se o usuario e Owner do banco ORACLE     ###
#########################################################

OWNER_DB=`ps -ef | grep -i pmon |  grep -v +ASM | awk '{print $1}' | uniq`
ACTUAL_USER=`whoami`


if [ "$ACTUAL_USER" != "$OWNER_DB" ];
        then
		        echo ""
                echo  "Conectar com o usuario $OWNER_DB!";
                echo  "Usuario Atual: $ACTUAL_USER"
                echo  ""
                echo  ""
                exit;
		else
		echo "Usuario Atual: $ACTUAL_USER"		
fi

############################################
### Verifica se o utilario BC existe     ###
############################################

 
if [ "$BC" == "" ];
        then
		        echo ""
                echo  "\e[93m Por favor, installe bc.x86_64!\e[39m";
                echo  "\e[93mGNU's bc (a numeric processing language) and dc (a calculator)\e[39m"
                echo  ""
		        echo  ""
                exit;
fi


################################################## 
###  Seta Variaveis necessárias se tudo esta ok ##
##################################################
DATEPFILE=`date +'%d%m%y'`
}

# Lib para acesso ao SQL Plus #
sqldb()
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


 # Parametrização do Oracle #
DBparameter ()
{
##################################################################################
### ORACLE PARAMETERS
##################################################################################

## Carrega Variveis sobre instancias running
INSTANCE_COUNTASM=`ps -ef | grep -i pmon | egrep -v 'grep' | wc -l | tr -d ' '`
INSTANCE_RUNNING=`ps -ef | grep -i pmon | egrep -v 'grep' | awk {'print $9'} | cut -d'_' -f3 `
INSTANCE_RUNNING2=`echo $INSTANCE_RUNNING`
INSTANCE_COUNT=`ps -ef | grep -i pmon | egrep -v 'grep|ASM' | awk {'print $9'} |  wc -l |  tr -d ' '`


## Questiona a quantidade final de instancias
echo ""
echo ""
echo "Atualmente existem $INSTANCE_COUNTASM instancias em execução [$INSTANCE_RUNNING2]."
echo "Com base no valor informado será feito o calculo de memória para cada instância"
echo "Informe o número total de instancias que o servidor vai suportar. [Valores numericos apenas]"
echo ""
echo "!! NAO CONTABILIZAR A INSTANCIA DO ASM !!"
echo ""
echo "Numero de instancias:"
read INSTANCE_COUNTNEW
echo ""
echo ""


## Verificar se o valor passado é valido
case $INSTANCE_COUNTNEW in

              0) echo "Impossivel calcular $INSTANCE_COUNTNEW instancia (Div 0)."; exit 1;;
    ''|*[!1-99]*) "$INSTANCE_COUNTNEW diferente de numerico."; exit 1;;
              *) echo "Numero de Instancias atuais [ ${INSTANCE_COUNT} ], Numero futuro  [ ${INSTANCE_COUNTNEW} ]" ;;
esac

echo ""
echo ""
echo "################################################################"
echo "###                  Memoria Oracle                          ###"
echo "################################################################"
echo ""
echo ""

echo "Instancias em execucão $INSTANCE_RUNNING2"
echo ""
echo ""

export USABLE_MEMORY=$(echo "$TOTAL_MEMORY_MB-1024"|bc)

## Executa um loop de parametrizacao para cada instancia
for inst in `echo $INSTANCE_RUNNING | sed -e 's/+ASM//g'`
do

## Exporta o oracle_sid para conectar em cada instancia e pegar o valor 
export ORACLE_SID=$inst
SGA_TARGET=`sqldb "show parameter sga_target"|awk '{print $4}'`
SGA_MAX_SIZE=`sqldb "show parameter sga_max_size"|awk '{print $4}'`
DB_CACHE_SIZE=`sqldb "show parameter db_cache_size"|awk '{print $4}'`
SHARED_POOL_SIZE=`sqldb "show parameter shared_pool_size"|awk '{print $4}'`
PGA_AGGREGATE_TARGET=`sqldb "show parameter pga_aggregate_target"|awk '{print $4}'`
MEMORY_MAX_TARGET=`sqldb "show parameter memory_max_target"|awk '{print $4}'`
MEMORY_TARGET=`sqldb "show parameter memory_target"|awk '{print $4}'`
CELL_OFFLOAD_PROCESSING=`sqldb "show parameter cell_offload_processing"|awk '{print $3}'`
CONTROL_MANAGEMENT_PACK_ACCESS=`sqldb "show parameter CONTROL_MANAGEMENT_PACK_ACCESS"|awk '{print $3}'`
FAST_START_MTTR_TARGET=`sqldb "show parameter FAST_START_MTTR_TARGET"|awk '{print $3}'`
NEW_SGA_TARGET=$(echo "$USABLE_MEMORY*60/100/$INSTANCE_COUNTNEW"|bc)
NEW_SGA_MAX_SIZE=$NEW_SGA_TARGET
NEW_DB_CACHE_SIZE=$(echo "$NEW_SGA_TARGET*45/100"|bc)
NEW_SHARED_POOL_SIZE=$(echo "$NEW_SGA_MAX_SIZE*20/100"|bc)
NEW_PGA_AGGREGATE_TARGET=$(echo "$NEW_SGA_MAX_SIZE*5/100"|bc)


#### Parametros Atuais

echo ""
echo ""
echo "################################################################"
echo "###                  $inst                                   ###"
echo "################################################################"
echo ""
echo  " Parametros Atuais Instancia $inst."
echo  "----------------------------------------------------------------"
echo  "SGA_TARGET: $SGA_TARGET"
echo  "SGA_MAX_SIZE: $SGA_MAX_SIZE"
echo  "DB_CACHE_SIZE: $DB_CACHE_SIZE"
echo  "SHARED_POOL_SIZE: $SHARED_POOL_SIZE"
echo  "PGA_AGGREGATE_TARGET: $PGA_AGGREGATE_TARGET"
echo  "MEMORY_MAX_TARGET: $MEMORY_MAX_TARGET"
echo  "MEMORY_TARGET: $MEMORY_TARGET"
echo  "CELL_OFFLOAD_PROCESSING: $CELL_OFFLOAD_PROCESSING"
echo  "CONTROL_MANAGEMENT_PACK_ACCESS: $CONTROL_MANAGEMENT_PACK_ACCESS"
echo  "FAST_START_MTTR_TARGET: $FAST_START_MTTR_TARGET"
echo  ""
echo  ""
echo  ""
echo  ""
#### Novos Parametros Sugeridos
echo "Novos Parametros Instancia $inst."
echo "----------------------------------------------------------------"
echo "CREATE PFILE='/tmp/pfile-$DATEPFILE$inst' FROM SPFILE;"
echo "ALTER SYSTEM SET SGA_TARGET=${NEW_SGA_TARGET}M SCOPE=SPFILE;"
echo "ALTER SYSTEM SET SGA_MAX_SIZE=${NEW_SGA_MAX_SIZE}M SCOPE=SPFILE;"
echo "ALTER SYSTEM SET DB_CACHE_SIZE=${NEW_DB_CACHE_SIZE}M SCOPE=SPFILE;"
echo "ALTER SYSTEM SET SHARED_POOL_SIZE=${NEW_SHARED_POOL_SIZE}M SCOPE=SPFILE;"
echo "ALTER SYSTEM SET PGA_AGGREGATE_TARGET=${NEW_PGA_AGGREGATE_TARGET}M SCOPE=SPFILE;"
echo "ALTER SYSTEM SET FAST_START_MTTR_TARGET=180 SCOPE=SPFILE;"
echo "ALTER SYSTEM SET \"CELL_OFFLOAD_PROCESSING\"=FALSE SCOPE=SPFILE; (Somente se não for Exadata)"
echo "ALTER SYSTEM SET CONTROL_MANAGEMENT_PACK_ACCESS='NONE' SCOPE=SPFILE; (Somente se não tiver Dignostic + Tunning Pack)"
echo ""
echo ""
echo ""
done
}

 # Output Linux #
linux () {

## Carrega Variaveis de Ambiente do Linux
environment_linux;

##################################################################################
echo -e "\e[93mParametros: \e[39m"
echo -e "\e[31m----------------------------------------------------------------\e[39m"
echo -e "Total de RAM (Mb): \e[97m${TOTAL_MEMORY}\e[39m"
echo -e ""
echo -e ""
echo -e ""
echo -e "\e[93m Parametros de Kernel /etc/sysctl.conf \e[39m"
echo -e "\e[31m----------------------------------------------------------------\e[39m"
echo -e "kernel.shmmax = \e[97m$max \e[96m(actual ${SHMMAX})\e[39m"
echo -e "kernel.shmall = \e[97m$all \e[96m(actual ${SHMALL})\e[39m"
echo -e "kernel.shmmni = \e[97m4096 \e[96m(actual ${SHMMNI})\e[39m"
echo -e "kernel.sem = \e[97m${SEMMSL} ${SEMMNS} ${SEMOPM} ${SEMMNI} \e[96m(actual ${SEM})\e[39m"
echo -e "vm.nr_hugepages = $NUM_PG     \e[96m(actual ${NR_HUGEPAGES})\e[39m "   
echo -e "vm.swappiness = 0     \e[96m(actual ${ACTSWAP})\e[39m" 
echo -e ""
echo -e ""
echo -e ""
#### Limits do usuário
echo -e "\e[93m Limitando recursos para o usuario Oracle /etc/security/limits.conf \e[39m"
echo -e "\e[31m----------------------------------------------------------------\e[39m"
echo -e "oracle soft memlock \e[97m$LIMITS \e[96m(actual $ORACLE_SOFT_MEMLOCK)\e[39m"
echo -e "oracle hard memlock \e[97m$LIMITS \e[96m(actual $ORACLE_HARD_MEMLOCK)\e[39m"
echo -e "oracle soft nofile \e[97m1024 \e[96m(actual $ORACLE_SOFT_NOFILE)\e[39m"
echo -e "oracle hard nofile \e[97m65536 \e[96m(actual $ORACLE_HARD_NOFILE)\e[39m"
echo -e "oracle soft nproc \e[97m16384 \e[96m(actual $ORACLE_SOFT_NPROC)\e[39m"
echo -e "oracle hard nproc \e[97m16384 \e[96m(actual $ORACLE_HARD_NPROC)\e[39m"
echo -e "oracle soft stack \e[97m10240 \e[96m(actual $ORACLE_SOFT_STACK)\e[39m"
echo -e "oracle hard stack \e[97m32768 \e[96m(actual $ORACLE_HARD_STACK)\e[39m"
echo -e ""
echo -e ""
echo -e "\e[93m Tunning Linux para VMs : \e[39m"
echo -e "\e[31m-------------------- EXECUTAR COMO ROOT - VMS APENAS!!----------------------\e[39m"
## Rotational 
for i in $IO_DEVICES
do
echo "echo 0 > /sys/block/$i/queue/rotational"
done
echo -e "\e[93mAdicionar os comandos acima tambem no /etc/rc.local para ser efetivo apos reboot \e[39m"
echo -e ""
echo -e ""

## Scheduler
for i in $IO_DEVICES
do
echo "echo noop > /sys/block/$i/queue/scheduler"
done
echo -e ""

### Parametros do Grub
echo -e "\e[93m Adicionar ao Kernel utilizado em /etc/grub.conf - VMs \e[39m"
echo -e "\e[31m-------------------- EXECUTAR COMO ROOT - VMS APENAS!!----------------------\e[39m"
echo -e "apm=off acpi=off noapic elevator=noop"
echo -e ""
}



pre_check;
case "$os"
in
   "Linux")  DBparameter; linux;;
     "AIX")  DBparameter;;
         *)  echo "$os nao suportardo." 
             exit 1;;
esac
