
for LINE in $(ps -ef | grep pmon | grep -v grep | grep -v ASM | grep -v MGMTDB | cut -d_ -f3| sort)
do
export ORACLE_SID=$LINE
sqlplus / as sysdba<<EOF
spool priv_DBA_$LINE.txt;
@get_priv_dba_sysdba_audit.sql
exit
EOF
done  
