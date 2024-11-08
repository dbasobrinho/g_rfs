#!/bin/sh
ftp -vn 200.185.21.10 <<SCRIPT
user ad\roberto.fernandes s1q2m09U#
cd /06-Banco_de_Dados/ORACLE/ORACLE_11.2.0.4_AIX_64/11.2.0.4_PATCH/2018_07_CPU_p28317141_112040_AIX64-5L
binary
prompt off
mget *.zip
SCRIPT
exit 0
