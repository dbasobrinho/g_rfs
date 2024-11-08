#!/bin/bash
while true;do 
export ORACLE_SID=pback
sqlplus / as sysdba <<EOF
@/tmp/scr/scn_status_fuzzy_db.sql
exit
EOF
sleep 5
done
