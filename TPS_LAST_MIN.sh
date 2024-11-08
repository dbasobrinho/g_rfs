###while true; do sh /u/app/oracle/TVTDBA/TOOL/TPS_LAST_MIN.sh; sleep 5; done

sqlplus -S "/as sysdba"<<EOF
@$ORACLE_BASE/TVTDBA/TOOL/TPS_LAST_MIN.sql
EXIT
EOF