#!/bin/bash
# script: capivara.sh
# desc: emite relatorio detalhado sql_id usando o SQLHC

if [ -z $1 ]; then
  echo "Erro: falta passar sql_id como parametro.."
  exit 1
fi

sqlplus / as sysdba <<EOF > sqlhc_$1.out 2>&1
@sqlhc T $1;
exit;
EOF
