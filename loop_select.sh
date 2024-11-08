INSTANCE_RUNNING=`ps -ef | grep -i pmon | egrep -iv "asm|grep|awk" | awk -F"_pmon_" '{print$2}'`

## Executa um loop de parametrizacao para cada instancia
for inst in `echo $INSTANCE_RUNNING | sed -e 's/+ASM//g'`
do
export ORACLE_SID=$inst

sqlplus / as sysdba <<EOF
@dba_registry_history_psu.sql
exit
EOF
done
