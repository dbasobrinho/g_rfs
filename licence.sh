#!/bin/bash
ps -ef | grep pmon | grep -v grep | grep -iv asm | awk '{print$8}' | cut -d '_' -f3 > instancias.txt
cat instancias.txt | while read LINE; do
export ORACLE_SID=$LINE
sqlplus / as sysdba<<EOF
spool licence_${ORACLE_SID}.txt;
@licence.sql
exit
EOF
done
