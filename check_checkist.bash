#!/bin/bash
#
# checklist_CNU.sh
# Adaptacao: Matsuo Furushima
#
# Script valida diversas funcionalidades do banco de dados e Exadata afim de evitar problemas durante o dia 
# 
#
#
#
# Alteracoes:
#
# Data          Autor                   Descricao
# ----------   -------------------     ----------------------------------------------------
#
#===============================================================================================================================================


SERVIDOR=`hostname -s`

## Oratab
export PATH_ORATAB="/home/oracle/dba"
ALL_DATABASES=`cat ${PATH_ORATAB}/oratab|grep -v "^#"|grep -v "N$"|cut -f1 -d: -s|grep -v EBS|grep -v '-'`
DH=`date +%Y%m%d-%H%M`


## Modo de exibicao HTML
export VAR_DISPLAY_MODE=html
 
## Valida que Arquivos de Hosts Exista
FILE="/backup/scripts_adm/checklist_cnu/all_servers_cnu"
if test -f "$FILE"; then
    echo "Arquivo de Servidores a serem validados $FILE."
else 
   echo "O Arquivo $FILE nao existe, validar!"
   exit	
fi





## Arquivo para teste de ICMP ##
export ONS="/tmp/onlineservers"
export OFFS="/tmp/offlineservers"

if [ -f $ONS ]; then
rm -f $ONS
fi

if [ -f $OFFS ]; then
rm -f $OFFS
fi




###################################################################################################
############################     FUNCOES DE SISTEMA OPERACIONAL       #############################
###################################################################################################

## OS.00 - Verifica se os servidores envolvidos estao respondendo a ICMP
FUN_OS00() {

  export ORACLE_SID=""
  export COD_METRICA="OS.00"
  export TIP_VAL_ESPERADO="txt"
  export VAL_ESPERADO="ON"
  export SERV_AUX=""


echo "Realizando analise de UP/DOWN"

for pools in `cat /backup/scripts_adm/checklist_cnu/all_servers_cnu`
do
ping -q -c2 $pools 1>> /dev/null

if [ $? -eq 0 ]
then
     echo "$pools"  >> $ONS
	 VAL_COLETA="ON"
	 export DSC_METRICA="Servidor $pools esta respondendo ao Ping."
	 FUN_OUTPUT
else
     echo "$pools" >> $OFFS
	 VAL_COLETA="OFF"
	 export DSC_METRICA="Servidor $pools nao esta respondendo ao Ping!"
	 FUN_OUTPUT
fi      
done

}

## INICIO: OS.01 - Funcao: Valida filesystem > VAL_ESPERADO
FUN_OS01() {
  export ORACLE_SID=""
  export COD_METRICA="OS.01"
  export TIP_VAL_ESPERADO="txt"
  export VAL_ESPERADO="90"
  export SERV_AUX=""
  
  echo "Realizando analise de utilizacao do filesystem."
  aux2=""
  for linha in `sudo /usr/local/bin/dcli -g $ONS -l root  df -Pkhl  | grep -v 'Filesystem' |  awk '{print $1 ";" $6 ";" $7}' | tr -d :`
  do
    RESULT=""
    aux=""
    aux=`echo $linha |  cut -d";" -f2 | cut -d% -f1`
	SERVIDOR=`echo $linha |  cut -d";" -f1`
	FS=`echo $linha |  cut -d";" -f3`
    if [ $((aux)) -gt $((VAL_ESPERADO)) ]
    then
	  ## Filesystem acima do Threshould ##
      aux2=${aux2}"`echo $linha | cut -d\; -f2` "
      VAL_COLETA=""
      export DSC_METRICA="Filesystem $FS com ocupacao ( $aux2 )% - Valor Esperado $VAL_ESPERADO % "
	  FUN_OUTPUT
	  unset aux2
	else
	
	 if [ "$SERV_AUX" != "${SERVIDOR}" ] 
	 then
	 SERV_AUX=${SERVIDOR}
	 VAL_COLETA=$((VAL_ESPERADO))
     export DSC_METRICA="Filesystem $FS OK."
	 FUN_OUTPUT
	 fi
   fi
  
     
  
  done
  unset SERVIDOR
}



## INICIO: OS.02 - Funcao: Valida uptime
FUN_OS02() {
  export ORACLE_SID=""
  export COD_METRICA="OS.02"
  export TIP_VAL_ESPERADO="num_menos"
  export VAL_ESPERADO="7"
  
  echo "Realizando analise de uptime."
  for linha in `sudo /usr/local/bin/dcli -g $ONS -l root  uptime |  awk '{print $1 ";" $4}' | tr -d :`
  do
  SERVIDOR=`echo $linha | cut -d";" -f1`
  VAL_COLETA=`echo $linha | cut -d";" -f2`
  export DSC_METRICA="Uptime > ${VAL_ESPERADO} ( ${VAL_COLETA} ) dias"
  FUN_OUTPUT
  done
  unset SERVIDOR
  
}
## FIM: OS.02 - Funcao: Valida uptime


## INICIO: OS.03 - Funcao: Valida load average
FUN_OS03() {
  export ORACLE_SID=""
  export COD_METRICA="OS.03"
  export TIP_VAL_ESPERADO="num"
  export VAL_ESPERADO="35"

echo "Realizando analise de Load avarage."
for linha in `sudo /usr/local/bin/dcli -g $ONS -l root  uptime | awk '{print $1 ";" $11}' | tr -d :,`
  do
  SERVIDOR=`echo $linha | cut -d";" -f1`
  VAL_COLETA=`echo $linha | cut -d";" -f2`
  export DSC_METRICA="load average < ${VAL_ESPERADO} ( ${VAL_COLETA} )"
  export VAL_COLETA=`printf '%.*f\n' 0 ${VAL_COLETA}`

  FUN_OUTPUT
  
  done
  unset SERVIDOR



}
## FIM: OS.03 - Funcao: Valida load average

## INICIO: OS.04 - Funcao: Valida memoria
FUN_OS04() {
  export ORACLE_SID=""
  export COD_METRICA="OS.04"
  export TIP_VAL_ESPERADO="num"
  export VAL_ESPERADO="95"
  
echo "Realizando analise de utilizacao de memoria."  
for linha in `sudo /usr/local/bin/dcli -g $ONS -l root  free -m | grep -i Mem | awk '{print $1 ";" $3 ";" $4 ";" $5 }' `
  do
  export TOTALMEM=`echo $linha | cut -d";" -f2`
  export USEDMEM=`echo $linha | cut -d";" -f3`
  export FREEMEM=`echo $linha | cut -d";" -f4`
  SERVIDOR=`echo $linha | cut -d";" -f1`
  VAL_COLETA=`echo $(($USEDMEM * 100 / $TOTALMEM ))`
  export DSC_METRICA="Memoria usada < ${VAL_ESPERADO} % ( Utilizacao: ${VAL_COLETA} % - Total: ${TOTALMEM} M | Usado: ${USEDMEM} M | livre: ${FREEMEM} M )"
  export VAL_COLETA=`printf '%.*f\n' 0 ${VAL_COLETA}`

  FUN_OUTPUT
  
  done
  unset SERVIDOR
}
## FIM: OS.04 - Funcao: Valida memoria

## INICIO: OS.05 - Funcao: Valida swap
FUN_OS05() {
  export ORACLE_SID=""
  export COD_METRICA="OS.05"
  export TIP_VAL_ESPERADO="num"
  export VAL_ESPERADO="60"


echo "Realizando analise de utilizacao de Swap."  
for linha in `sudo /usr/local/bin/dcli -g $ONS -l root  free -m | grep -i swap | awk '{print $1 ";" $3 ";" $4 ";" $5 }' `
  do
  export TOTALSWAP=`echo $linha | cut -d";" -f2`
  export USEDSWAP=`echo $linha | cut -d";" -f3`
  export FREESWAP=`echo $linha | cut -d";" -f4`
  SERVIDOR=`echo $linha | cut -d";" -f1`
  VAL_COLETA=`echo $(($USEDSWAP * 100 / $TOTALSWAP ))`
  export DSC_METRICA="Swap utilizado < ${VAL_ESPERADO} % ( Utilizacao: ${VAL_COLETA} % - Total: ${TOTALSWAP} M | Usado: ${USEDSWAP} M | livre: ${FREESWAP} M )"
  export VAL_COLETA=`printf '%.*f\n' 0 ${VAL_COLETA}`
  FUN_OUTPUT
  
  done
  unset SERVIDOR
}
## FIM: OS.05 - Funcao: Valida swap

## INICIO: OS.6 - Funcao: Valida inodes
FUN_OS06() {
  export ORACLE_SID=""
  export COD_METRICA="OS.06"
  export TIP_VAL_ESPERADO="txt"
  export VAL_ESPERADO="90"

  echo "Realizando analise de utilizacao de INODE."
  aux2=""
  for linha in `sudo /usr/local/bin/dcli -g $ONS -l root  df -Pkhil  | grep -v 'Filesystem' |  awk '{print $1 ";" $6 ";" $7}' | grep -v '/dev' | grep -v '-' | tr -d :`
  do
    RESULT=""
    aux=""
    aux=`echo $linha |  cut -d";" -f2 | cut -d% -f1`
	SERVIDOR=`echo $linha |  cut -d";" -f1`
	FS=`echo $linha |  cut -d";" -f3`
    if [ $((aux)) -gt $((VAL_ESPERADO)) ]
    then
	  ## Filesystem acima do Threshould ##
      aux2=${aux2}"`echo $linha | cut -d\; -f2` "
      VAL_COLETA=""
      export DSC_METRICA="Filesystem $FS com ocupacao de Inodes ( $aux2 )% - Valor Esperado $VAL_ESPERADO % "
	  FUN_OUTPUT
	  unset aux2
	else
	 if [ "$SERV_AUX" != "${SERVIDOR}" ] 
	 then
	 SERV_AUX=${SERVIDOR}
	 VAL_COLETA=$((VAL_ESPERADO))
     export DSC_METRICA="Inodes $FS OK."
	 FUN_OUTPUT
	 fi
   fi
   
     
  done
  unset SERVIDOR
     
}
## FIM: OS.06 - Funcao: Valida filesystem > VAL_ESPERADO

## INICIO: OS.07 - Funcao: Valida CPU
FUN_OS07() {
  export ORACLE_SID=""
  export COD_METRICA="OS.07"
  export TIP_VAL_ESPERADO="num"
  export VAL_ESPERADO="60"
  
  
  echo "Realizando analise de CPU."
  for linha in `sudo /usr/local/bin/dcli -g $ONS -l root mpstat | egrep -i "AM|PM" | grep -v CPU  |  awk '{print $1 ";" $13}'  | tr -d :`
  do
  SERVIDOR=`echo $linha | cut -d";" -f1`
  VAL_COLETAI=`echo $linha | cut -d";" -f2 | cut -d"." -f1`
  VAL_COLETA=`echo $(( 100 - $VAL_COLETAI ))`

  export DSC_METRICA="Uso da CPU  $VAL_COLETA  - Cpu Idle: ${VAL_COLETAI} - Threshould $VAL_ESPERADO )"
  export VAL_COLETA=`printf '%.*f\n' 0 ${VAL_COLETA}`
  FUN_OUTPUT
  done
  unset SERVIDOR
}
## FIM: OS.07 - Funcao: Valida CPU

## INICIO: OS.08 - Funcao: Valida IOWait
FUN_OS08() {
  export ORACLE_SID=""
  export COD_METRICA="OS.08"
  export TIP_VAL_ESPERADO="num"
  export VAL_ESPERADO="20"

  VAL_COLETA=`iostat -c|awk '/^ /{print $4}' | cut -f1 -d.`
  export DSC_METRICA="IOWait  < ${VAL_ESPERADO} % ( ${VAL_COLETA} % )"
  export VAL_COLETA=`printf '%.*f\n' 0 ${VAL_COLETA}`

  FUN_OUTPUT
}
## FIM: OS.08 - Funcao: Valida IOWait

###################################################################################################
############################ FUNCOES BANCO DE DADOS DE DISPONIBILIDADE ############################
###################################################################################################

## INICIO: HA.01 - Funcao: valida disponibilidade
FUN_HA01() {
  export V_DB_VERSION=""
  export V_DB_STATUS=""
  export V_CHECA_PROCESSO_DB=""
  export V_DB_ROLE=""
  export COD_METRICA="HA.01"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"

echo "Validando disponibilidade -  $ORACLE_SID"
 
  if [ "`echo ${ORACLE_SID} | cut -c1`" = "+" ]
  then
    export VAL_ESPERADO="STARTED"
    V_CHECA_PROCESSO_DB=`ps -ef | grep asm_pmon_${ORACLE_SID} | grep -v grep | wc -l`
  else
    export VAL_ESPERADO="OPEN"
    V_CHECA_PROCESSO_DB=`ps -ef | grep ora_pmon_${ORACLE_SID} | grep -v grep | wc -l`
  fi
  
  if [ "${V_CHECA_PROCESSO_DB}" -eq 1 ]
  then 
    VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select status from v\\$instance;
    exit
EOF
`

    export V_DB_VERSION=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select version from v\\$instance;
    exit
EOF
`
    export V_DB_ROLE=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select DATABASE_ROLE from v\\$database;
    exit
EOF
`
    if [ "`printf ${V_DB_ROLE}`" != "PRIMARY" ] && [ "`printf ${VAL_COLETA}`" != "OPEN" ] && [ "`echo ${ORACLE_SID} | cut -c1`" != "+" ]
    then
      export VAL_ESPERADO="MOUNTED"
    fi
  else
    export VAL_COLETA="DOWN"
    export V_DB_VERSION="-"
    export V_DB_ROLE="-"
  fi

  export DSC_METRICA="Disponibilidade - BD status: ( `printf ${VAL_COLETA}` ) | Versao: `printf ${V_DB_VERSION}` "

  FUN_OUTPUT 
}
## FIM: HA.01 - Funcao: valida disponibilidade


## INICIO: HA.02 - Funcao: valida disponibilidade db

FUN_HA02() {
  export COD_METRICA="HA.02"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="num_menos"
  export VAL_THRESHOLD=1
echo "Validando ultimo startup -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select count(1) from v\\$instance where STARTUP_TIME < sysdate-${VAL_THRESHOLD};
    exit
EOF
`
  export DSC_METRICA="Ultimo startup do banco de dados < ( ${VAL_THRESHOLD} dia )"

  export VAL_ESPERADO=0


  FUN_OUTPUT
}

## FIM: HA.02 - Funcao: valida disponibilidade db


## INICIO: HA.04 - Funcao: valida diskgroups

FUN_HA04() {
  export COD_METRICA="HA.04"
  export CONNECT_BD="/ as sysasm"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=95
  aux=""
  aux2=""
  export VAL_COLETA=""
  echo "Validando uso do Diskgroup ASM."
  export aux=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select name
      from ( SELECT 
           NAME,
           (TOTAL_MB) TOTAL_MB,
           (total_mb - free_mb) used_mb,
           (total_mb -(total_mb - free_mb)) FREE_MB,
           ROUND((1- (free_mb / total_mb))*100, 2) pct_used,
           case
             when TOTAL_MB <= 2000000  and ROUND((1- (free_mb / total_mb))*100, 2) > 80 then 91
             when (TOTAL_MB > 2000000  and TOTAL_MB = 5000000) and ROUND((1- (free_mb / total_mb))*100, 2) > 90 then 91
             when (TOTAL_MB > 5000000) and ROUND((1- (free_mb / total_mb))*100, 2) > 95 then 91
           else
             89
           end status_alarme
             FROM v\\$asm_diskgroup)
       where pct_used > '${VAL_THRESHOLD}';

EOF
`
  for linha in `echo $aux`
  do
    aux2=$linha"|"${aux2}
  done

  export DSC_METRICA="Diskgroups com ocupacao > `echo ${VAL_THRESHOLD}`% "

  if [ "`echo ${aux2}`" == "" ]
  then
     export VAL_COLETA=""
  else
     export VAL_COLETA="`echo ${aux2}`"
     export DSC_METRICA=`echo ${DSC_METRICA}`" ( `echo ${VAL_COLETA}` )"
  fi

  export VAL_ESPERADO=""

  FUN_OUTPUT
}

## FIM: HA.04 - Funcao: valida diskgroups


## INICIO: HA.05 - Funcao: valida tablespaces

FUN_HA05() {
  export COD_METRICA="HA.05"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=97
  export VAL_THRESHOLD2=10000 #menor MB
  aux=""
  aux2=""
  echo "Validando tablespaces da base -  $ORACLE_SID"
  export VAL_COLETA=""
  export aux=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select name
 from (select nvl(b.tablespace_name, nvl(a.tablespace_name,'UNKOWN')) name,
        mbytes_alloc mbytes, decode(mbytes_largest, -1, mbytes_free, mbytes_alloc-nvl(mbytes_free,0)) used,
        decode(mbytes_largest, -1, b.mbytes_alloc-a.mbytes_free, nvl(mbytes_free,0)) free,
         decode(mbytes_largest, -1,mbytes_free/mbytes_alloc, (mbytes_alloc-nvl(mbytes_free,0))/mbytes_alloc)*100 pct_used,
         decode(mbytes_largest, -1, 0, nvl(mbytes_largest,0)) largest
  from ( select sum(bytes)/1024/1024 mbytes_free,
                round(max(bytes)/1024/1024,2) mbytes_largest,
                tablespace_name
           from sys.dba_free_space
          group by tablespace_name
          union
          select sum(bytes_used)/1024/1024 mbytes_used, -1, tablespace_name
          from v\\$temp_extent_pool
          group by tablespace_name) a,
        ( select sum(bytes)/1024/1024 mbytes_alloc,
                 tablespace_name
          from sys.dba_data_files
          group by tablespace_name
          union
          select sum(bytes)/1024/1024 mbytes_alloc,
                 tablespace_name
          from sys.dba_temp_files
          group by tablespace_name )b
   where a.tablespace_name (+) = b.tablespace_name)
 where (name not in (select TABLESPACE_NAME from DBA_ROLLBACK_SEGS where TABLESPACE_NAME <> 'SYSTEM' group by TABLESPACE_NAME)
        and name not in (select TABLESPACE_NAME from v\\$temp_space_header group by TABLESPACE_NAME))
   and pct_used > '${VAL_THRESHOLD}';
EOF
`
  for linha in `echo $aux`
  do
    aux2=$linha"|"${aux2}
  done
  
  export DSC_METRICA="Tablespaces com ocupacao > `echo ${VAL_THRESHOLD}`% "
   
  if [ "`echo ${aux2}`" == "" ]
  then
     export VAL_COLETA=""
  else
     export VAL_COLETA="`echo ${aux2}`"
     export DSC_METRICA=`echo ${DSC_METRICA}`" ( `echo ${VAL_COLETA}` )"
  fi

  export VAL_ESPERADO=""

  FUN_OUTPUT
}

## FIM: HA.05 - Funcao: valida tablespace


## INICIO: HA.06 - Funcao: valida dbfiles

FUN_HA06() {
  export COD_METRICA="HA.06"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="num"
  export VAL_THRESHOLD=1
  echo "Validando DBFILES -  $ORACLE_SID"

  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select round((select count(file#) from v\\$datafile)/(select value from v\\$parameter where name = 'db_files')*100) from dual;
    exit
EOF
`
  export VAL_ESPERADO=80
  export DSC_METRICA="Total datafiles > ${VAL_ESPERADO} % ( `echo ${VAL_COLETA}`% )"


  FUN_OUTPUT
}

## FIM: HA.06 - Funcao: valida dbfiles


## INICIO: HA.07 - Funcao: valida alert ultimas 24hrs.

FUN_HA07() {
  export COD_METRICA="HA.07"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=""
  aux=""
  aux2=""
  export VAL_COLETA=""
  echo "Validando erros no alert -  $ORACLE_SID"
  export aux=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select name
    from (
	SELECT distinct
       substr(MESSAGE_TEXT,INSTR(upper(MESSAGE_TEXT),'ORA-', 1, 1),9) name
	  FROM sys.X\\$DBGALERTEXT
	 WHERE 
              --(upper(MESSAGE_TEXT) like '%ORA-%' and upper(MESSAGE_TEXT) not like '%ORA-03135%')
             (upper(MESSAGE_TEXT) like '%ORA-07445%' or  upper(MESSAGE_TEXT) like '%ORA%600%') 
	   AND originating_timestamp > (SYSDATE-1)
       );
EOF
`
  for linha in `echo $aux`
  do
    aux2=$linha"|"${aux2}
  done

  export DSC_METRICA="Erros no log de banco nas ultimas 24hrs. "

  if [ "`echo ${aux2}`" == "" ]
  then
     export VAL_COLETA=""
  else
     export VAL_COLETA="`echo ${aux2}`"
     export DSC_METRICA=`echo ${DSC_METRICA}`" ( `echo ${VAL_COLETA}` )"
  fi

  export VAL_ESPERADO=""

  FUN_OUTPUT
}

## FIM: HA.07 - Funcao: valida alert ultimas 24hrs.


## INICIO: HA.08 - Funcao: valida backup archive

FUN_HA08() {
  export COD_METRICA="HA.08"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=8

  echo "Validando backup de archive -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select  status 
      from v\\$rman_backup_job_details 
     where start_time between sysdate - interval '8' hour and sysdate
       and status in ('COMPLETED')
       and input_type = 'ARCHIVELOG'
       and end_time > sysdate-'${VAL_THRESHOLD}'/24 group by status;	     
		   
    exit
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA="NOT EXECUTED"
  fi

  export VAL_ESPERADO="COMPLETED"

  export DSC_METRICA="Execucao do ultimo backup de archive >  "${VAL_THRESHOLD}" h: ( status `echo ${VAL_COLETA}` )"

  FUN_OUTPUT
}
## FIM: HA.08 - Funcao: valida backup archive


## INICIO: HA.09 - Funcao: valida backup hot

FUN_HA09() {
  export COD_METRICA="HA.09"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=1

  echo "Validando backups Hot -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select status from v\\$rman_status
where operation = 'BACKUP' and object_type like 'DB%' and status = 'COMPLETED'  and end_time > sysdate-'${VAL_THRESHOLD}' group by status;
    exit
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA="NOT EXECUTED"
  fi

  export VAL_ESPERADO="COMPLETED"

  export DSC_METRICA="Execucao do ultimo backup DB >  "${VAL_THRESHOLD}" dia(s): ( status `echo ${VAL_COLETA}` )"

  FUN_OUTPUT
}

## FIM: HA.09 - Funcao: valida backup hot

## INICIO: HA.11 - Funcao: espaco valida archive

FUN_HA11() {
  export COD_METRICA="HA.11"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="num"
  export VAL_THRESHOLD=70
  aux3=""
    echo "Validando espaco de archive -  $ORACLE_SID"
  export aux3=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    set serveroutput on

DECLARE
  v_archive      v\\$database.log_mode%type;
  v_cnt_archive  number := 0;
  v_localizacao  v\\$parameter.name%type;
  v_tamanho      v\\$parameter.name%type;
  v_tipo_destino varchar2(10);
  v_PRC_USED     number(10,2);
BEGIN
  BEGIN
    SELECT LOG_MODE INTO v_archive FROM v\\$database;
  EXCEPTION
    WHEN others THEN
      v_archive := null;
  END;
  
  IF v_archive = 'ARCHIVELOG' then
    FOR linha IN (select dest_name,destination from V\\$ARCHIVE_DEST where status='VALID' and archiver='ARCH')
    LOOP
      IF linha.destination = 'USE_DB_RECOVERY_FILE_DEST' THEN
        select VALUE
          INTO v_localizacao
          from v\\$parameter
         where NAME ='db_recovery_file_dest';
        
        select VALUE/1024/1024/1024
          INTO v_tamanho
          from v\\$parameter
         where NAME ='db_recovery_file_dest_size';

        select decode ((substr(v_localizacao,1,1)),'+','ASM','FILESYSTEM')
          INTO v_tipo_destino
         from dual;

        execute immediate 'SELECT CEIL((SPACE_USED - SPACE_RECLAIMABLE)/SPACE_LIMIT * 100) FROM V\\$RECOVERY_FILE_DEST' INTO v_PRC_USED;

        dbms_output.put_line(v_archive||';'||'FRA'||';'||v_tipo_destino||';'||v_localizacao||';'||v_tamanho||';'||v_PRC_USED);
      ELSE
        select decode ((substr(linha.destination,1,1)),'+','ASM','FILESYSTEM')
          INTO v_tipo_destino
         from dual;

        dbms_output.put_line(v_archive||';'||'NOT-FRA'||';'||v_tipo_destino||';'||linha.destination||';0;0');
      END IF;
    END LOOP;
  ELSE
    dbms_output.put_line('NOARCHIVE');
  END IF;
  
END;
/

    exit
EOF
`
  export VAL_ESPERADO=70 
  if [ "`echo ${aux3}`" == "NOARCHIVE" ]
  then
     export VAL_COLETA="0"
     export DSC_METRICA="ocupacao area de archive ( `echo ${aux3}` )"
  else
     export VAL_COLETA="`echo ${aux3}|  cut -f6 -d';'`"
     export DSC_METRICA="ocupacao area de archive ( `echo ${aux3}| cut -f2 -d';'` | `echo ${VAL_COLETA}` % )"
  fi


  FUN_OUTPUT
}

## FIM: HA.11 - Funcao: valida archive

## INICIO: HA.12 - Funcao: valida process

FUN_HA12() {
  export COD_METRICA="HA.12"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="num"
  export VAL_THRESHOLD=1

   echo "Validando quantidade de process -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select round((select count(spid) from v\\$process)/(select value from v\\$parameter where name = 'processes')*100) from dual;
    exit
EOF
`
  export VAL_ESPERADO=80
  export DSC_METRICA="Process < ${VAL_ESPERADO} % ( `echo ${VAL_COLETA}`% )"


  FUN_OUTPUT
}

## FIM: HA.12 - Funcao: valida process

## INICIO: HA.13 - Funcao: valida tamanho recyclebin

FUN_HA13() {
  export COD_METRICA="HA.13"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="num"
  export VAL_THRESHOLD=1
  
  echo "Validando tamanho da Recyclebin -  $ORACLE_SID"

  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    alter session set NLS_NUMERIC_CHARACTERS=', ';
    select nvl(round(sum(seg.bytes/1024/1024)),0)
      from dba_segments seg,
           DBA_RECYCLEBIN bin
     where seg.segment_name=bin.object_name
       and seg.owner=bin.owner;
    exit
EOF
`
  export VAL_ESPERADO="2048"
  export DSC_METRICA="Recyclebin < ${VAL_ESPERADO} MB ( `echo ${VAL_COLETA}` MB )"


  FUN_OUTPUT
}

## FIM: HA.13 - Funcao: valida recyclebin


# INICIO: HA.14 - Funcao: valida limite recursos

FUN_HA14() {
  export COD_METRICA="HA.14"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=95
  aux=""
  aux2=""
  export VAL_COLETA=""
    echo "Validando Limitacao de recursos -  $ORACLE_SID"
  export aux=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select name
      from ( select RESOURCE_NAME name, round((CURRENT_UTILIZATION / MAX_UTILIZATION) *100 ) pct_used 
  from v\\$resource_limit
 where RESOURCE_NAME in ('processes','sessions','parallel_max_servers','enqueue_locks','enqueue_resources','transactions'))
       where pct_used > '${VAL_THRESHOLD}';
EOF
`
  for linha in `echo $aux`
  do
    aux2=$linha"|"${aux2}
  done

  export DSC_METRICA="Limite recursos instância > `echo ${VAL_THRESHOLD}`% "

  if [ "`echo ${aux2}`" == "" ]
  then
     export VAL_COLETA=""
  else
     export VAL_COLETA="`echo ${aux2}`"
     export DSC_METRICA=`echo ${DSC_METRICA}`" ( `echo ${VAL_COLETA}` )"
  fi

  export VAL_ESPERADO=""

  FUN_OUTPUT
}


## FIM: HA.14 - Funcao: valida limite recursos


###################################################################################################
############################         VALIDA FUNCOES DO BANCO          #############################
###################################################################################################

## INICIO: PE.1 - Funcao: valida regressao de um SQL_ID

FUN_PE1() {
  export COD_METRICA="PE.1"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=20
  export VAL_THRESHOLD2=10
  aux=""
  aux2=""
  echo "Validando SQLs Lentos  -  $ORACLE_SID"
  export VAL_COLETA=""
  export aux=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    alter session set nls_date_format = 'dd-mm-yyyy hh24:mi:ss';
    select sql_id from (
select sql_id, sum(execs), min(avg_etime) min_etime, max(avg_etime) max_etime, stddev_etime/min(avg_etime) norm_stddev
from (
select sql_id, plan_hash_value, execs, avg_etime,
stddev(avg_etime) over (partition by sql_id) stddev_etime
from (
select sql_id, plan_hash_value,
sum(nvl(executions_delta,0)) execs,
(sum(elapsed_time_delta)/decode(sum(nvl(executions_delta,0)),0,1,sum(executions_delta))/1000000) avg_etime
-- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0 and to_char(BEGIN_INTERVAL_TIME,'DD/MM/YYYY hh24:mi:ss') > SYSDATE-1
group by sql_id, plan_hash_value
)
)
group by sql_id, stddev_etime
)
where norm_stddev > '${VAL_THRESHOLD}'
and max_etime > '${VAL_THRESHOLD2}'
order by norm_stddev
/
EOF
`
  for linha in `echo $aux`
  do
    aux2=$linha"|"${aux2}
  done

  export DSC_METRICA="Regressao de planos de execucao com tempo > `echo ${VAL_THRESHOLD2}` segundos no ultimo dia"

  if [ "`echo ${aux2}`" == "" ]
  then
     export VAL_COLETA=""
  else
     export VAL_COLETA="`echo ${aux2}`"
     export DSC_METRICA=`echo ${DSC_METRICA}`" ( `echo ${VAL_COLETA}` )"
  fi

  export VAL_ESPERADO=""

  FUN_OUTPUT
}

## FIM: PE.1 - Funcao: valida regressao de planos

## INICIO: PE.02 - Funcao: valida lock

FUN_PE02() {
  export COD_METRICA="PE.02"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  #export VAL_THRESHOLD=0 - implementar supress de metrica
  echo "Validando Lock -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select count(1)
    from gv\\$lock l1, gv\\$session s1, gv\\$lock l2, gv\\$session s2
    where s1.sid=l1.sid and s2.sid=l2.sid
    and l1.BLOCK=1 and l2.request > 0
    and l1.id1 = l2.id1
    and l2.id2 = l2.id2; 
    exit
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA=0
  fi

  export VAL_ESPERADO=0

  export DSC_METRICA="Quantidade de sessoes em lock <  "${VAL_ESPERADO}" ( `echo ${VAL_COLETA}` )"

  FUN_OUTPUT
}

## FIM: PE.02 - Funcao: valida lock

## INICIO: PE.03 - Funcao: valida index unusable

FUN_PE03() {
  export COD_METRICA="PE.03"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  #export VAL_THRESHOLD=0
  echo "Validando Index Unusable -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select count(1) from dba_indexes where status='UNUSABLE';
    exit
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA=0
  fi

  export VAL_ESPERADO=0

  export DSC_METRICA="Quantidade de indexes com status unusable  ( `echo ${VAL_COLETA}` )"

  FUN_OUTPUT
}

## FIM: PE.03 - Funcao: valida index unusable


## INICIO: PE.08 - Funcao: valida objetos invalidos

FUN_PE08() {
  export COD_METRICA="PE.08"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  #export VAL_THRESHOLD=0
    echo "Validando Objetos Invalidos -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select count(1) from dba_objects where status<>'VALID';
    exit
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA=0
  fi

  export VAL_ESPERADO=0

  export DSC_METRICA="Quantidade de objetos invalidos  ( `echo ${VAL_COLETA}` )"

  FUN_OUTPUT
}

## FIM: PE.08 - Funcao: valida objetos invalidos

## INICIO: PE.09 - Funcao: valida componentes invalidos

FUN_PE09() {
  export COD_METRICA="PE.09"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  #export VAL_THRESHOLD=0
    echo "Validando Componentes Invalidos -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select count(1) from dba_registry where status <> 'VALID';
    exit
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA=0
  fi

  export VAL_ESPERADO=0

  export DSC_METRICA="Quantidade de componentes invalidos ( `echo ${VAL_COLETA}` )"

  FUN_OUTPUT
}

## FIM: PE.09 - Funcao: valida componentes invalidos


## INICIO: PE.06 - Funcao: valida sessao com status SUSPENDED por espaco recuperavel

FUN_PE06() {
  export COD_METRICA="PE.06"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  #export VAL_THRESHOLD=0
    echo "Validando Suspended  -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select count(1) from dba_resumable;
    exit
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA=0
  fi

  export VAL_ESPERADO=0

  export DSC_METRICA="Quantidade de sessoes com status SUSPENDED por espaco recuperavel ( `echo ${VAL_COLETA}` )"

  FUN_OUTPUT
}

## FIM: PE.06 - Funcao: valida sessao com status SUSPENDED por espaco recuperavel

## INICIO: PE.07 - Funcao: valida tabelas e indices  com  DEGREE > 0

FUN_PE07() {
  export COD_METRICA="PE.07"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  #export VAL_THRESHOLD=0
    echo "Validando Degree de objetos -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select sum(obj)
from
(
select  count(degree) obj from dba_tables where degree > '1' and
          OWNER NOT IN
 ('SYS','SYSTEM','OLAPSYS','ORDSYS','XDB','MDSYS','EXFSYS','WMSYS','ORDDATA','DBSNMP','OUTLN',
  'APPQOSSYS','WMSYS','SYSMAN','CTXSYS','TOTVSINSURANCE_SEGUROS','DBCSI_P2K','APEX_030200')
union all
select count(degree) obj from dba_indexes where degree > '1' and
          OWNER NOT IN
 ('SYS','SYSTEM','OLAPSYS','ORDSYS','XDB','MDSYS','EXFSYS','WMSYS','ORDDATA','DBSNMP','OUTLN',
  'APPQOSSYS','WMSYS','SYSMAN','CTXSYS','TOTVSINSURANCE_SEGUROS','DBCSI_P2K','APEX_030200')
) a;
    exit
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA=0
  fi

  export VAL_ESPERADO=0

  export DSC_METRICA="Quantidade de tabelas e indices com  DEGREE > 0 ( `echo ${VAL_COLETA}` )"

  FUN_OUTPUT
}

## FIM: PE.07 - Funcao: valida sessao com status SUSPENDED por espaco recuperavel

## INICIO: PE.01 - Funcao: valida jobs em BROKEN/FALHA

FUN_PE01() {
  export COD_METRICA="PE.01"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=""
  aux=""
  aux2=""
  export VAL_COLETA=""
  echo "Validando Jobs Broken -  $ORACLE_SID"
  export aux=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select name
    from (
        SELECT distinct substr(JOB,1,10) name
          FROM dba_jobs       
         where broken <> 'N' order by 1
       );
EOF
`
  for linha in `echo $aux`
  do
    aux2=$linha"|"${aux2}
  done

  export DSC_METRICA="Jobs em BROKEN/FALHA. "

  if [ "`echo ${aux2}`" == "" ]
  then
     export VAL_COLETA=""
  else
     export VAL_COLETA="`echo ${aux2}`"
     export DSC_METRICA=`echo ${DSC_METRICA}`" ( `echo ${VAL_COLETA}` )"
  fi

  export VAL_ESPERADO=""

  FUN_OUTPUT
}

## FIM: PE.01 - Funcao: valida jobs em BROKEN/FALHA

## INICIO: PE.04 - Funcao: valida lag do dataguard

FUN_PE04() {
  export COD_METRICA="PE.04"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="num"
  export VAL_THRESHOLD=10
   echo "Validando Lag Dataguard -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
	select  sum(a.sequence - b.sequence) delay
  from (select thread#, dest_id, 'LOCAL' destination, max(sequence#) sequence, max(next_time) next_time
          from v\\$archived_log join v\\$archive_dest using (dest_id)
         where applied = 'NO'
           and standby_dest = 'NO'
                                  and v\\$archive_dest.status <> 'INACTIVE'
           and resetlogs_time = (select resetlogs_time from v\\$database)
         group by thread#, dest_id) a,
       (select thread#, dest_id,
               upper (decode (regexp_instr (destination, '[(]INSTANCE_NAME[=][a-zA-Z|_]*',1), 0, destination,
                              substr (regexp_substr (destination, '[(]INSTANCE_NAME[=][a-zA-Z|_]*'),
                                      instr(regexp_substr (destination, '[(]INSTANCE_NAME[=][a-zA-Z|_]*'),'=')+1))) destination,
               max(sequence#) sequence, max(next_time) next_time
          from v\\$archived_log join v\\$archive_dest using (dest_id)
         where applied = 'YES'
           and standby_dest = 'YES'
                                  and v\\$archive_dest.status <> 'INACTIVE'
           and resetlogs_time = (select resetlogs_time from v\\$database)
         group by thread#, dest_id, destination) b
where a.thread# = b.thread#(+)
order by a.thread#, b.dest_id;	   
exit	
EOF
`
  if [ "`echo ${VAL_COLETA}`" == "" ]
  then
     VAL_COLETA=0
  fi

  export VAL_ESPERADO=10

  export DSC_METRICA="Lag do dataguard Esperado ate  "${VAL_ESPERADO}"  Valor Recebido ( `echo ${VAL_COLETA}` )"
  FUN_OUTPUT
}

## FIM: PE.04 - Funcao: valida lag do dataguard

## INICIO: PE.05 - Funcao: valida estatisticas tabelas

FUN_PE05() {
  export COD_METRICA="PE.05"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=""
  aux=""
  aux2=""
    echo "Validando estatisticas -  $ORACLE_SID"
  export VAL_COLETA=""
  export aux=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select distinct name
    from (
        select owner name,table_name , stale_stats, last_analyzed 
          from dba_tab_statistics 
         where 
          OWNER NOT IN 
 ('SYS','SYSTEM','OLAPSYS','ORDSYS','XDB','MDSYS','EXFSYS','WMSYS','ORDDATA','DBSNMP','OUTLN',
  'APPQOSSYS','WMSYS','SYSMAN','CTXSYS','TOTVSINSURANCE_SEGUROS','DBCSI_P2K','APEX_030200')
           and stale_stats='YES'
           and last_analyzed <= sysdate -30
       );
EOF
`
  for linha in `echo $aux`
  do
    aux2=$linha"|"${aux2}
  done

  export DSC_METRICA="Schemas com estatisticas desatualizadas. "

  if [ "`echo ${aux2}`" == "" ]
  then
     export VAL_COLETA=""
  else
     export VAL_COLETA="`echo ${aux2}`"
     export DSC_METRICA=`echo ${DSC_METRICA}`" ( `echo ${VAL_COLETA}` )"
  fi

  export VAL_ESPERADO=""

  FUN_OUTPUT
}

## FIM: PE.05 - Funcao: valida estatisticas tabelas


## INICIO: SE.01 - Funcao: valida alteracao admin

FUN_SE01() {
  export COD_METRICA="SE.01"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=1
  echo "Validando usuarios Sys e System -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select count(1)  from user$ where name in ('SYS','SYSTEM') and PTIME > sysdate-1;
    exit
EOF
`
  export DSC_METRICA="Alteracao usuario administrativo"

  export VAL_ESPERADO=0


  FUN_OUTPUT
}

## FIM: SE.01 - Funcao: valida alteracao admin

## INICIO: SE.02 - Funcao: valida priv dba

FUN_SE02() {
  export COD_METRICA="SE.02"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="txt"
  export VAL_THRESHOLD=1
   echo "Validando Grant de DBA -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    select count(1) from dba_role_privs where granted_role='DBA' and grantee not in ('TIVITADM','SYS','OGGUSER','SYSTEM','GGS_MON');
    exit
EOF
`
  export DSC_METRICA="Usuarios com privilegio DBA"

  export VAL_ESPERADO=0


  FUN_OUTPUT
}

## FIM: SE.02 - Funcao: valida  priv dba

## INICIO: SE.03 - Funcao: valida tamanho aud$

FUN_SE03() {
  export COD_METRICA="SE.03"
  export CONNECT_BD="/ as sysdba"
  export TIP_VAL_ESPERADO="num"
  export VAL_THRESHOLD=1

   echo "Validando tamanho da SYS.AUD -  $ORACLE_SID"
  export VAL_COLETA=`${ORACLE_HOME}/bin/sqlplus -s /nolog <<EOF
    conn ${CONNECT_BD}
    set linesize 120 pagesize 60 head off feed off verify off echo off
    alter session set NLS_NUMERIC_CHARACTERS=', ';
    select nvl(round(sum(seg.bytes/1024/1024)),0)
      from dba_segments seg
     where seg.segment_name='AUD\$';
    exit
EOF
`
  export VAL_ESPERADO="2048"
  export DSC_METRICA="AUD\$ < ${VAL_ESPERADO} MB ( `echo ${VAL_COLETA}` MB )"


  FUN_OUTPUT
}

## FIM: SE.03 - Funcao: valida recyclebin



 FUN_OUTPUT() {

## FUNCAO DE OK OU NAO OK ##
  if [ "$VAR_DISPLAY_MODE" == "txt" ]
  then
    V_OK="OK"
    V_NOK="NOK"
  elif [ "$VAR_DISPLAY_MODE" == "html" ]
  then
    V_OK="<p class='verde'>OK</p>"
    V_NOK="<p class='verm'>NOK</p>"
  else
    V_OK="`printf ${VERDE}.OK${SEMCOR}`"
    V_NOK="`printf ${VERMELHO}NOK${SEMCOR}`"
  fi 

## Valida que configuracao sera feita ##

  if [ "`printf ${TIP_VAL_ESPERADO}`" = "num" ]
  then
     if [ ${VAL_ESPERADO} -gt ${VAL_COLETA} ]
     then
       VAL_OK=$V_OK
     else
      VAL_OK=$V_NOK
     fi
  elif [ "`printf ${TIP_VAL_ESPERADO}`" = "num_menos" ]
  then
     if [ ${VAL_ESPERADO} -lt ${VAL_COLETA} ]
     then
       VAL_OK=$V_OK
     else
      VAL_OK=$V_NOK
     fi
  else
    if [ "`echo ${VAL_ESPERADO}`" = "`echo ${VAL_COLETA}`"  ]
    then
      VAL_OK=$V_OK
    else
      VAL_OK=$V_NOK
    fi  
  fi
############################################### 
  
  
  
  if [ "$VAR_DISPLAY_MODE" == "txt" ]
  then
    printf  "$format" "${VAL_OK}" "${SERVIDOR}" "${ORACLE_SID}" "${COD_METRICA} - ${DSC_METRICA}" >> $LOG_FILE
  elif [ "$VAR_DISPLAY_MODE" == "html" ]
  then
    echo "<tr><td>"${VAL_OK}"</td><td>"${SERVIDOR}"</td><td>"${ORACLE_SID}"</td><td>"${COD_METRICA}" - "${DSC_METRICA}"</td></tr>"  >> $LOG_FILE
  else
    printf  "$format" "${VAL_OK}" "${SERVIDOR}" "${ORACLE_SID}" "${COD_METRICA} - ${DSC_METRICA}"
  fi
}


## Execucoes:
FUN_EXECUTA(){
  


  LOG_FILE=$HOME/dba/logs/checklist_$DH.$VAR_DISPLAY_MODE
  if [ "$VAR_DISPLAY_MODE" == "txt" ]
  then
    ## Cabecalho
    echo "---> Inicio: Checklist Central Nacional Unimed "$SERVIDOR" - data: "`date "+%F %T"` >> $LOG_FILE

    ## PRINT
    divider="========================================================================================="
    divider=$divider$divider
    header="\n %-1s| %-1s| %-15s|%-100s\n"
    format=" %-15s| %-15s| %-15s |%-120s \n"
    width=150
    printf "$header" "VAL" "SERVIDOR" "BD" "METRICA" >> $LOG_FILE
    printf "%$width.${width}s\n" "$divider">> $LOG_FILE

  elif [ "$VAR_DISPLAY_MODE" == "html" ]
  then
    echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">" >> $LOG_FILE
    echo "<!-- Checklist - by matsuo.furushima@tivit.com - V.3 - Central Nacional Unimed -->" >> $LOG_FILE
    echo "<html>" >> $LOG_FILE
    echo "<head>" >> $LOG_FILE
    echo "<title>Checklist Central Nacional Unimed "$SERVIDOR" - data: `date`</title>" >> $LOG_FILE
    echo "<script>" >> $LOG_FILE
    echo "function sortTable(n) {" >> $LOG_FILE
    echo "  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;" >> $LOG_FILE
    echo "  table = document.getElementById('myTable');" >> $LOG_FILE
    echo "  switching = true;" >> $LOG_FILE
    echo "  //Set the sorting direction to ascending:" >> $LOG_FILE
    echo "  dir = 'asc'; " >> $LOG_FILE
    echo "  /*Make a loop that will continue until" >> $LOG_FILE
    echo "  no switching has been done:*/" >> $LOG_FILE
    echo "  while (switching) {" >> $LOG_FILE
    echo "    //start by saying: no switching is done:" >> $LOG_FILE
    echo "    switching = false;" >> $LOG_FILE
    echo "    rows = table.getElementsByTagName('TR');" >> $LOG_FILE
    echo "    /*Loop through all table rows (except the" >> $LOG_FILE
    echo "    first, which contains table headers):*/" >> $LOG_FILE
    echo "    for (i = 1; i < (rows.length - 1); i++) {" >> $LOG_FILE
    echo "      //start by saying there should be no switching:" >> $LOG_FILE
    echo "      shouldSwitch = false;" >> $LOG_FILE
    echo "      /*Get the two elements you want to compare," >> $LOG_FILE
    echo "      one from current row and one from the next:*/" >> $LOG_FILE
    echo "      x = rows[i].getElementsByTagName('TD')[n];" >> $LOG_FILE
    echo "      y = rows[i + 1].getElementsByTagName('TD')[n];" >> $LOG_FILE
    echo "      /*check if the two rows should switch place," >> $LOG_FILE
    echo "      based on the direction, asc or desc:*/" >> $LOG_FILE
    echo "      if (dir == 'asc') {" >> $LOG_FILE
    echo "        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {" >> $LOG_FILE
    echo "          //if so, mark as a switch and break the loop:" >> $LOG_FILE
    echo "          shouldSwitch= true;" >> $LOG_FILE
    echo "          break;" >> $LOG_FILE
    echo "        }" >> $LOG_FILE
    echo "      } else if (dir == 'desc') {" >> $LOG_FILE
    echo "        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {" >> $LOG_FILE
    echo "          //if so, mark as a switch and break the loop:" >> $LOG_FILE
    echo "          shouldSwitch= true;" >> $LOG_FILE
    echo "          break;" >> $LOG_FILE
    echo "        }" >> $LOG_FILE
    echo "      }" >> $LOG_FILE
    echo "    }" >> $LOG_FILE
    echo "    if (shouldSwitch) {" >> $LOG_FILE
    echo "      /*If a switch has been marked, make the switch" >> $LOG_FILE
    echo "      and mark that a switch has been done:*/" >> $LOG_FILE
    echo "      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);" >> $LOG_FILE
    echo "      switching = true;" >> $LOG_FILE
    echo "      //Each time a switch is done, increase this count by 1:" >> $LOG_FILE
    echo "      switchcount ++;" >> $LOG_FILE
    echo "    } else {" >> $LOG_FILE
    echo "      /*If no switching has been done AND the direction is 'asc'," >> $LOG_FILE
    echo "      set the direction to 'desc' and run the while loop again.*/" >> $LOG_FILE
    echo "      if (switchcount == 0 && dir == 'asc') {" >> $LOG_FILE
    echo "        dir = 'desc';" >> $LOG_FILE
    echo "        switching = true;" >> $LOG_FILE
    echo "      }" >> $LOG_FILE
    echo "    }" >> $LOG_FILE
    echo "  }" >> $LOG_FILE
    echo "}" >> $LOG_FILE
    echo "</script>" >> $LOG_FILE
    echo "<style>" >> $LOG_FILE
    echo "  body {" >> $LOG_FILE
    echo "    font-family: Arial, Helvetica, sans-serif; " >> $LOG_FILE
    echo "    } " >> $LOG_FILE
    echo "  table { " >> $LOG_FILE
    echo "        border-collapse: collapse;"  >> $LOG_FILE
    echo "  } " >> $LOG_FILE
    echo "  table, th, td { "  >> $LOG_FILE
    echo "    border: 1px solid black; "  >> $LOG_FILE
    echo "  }"  >> $LOG_FILE
    echo "  th { "  >> $LOG_FILE
    echo "    text-align: center; "  >> $LOG_FILE
    echo "    background-color: green;"  >> $LOG_FILE
    echo "    color: white;"  >> $LOG_FILE
    echo "  }"  >> $LOG_FILE
    echo "  td { "  >> $LOG_FILE
    echo "    text-align: left; "  >> $LOG_FILE
    echo "  }"  >> $LOG_FILE
    echo "  tr:nth-child(even) {background-color: #f2f2f2}" >> $LOG_FILE
    echo "  p.verm { " >> $LOG_FILE
    echo "    color: white;" >> $LOG_FILE
    echo "    background-color:red;" >> $LOG_FILE
    echo " } " >> $LOG_FILE
    echo "  p.verde { " >> $LOG_FILE
    echo "    color: white;" >> $LOG_FILE
    echo "    background-color:green;" >> $LOG_FILE
    echo " } " >> $LOG_FILE
	echo "  p.verde_head { " >> $LOG_FILE
    echo "    color: green;" >> $LOG_FILE
    echo " } " >> $LOG_FILE
    echo " h1 {" >> $LOG_FILE
    echo "  text-align: center; " >> $LOG_FILE
    echo " } " >> $LOG_FILE
    echo "</style>" >> $LOG_FILE
    echo "</head>" >> $LOG_FILE
    echo "<body>" >> $LOG_FILE
    echo "<h1 class='verde'>Check Database - Exadata </h1>" >> $LOG_FILE
	echo "<center><img src="https://i.ibb.co/b7GsGh4/tivit.png" alt="tivit" border="0" width=104 height=104>" >> $LOG_FILE
    echo "<img src="https://i.ibb.co/XJ7yWv9/CNU.png" alt="CNU" border="0"width=154 height=104></center>" >> $LOG_FILE
    echo "<p><b>Servidor de Origem : </b> "$SERVIDOR"</p>" >> $LOG_FILE
    echo "<p> <b> Inicio: </b> `date "+%F %T"`</p>" >> $LOG_FILE
	echo "<p><font size="1">Developed by Mfurushima.</font></p>" >> $LOG_FILE
    echo "<div style='overflow-x:auto;'>" >> $LOG_FILE
    echo "<table id='myTable'>" >> $LOG_FILE
    echo "<tr>"  >> $LOG_FILE
    echo "  <th onclick='sortTable(0)'>Status</th>"  >> $LOG_FILE
    echo "  <th onclick='sortTable(1)'>Servidor</th>"  >> $LOG_FILE
    echo "  <th onclick='sortTable(2)'>Banco de dados</th>"  >> $LOG_FILE
    echo "  <th onclick='sortTable(3)'>Metrica</th>"  >> $LOG_FILE
    echo "</tr>"  >> $LOG_FILE

  else
    ## colors -- begin
    VERMELHO='\033[0;31m'
    VERDE='\033[0;32m'
    SEMCOR='\033[0m' # No Color
    ## colors -- end
    clear
    
    ## Cabecalho
    echo "---> Inicio: Checklist Central Nacional Unimed "$SERVIDOR" - data: "`date`
    printf "\n"

    ## PRINT
    divider="========================================================================================="
    divider=$divider$divider
    header="\n %-1s| %-1s| %-15s|%-100s\n"
    format=" %-15s| %-15s| %-15s |%-120s \n"
    width=150
    printf "$header" "VAL" "SERVIDOR" "BD" "METRICA"
    printf "%$width.${width}s\n" "$divider"

  fi


## Realiza os checks para funcoes de S.O
  
 FUN_OS00 #UP Down
 FUN_OS01 #Valida filesystem
 FUN_OS02 #Valida uptime
 FUN_OS03 #Valida load average
 FUN_OS04 #Valida memoria
 FUN_OS05 #Valida swap
 FUN_OS06 #Valida inodes
 FUN_OS07 #Valida CPU


## Realiza Checkagens do banco de dados


 for DB in $ALL_DATABASES
 do
  unset  TWO_TASK
  export ORACLE_SID=$DB
  export ORACLE_HOME=`grep "^${DB}:" ${PATH_ORATAB}/oratab|cut -d: -f2 -s`
  export PATH=$ORACLE_HOME/bin:$PATH

  FUN_HA01 # Verifica se a Instancia esta Open / Mount e etc

  # Se banco diferente de down continua executando demais metricas
  if [ "`printf ${VAL_COLETA}`" != "DOWN" ] && [ "${VAL_OK}" = "$V_OK" ]
  then
    FUN_HA02 # Verifica o ultimo startup 
	
    # Metricas para ASM
    if [ "`echo ${ORACLE_SID} | cut -c1`" = "+" ]
    then
      FUN_HA04 # valida diskgroups
    elif [ "`printf ${V_DB_ROLE}`" == "PRIMARY" ]
    then
      FUN_HA05 #valida tablespaces
      FUN_HA06 #valida dbfiles
      FUN_HA07 #Valida erros no Alert
      FUN_HA08 #valida backup archive
      FUN_HA09 #valida backup hot
	  
      #Colocar aqui metricas especificas por versao de banco, se for metrica geral colocar acima
      if [ `printf ${V_DB_VERSION} | cut -d. -f1` -ge 10 ]
      then
        FUN_HA11 #Valida Area de Archive
        FUN_HA12 #Valida Quantidade de processos
        FUN_HA14 #Valida Limite de Recursos
        FUN_HA13 #Tamanho de RecycleBin
        FUN_PE01 #Valida jobs em BROKEN/FALHA
        FUN_PE02 #Valida lock
        FUN_PE03 #Valida index unusable
        FUN_PE04 #Valida lag do dataguard
        ##FUN_PE05 #Valida estatistica de tabela
        FUN_PE06 #valida sessao com status SUSPENDED por espaco recuperavel
        FUN_PE07 #valida tabelas e indices  com  DEGREE > 0
        ##FUN_PE08
        FUN_PE09 #Valida componentes invalidos
        FUN_SE01 #Alteracoes do usuario Sys
        FUN_SE02 #Usuarios DBA
        FUN_SE03 #Tamanho da Audit
      fi
       if [ `printf ${V_DB_VERSION} | cut -d. -f1` -ge 11 ]
       then
         FUN_PE1 #Valida Regressao de Um SQLID
       fi
    else
      #FUN_RE1
	  sleep 1
    fi
  fi
 done




  if [ "$VAR_DISPLAY_MODE" == "txt" ]
  then
    ## Cabecalho
    echo "---> Fim: Checklist do servidor "$SERVIDOR" - data: "`date` >> $LOG_FILE
  elif [ "$VAR_DISPLAY_MODE" == "html" ]
  then
    echo "</table>" >> $LOG_FILE
    echo "</div>" >> $LOG_FILE
    echo "<p>Fim: `date`</p>" >> $LOG_FILE
    echo "<!-- Checklist - by Matsuo Furushima -->" >> $LOG_FILE
    echo "</body>" >> $LOG_FILE
    echo "</html>" >> $LOG_FILE
  else
    printf "\n"
    echo "---> Fim: Checklist do servidor "$SERVIDOR" - data: "`date`
  fi


}


FUN_EXECUTA;
