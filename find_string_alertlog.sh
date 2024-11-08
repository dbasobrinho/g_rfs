#!/bin/bash
#============================================================================================================
#Referencia : find_string_alertlog.sh
#Assunto    : Procurar STRING alert, retornando NRO linha, string procurada + uma linha antes e uma depois 
#Criado por : Roberto Fernandes Sobrinho
#Como Usar  : sh find_string_alertlog.sh <STRING_PROCURAR>  |ex:  sh find_string_alertlog.sh ORA-00020
#Data       : 06/11/2020
#Ref        : Nao tem, tudo nosso
#Alteracoes :
#           :
#============================================================================================================
cat `find $ORACLE_BASE -type f -name alert_$ORACLE_SID.log 2> /dev/null |grep trace` |  sed -n -e '/'${1}'/{=;x;1!p;g;$!N;p;D;}' -e h 
##
##sh find_string_alertlog.sh ORA-00020
##cat `find $ORACLE_BASE -type f -name alert_$ORACLE_SID.log |grep trace 2> /dev/null` |  sed -n -e '/ORA-00020/{=;x;1!p;g;$!N;p;D;}' -e h